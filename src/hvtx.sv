module hvtx_cursor #
( parameter int WID = 12

, parameter int unsigned FRAME_WIDTH = 1650
, parameter int unsigned FRAME_HEIGHT = 750

, parameter type POS_T = logic [WID-1:0]
)
( input  var logic i_clk
, input  var logic i_rst

, output var POS_T o_x
, output var POS_T o_y
);

    var POS_T x, y;

    var logic last_pixel;
    var logic last_line;

    assign last_pixel = x == FRAME_WIDTH  - WID'(1);
    assign last_line  = y == FRAME_HEIGHT - WID'(1);

    assign o_x = x;
    assign o_y = y;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            {x, y} <= 0;
        end else begin
            if (last_pixel) begin
                x <= WID'(0);

                if (last_line) begin
                    y <= WID'(0);
                end else begin
                    y <= y + WID'(1);
                end
            end else begin
                x <= x + WID'(1);
            end
        end
    end

endmodule : hvtx_cursor

module hvtx_sync #
( parameter int unsigned WID = 12

, parameter int unsigned FRAME_WIDTH = 1650
, parameter int unsigned FRAME_HEIGHT = 750
, parameter int unsigned ACTIVE_WIDTH = 1280
, parameter int unsigned ACTIVE_HEIGHT = 720
, parameter int unsigned H_PORCH = 110
, parameter int unsigned H_SYNC = 40
, parameter int unsigned V_PORCH = 5
, parameter int unsigned V_SYNC = 5

, parameter type CURSOR_T = logic [WID-1:0]
)
( input  var logic i_clk

, input  var CURSOR_T i_x
, input  var CURSOR_T i_y

, output var logic o_hs
, output var logic o_vs
, output var logic o_de
);

    var CURSOR_T x, y;
    var logic hs, vs, de;

    assign x = i_x;
    assign y = i_y;
    assign {o_hs, o_vs, o_de} = {hs, vs, de};

    localparam int unsigned H_SYNC_START   = ACTIVE_WIDTH + H_PORCH;
    localparam int unsigned H_SYNC_END     = H_SYNC_START + H_SYNC;
    localparam int unsigned V_SYNC_START   = ACTIVE_HEIGHT + V_PORCH;
    localparam int unsigned V_SYNC_END     = V_SYNC_START + V_SYNC;
    localparam int unsigned PREAMBLE_START = FRAME_WIDTH - 10;
    localparam int unsigned GUARD_START    = FRAME_WIDTH - 2;

    logic x_gte_start, x_lt_end, x_lt_start;
    logic y_eq_start, y_vs_last;
    logic y_gte_start, y_lt_end;
    logic x_lt_active, y_lt_active;

    always_ff @(posedge i_clk) begin
        x_gte_start <= (x >= H_SYNC_START);
        x_lt_end    <= (x < H_SYNC_END);
        x_lt_start  <= (x < H_SYNC_START);

        y_eq_start  <= y == V_SYNC_START;
        y_vs_last   <= y == V_SYNC_END - 1;

        y_gte_start <= y >= V_SYNC_START;
        y_lt_end    <= y < V_SYNC_END;

        x_lt_active <= x < ACTIVE_WIDTH;
        y_lt_active <= y < ACTIVE_HEIGHT;
    end

    always_ff @(posedge i_clk) begin
        hs <= x_gte_start & x_lt_end;

        if (y_eq_start) begin
            vs <= x_gte_start;
        end else if (y_vs_last) begin
            vs <= x_lt_start;
        end else begin
            vs <= y_gte_start & y_lt_end;
        end

        de <= x_lt_active & y_lt_active;
    end

endmodule : hvtx_sync

module hvtx_mod
( input  var logic i_pclk
, input  var logic i_sclk
, input  var logic i_hs
, input  var logic i_vs
, input  var logic i_de
, input  var logic [2:0][7:0] i_video

, output var logic [2:0][9:0] o_chan_vec
);

    var logic [2:0][1:0] ctl;

    assign ctl = {4'b0000, i_vs, i_hs};

    generate for (genvar chan = 0; chan < 3; chan++) begin : gen_chan_mux
        hvtx_mux #(chan) u_mux
        ( .i_clk(i_pclk)
        , .i_de(i_de)
        , .i_ctl(ctl[chan])
        , .i_video(i_video[chan])
        , .o_symbol(o_chan_vec[chan])
        );
    end endgenerate

endmodule : hvtx_mod

module hvtx_mux #
( parameter int CHAN = 0
)
( input  var logic i_clk

, input  var logic       i_de
, input  var logic [1:0] i_ctl
, input  var logic [7:0] i_video

, output var logic [9:0] o_symbol
);

    var logic de;
    var logic [9:0] ctl_symbol;
    var logic [9:0] video_symbol;

    always_ff @(posedge i_clk)
        de <= i_de;

    always_ff @(posedge i_clk)
        unique case (i_ctl)
            2'b00: ctl_symbol <= 10'b1101010100;
            2'b01: ctl_symbol <= 10'b0010101011;
            2'b10: ctl_symbol <= 10'b0101010100;
            2'b11: ctl_symbol <= 10'b1010101011;
        endcase

    hvtx_8b10b u_8b10b
    ( .i_clk(i_clk)
    , .i_rst(~i_de)
    , .i_data(i_video)
    , .o_symbol(video_symbol)
    );

    always_ff @(posedge i_clk) begin
        if (de) o_symbol <= video_symbol;
        else    o_symbol <= ctl_symbol;
    end

endmodule : hvtx_mux

module hvtx_8b10b
( input  var logic i_clk
, input  var logic i_rst

, input  var logic [7:0] i_data

, output var logic [9:0] o_symbol
);

    var logic signed [4:0] disparity;
    var logic signed [4:0] dispadd;

    var logic [8:0] ir;
    var logic [3:0] n1d;
    var logic [4:0] n1ir;
    var logic [4:0] n0ir;
    var logic [9:0] symbol;

    var logic use_xnor;

    assign n1d  = 4'($countones(i_data));
    assign n1ir = 5'($countones(ir[7:0]));
    assign n0ir = 5'(8 - $countones(ir[7:0]));

    assign use_xnor = n1d > 4'd4 || (n1d == 4'd4 && i_data[0] == 1'b0);

    always_comb begin
        ir[0] = i_data[0];

        if (use_xnor) begin
            for (int i = 1; i < 8; i++) begin
                ir[i] = ir[i - 1] ~^ i_data[i];
            end

            ir[8] = 1'b0;
        end else begin
            for (int i = 1; i < 8; i++) begin
                ir[i] = ir[i - 1] ^ i_data[i];
            end

            ir[8] = 1'b1;
        end

        if (disparity == 5'sd0 || (n1ir == n0ir)) begin
            symbol = {~ir[8], ir[8], ir[8] ? ir[7:0] : ~ir[7:0]};
            dispadd = ir[8] ? n1ir - n0ir : n0ir - n1ir;
        end else if ((disparity > 5'sd0 && n1ir > n0ir) || (disparity < 5'sd0 && n1ir < n0ir)) begin
            symbol = {1'b1, ir[8], ~ir[7:0]};
            dispadd = (n0ir - n1ir) + (ir[8] ? 5'sd2 : 5'sd0);
        end else begin
            symbol = {1'b0, ir[8], ir[7:0]};
            dispadd = (n1ir - n0ir) - (~ir[8] ? 5'sd2 : 5'sd0);
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            disparity <= 0;
        end else begin
            disparity <= disparity + dispadd;
            o_symbol <= symbol;
        end
    end

endmodule : hvtx_8b10b

module hvtx_ser #
( parameter string LVDS_MODE = "ELVDS"
)
( input  var logic i_pclk
, input  var logic i_sclk
, input  var logic i_rst

, input  var logic [2:0][9:0] i_chan_vec

, output var logic       o_hdmi_clk_p
, output var logic       o_hdmi_clk_n
, output var logic [2:0] o_hdmi_chan_p
, output var logic [2:0] o_hdmi_chan_n
);

    generate for(genvar i = 0; i < 3; i++) begin : gen_oser10
        var logic hdmi_chan;

        OSER10 u_chan_serde
        ( .Q(hdmi_chan)
        , .D0(i_chan_vec[i][0])
        , .D1(i_chan_vec[i][1])
        , .D2(i_chan_vec[i][2])
        , .D3(i_chan_vec[i][3])
        , .D4(i_chan_vec[i][4])
        , .D5(i_chan_vec[i][5])
        , .D6(i_chan_vec[i][6])
        , .D7(i_chan_vec[i][7])
        , .D8(i_chan_vec[i][8])
        , .D9(i_chan_vec[i][9])
        , .PCLK(i_pclk)
        , .FCLK(i_sclk)
        , .RESET(i_rst)
        );

       if (LVDS_MODE == "ELVDS") begin : gen_elvds_data
           ELVDS_OBUF u_lvds_obuf
           ( .I(hdmi_chan)
           , .O(o_hdmi_chan_p[i])
           , .OB(o_hdmi_chan_n[i])
           );
       end else if (LVDS_MODE == "TLVDS") begin : gen_tlvds_data
           TLVDS_OBUF u_lvds_obuf
           ( .I(hdmi_chan)
           , .O(o_hdmi_chan_p[i])
           , .OB(o_hdmi_chan_n[i])
           );
       end else initial begin
           $fatal(1, "Unknown LVDS mode");
       end
    end endgenerate

    logic hdmi_clk;

    OSER10 u_clk_serde
    ( .Q(hdmi_clk)
    , .D0(1'b1)
    , .D1(1'b1)
    , .D2(1'b1)
    , .D3(1'b1)
    , .D4(1'b1)
    , .D5(1'b0)
    , .D6(1'b0)
    , .D7(1'b0)
    , .D8(1'b0)
    , .D9(1'b0)
    , .PCLK(i_pclk)
    , .FCLK(i_sclk)
    , .RESET(i_rst)
    );

    generate
        if (LVDS_MODE == "ELVDS") begin : gen_elvds_clk
            ELVDS_OBUF u_lvds_obuf
            ( .I(hdmi_clk)
            , .O(o_hdmi_clk_p)
            , .OB(o_hdmi_clk_n)
            );
        end else if (LVDS_MODE == "TLVDS") begin : gen_elvds_clk
            TLVDS_OBUF u_lvds_obuf
            ( .I(hdmi_clk)
            , .O(o_hdmi_clk_p)
            , .OB(o_hdmi_clk_n)
            );
        end else initial begin
            $fatal(1, "Unknown LVDS mode");
        end
    endgenerate

endmodule : hvtx_ser
