module top
( input  var logic i_rst_n
, input  var logic i_ref_clk

, output var logic       o_hdmi_clk_p_a
, output var logic       o_hdmi_clk_n_a
, output var logic [2:0] o_hdmi_chan_p_a
, output var logic [2:0] o_hdmi_chan_n_a

, output var logic       o_hdmi_clk_p_b
, output var logic       o_hdmi_clk_n_b
, output var logic [2:0] o_hdmi_chan_p_b
, output var logic [2:0] o_hdmi_chan_n_b
);

    localparam int unsigned WID = 12;

    localparam int unsigned FRAME_WIDTH = 2200;
    localparam int unsigned FRAME_HEIGHT = 1125;
    localparam int unsigned ACTIVE_WIDTH = 1920;
    localparam int unsigned ACTIVE_HEIGHT = 1080;
    localparam int unsigned H_PORCH = 88;
    localparam int unsigned H_SYNC = 44;
    localparam int unsigned V_PORCH = 4;
    localparam int unsigned V_SYNC = 5;

    localparam logic [WID*2-1:0] FRAME_DURATION = 'd2475000;

    logic serial_clk /*synthesis syn_keep=1*/;
    logic pixel_clk /*synthesis syn_keep=1*/;

    logic [WID-1:0] x_0, x_1, x_2;
    logic [WID-1:0] y_0, y_1, y_2;

    logic hs_0, vs_0, de_0;
    logic hs_1, vs_1, de_1;
    logic hs_2, vs_2, de_2;

    logic hdmi_clk;
    logic [2:0][9:0] chan_vec;

    logic [WID*2-1:0] frame_cnt;
    logic [WID-1:0] box_x;
    logic [WID-1:0] box_y;

    always_ff @(posedge pixel_clk) begin
        if (!i_rst_n) begin
            frame_cnt <= 0;
        end else if (frame_cnt == FRAME_DURATION - WID'(1)) begin
            frame_cnt <= 0;
            box_x <= box_x == ACTIVE_WIDTH - WID'(10) ? WID'(10) : box_x + WID'(10);
            box_y <= box_x == ACTIVE_WIDTH - WID'(10) ? (box_y == ACTIVE_HEIGHT - WID'(10) ? WID'(0) : box_y + WID'(10)) : box_y;
        end else begin
            frame_cnt <= frame_cnt + (WID*2-1)'(1);
        end
    end

    logic x_gte_box_x;
    logic x_lt_box_x_plus_10;
    logic y_gte_box_y;
    logic y_lt_box_y_plus_10;

    logic [23:0] video;

    always_ff @(posedge pixel_clk) begin
        x_1 <= x_0; y_1 <= y_0;
        x_2 <= x_1; y_2 <= y_1;

        x_gte_box_x <= x_2 >= box_x;
        x_lt_box_x_plus_10 <= x_2 < box_x + WID'(10);
        y_gte_box_y <= y_2 >= box_y;
        y_lt_box_y_plus_10 <= y_2 < box_y + WID'(10);

        video <= x_gte_box_x & x_lt_box_x_plus_10 & y_gte_box_y && y_lt_box_y_plus_10 ? 24'h00f0f0 : 24'hc0c0c0;
        {hs_1, vs_1, de_1} <= {hs_0, vs_0, de_0};
        {hs_2, vs_2, de_2} <= {hs_1, vs_1, de_1};
    end

    hdmi_pll u_hdmi_pll
    ( .lock()
    , .clkout0(serial_clk)
    , .clkin(i_ref_clk)
    , .reset(~i_rst_n)
    );

    pixel_clkdiv u_pixel_clkdiv
    ( .clkout(pixel_clk)
    , .hclkin(serial_clk)
    , .resetn(i_rst_n)
    );

    hvtx_cursor #
    ( .WID(WID)
    , .FRAME_WIDTH(2200)
    , .FRAME_HEIGHT(1125)
    ) u_cursor
    ( .i_clk(pixel_clk)
    , .i_rst(~i_rst_n)
    , .o_x(x_0)
    , .o_y(y_0)
    );

    hvtx_sync #
    ( .WID(WID)
    , .FRAME_WIDTH(FRAME_WIDTH)
    , .FRAME_HEIGHT(FRAME_HEIGHT)
    , .ACTIVE_WIDTH(ACTIVE_WIDTH)
    , .ACTIVE_HEIGHT(ACTIVE_HEIGHT)
    , .H_PORCH(H_PORCH)
    , .H_SYNC(H_SYNC)
    , .V_PORCH(V_PORCH)
    , .V_SYNC(V_SYNC)
    ) u_sync
    ( .i_clk(pixel_clk)
    , .i_x(x_0)
    , .i_y(y_0)
    , .o_hs(hs_0)
    , .o_vs(vs_0)
    , .o_de(de_0)
    );

    hvtx_mod u_mod
    ( .i_pclk(pixel_clk)
    , .i_sclk(serial_clk)
    , .i_hs(hs_2)
    , .i_vs(vs_2)
    , .i_de(de_2)
    , .i_video(video)
    , .o_chan_vec(chan_vec)
    );

    hvtx_ser #("ELVDS") u_ser_a
    ( .i_pclk(pixel_clk)
    , .i_sclk(serial_clk)
    , .i_rst(~i_rst_n)
    , .i_chan_vec(chan_vec)
    , .o_hdmi_clk_p(o_hdmi_clk_p_a)
    , .o_hdmi_clk_n(o_hdmi_clk_n_a)
    , .o_hdmi_chan_p(o_hdmi_chan_p_a)
    , .o_hdmi_chan_n(o_hdmi_chan_n_a)
    );

    hvtx_ser #("ELVDS") u_ser_b
    ( .i_pclk(pixel_clk)
    , .i_sclk(serial_clk)
    , .i_rst(~i_rst_n)
    , .i_chan_vec(chan_vec)
    , .o_hdmi_clk_p(o_hdmi_clk_p_b)
    , .o_hdmi_clk_n(o_hdmi_clk_n_b)
    , .o_hdmi_chan_p(o_hdmi_chan_p_b)
    , .o_hdmi_chan_n(o_hdmi_chan_n_b)
    );

endmodule : top
