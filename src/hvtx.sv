module hvtx_cursor #
( parameter int WIDTH = 12

, parameter logic [WIDTH-1:0] FRAME_WIDTH = WIDTH'(1650)
, parameter logic [WIDTH-1:0] FRAME_HEIGHT = WIDTH'(750)
)
( input logic i_clk
, input logic i_rst

, output logic [WIDTH-1:0] o_x
, output logic [WIDTH-1:0] o_y
);

    always_ff @(posedge i_clk)
        if (i_rst) begin
            {o_x, o_y} <= '0;
        end else begin
            o_x <= o_x == FRAME_WIDTH - WIDTH'(1) ? WIDTH'(0) : o_x + WIDTH'(1);
            o_y <= o_x == FRAME_WIDTH - WIDTH'(1) ? (o_y == FRAME_HEIGHT - WIDTH'(1) ? WIDTH'(0) : o_y + WIDTH'(1)) : o_y;
        end

endmodule : hvtx_cursor

module hvtx_sync #
( parameter int WIDTH = 12

, parameter logic [WIDTH-1:0] FRAME_WIDTH = WIDTH'(1650)
, parameter logic [WIDTH-1:0] FRAME_HEIGHT = WIDTH'(750)
, parameter logic [WIDTH-1:0] ACTIVE_WIDTH = WIDTH'(1280)
, parameter logic [WIDTH-1:0] ACTIVE_HEIGHT = WIDTH'(720)
, parameter logic [WIDTH-1:0] H_PORCH = WIDTH'(110)
, parameter logic [WIDTH-1:0] H_SYNC = WIDTH'(40)
, parameter logic [WIDTH-1:0] V_PORCH = WIDTH'(5)
, parameter logic [WIDTH-1:0] V_SYNC = WIDTH'(5)
)
( input logic i_clk

, input logic [WIDTH-1:0] i_x
, input logic [WIDTH-1:0] i_y

, output logic o_hs
, output logic o_vs
, output logic o_de
);

    localparam logic [WIDTH-1:0] H_SYNC_START   = ACTIVE_WIDTH + H_PORCH;
    localparam logic [WIDTH-1:0] H_SYNC_END     = H_SYNC_START + H_SYNC;
    localparam logic [WIDTH-1:0] V_SYNC_START   = ACTIVE_HEIGHT + V_PORCH;
    localparam logic [WIDTH-1:0] V_SYNC_END     = V_SYNC_START + V_SYNC;
    localparam logic [WIDTH-1:0] PREAMBLE_START = FRAME_WIDTH - WIDTH'(10);
    localparam logic [WIDTH-1:0] GUARD_START    = FRAME_WIDTH - WIDTH'(2);

    always_ff @(posedge i_clk) begin
        o_hs <= i_x >= H_SYNC_START && i_x < H_SYNC_END;

        if (i_y == V_SYNC_START) begin
            o_vs <= i_x >= H_SYNC_START;
        end else if (i_y == V_SYNC_END - WIDTH'(1)) begin
            o_vs <= i_x < H_SYNC_START;
        end else begin
            o_vs <= i_y >= V_SYNC_START && i_y < V_SYNC_END;
        end

        o_de <= i_x < ACTIVE_WIDTH && i_y < ACTIVE_HEIGHT;
    end

endmodule : hvtx_sync

module hvtx_mod
( input logic i_pixel_clk
, input logic i_serial_clk
, input logic i_rst
, input logic i_hs
, input logic i_vs
, input logic i_de
, input logic [2:0][7:0] i_video

, output logic [2:0][9:0] o_chan_vec
);

    logic [2:0][1:0] ctl;

    assign ctl = {4'b0000, i_vs, i_hs};

    generate for (genvar chan = 0; chan < 3; chan++) begin : gen_chan_mux
        hvtx_mux #(chan) u_mux
        ( .i_clk(i_pixel_clk)
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
( input logic i_clk

, input logic       i_de
, input logic [1:0] i_ctl
, input logic [7:0] i_video

, output logic [9:0] o_symbol
);

    logic de;
    logic [9:0] ctl_symbol;
    logic [9:0] video_symbol;

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

    always_ff @(posedge i_clk)
        if (de) o_symbol <= video_symbol;
        else    o_symbol <= ctl_symbol;              

endmodule : hvtx_mux

module hvtx_8b10b
( input logic i_clk
, input logic i_rst

, input logic [7:0] i_data

, output logic [9:0] o_symbol
);

    logic signed [4:0] disparity;
    logic [8:0] ir;

    logic [3:0] n1d;
    logic signed [4:0] n1ir;
    logic signed [4:0] n0ir;

    assign n1d  = 4'($countones(i_data));
    assign n1ir = 5'($countones(ir[7:0]));
    assign n0ir = 5'sd8 - 5'($countones(ir[7:0]));

    logic signed [4:0] dispadd;

    logic [9:0] next_symbol;

    always_comb begin
        ir[0] = i_data[0];

        if (n1d > 4'd4 || (n1d == 4'd4 && i_data[0] == 1'b0)) begin
            ir[1] = ir[0] ~^ i_data[1];
            ir[2] = ir[1] ~^ i_data[2];
            ir[3] = ir[2] ~^ i_data[3];
            ir[4] = ir[3] ~^ i_data[4];
            ir[5] = ir[4] ~^ i_data[5];
            ir[6] = ir[5] ~^ i_data[6];
            ir[7] = ir[6] ~^ i_data[7];

            ir[8] = 1'b0;
        end else begin
            ir[1] = ir[0] ^ i_data[1];
            ir[2] = ir[1] ^ i_data[2];
            ir[3] = ir[2] ^ i_data[3];
            ir[4] = ir[3] ^ i_data[4];
            ir[5] = ir[4] ^ i_data[5];
            ir[6] = ir[5] ^ i_data[6];
            ir[7] = ir[6] ^ i_data[7];

            ir[8] = 1'b1;
        end

        if (disparity == 5'sd0 || (n1ir == n0ir)) begin
            next_symbol = {~ir[8], ir[8], ir[8] ? ir[7:0] : ~ir[7:0]};
            dispadd = ir[8] ? n1ir - n0ir : n0ir - n1ir;
        end else if ((disparity > 5'sd0 && n1ir > n0ir) || (disparity < 5'sd0 && n1ir < n0ir)) begin
            next_symbol = {1'b1, ir[8], ~ir[7:0]};
            dispadd = (n0ir - n1ir) + (ir[8] ? 5'sd2 : 5'sd0);
        end else begin
            next_symbol = {1'b0, ir[8], ir[7:0]};
            dispadd = (n1ir - n0ir) - (~ir[8] ? 5'sd2 : 5'sd0);
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            disparity <= 0;
            o_symbol <= 10'b0;
        end else begin
            disparity <= disparity + dispadd;
            o_symbol <= next_symbol;
        end
    end

endmodule : hvtx_8b10b

module hvtx_ser
( input logic i_pixel_clk
, input logic i_serial_clk
, input logic i_rst

, input logic [2:0][9:0] i_chan_vec

, output logic o_hdmi_clk_p
, output logic o_hdmi_clk_n
, output logic [2:0] o_hdmi_chan_p
, output logic [2:0] o_hdmi_chan_n
);

    generate for(genvar i = 0; i < 3; i++) begin : gen_oser10
        logic hdmi_chan;

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
        , .PCLK(i_pixel_clk)
        , .FCLK(i_serial_clk)
        , .RESET(i_rst)
        );

        ELVDS_OBUF u_lvds_obuf
        ( .I(hdmi_chan)
        , .O(o_hdmi_chan_p[i])
        , .OB(o_hdmi_chan_n[i])
        );
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
    , .PCLK(i_pixel_clk)
    , .FCLK(i_serial_clk)
    , .RESET(i_rst)
    );

    ELVDS_OBUF u_lvds_obuf
    ( .I(hdmi_clk)
    , .O(o_hdmi_clk_p)
    , .OB(o_hdmi_clk_n)
    );

endmodule : hvtx_ser
