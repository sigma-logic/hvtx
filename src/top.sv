module top
( input logic rst_n
, inout logic ref_clk

, output logic       hdmi_clk_p_a
, output logic       hdmi_clk_n_a
, output logic [2:0] hdmi_chan_p_a
, output logic [2:0] hdmi_chan_n_a

, output logic       hdmi_clk_p_b
, output logic       hdmi_clk_n_b
, output logic [2:0] hdmi_chan_p_b
, output logic [2:0] hdmi_chan_n_b
);

    localparam int WIDTH = 11;

    localparam logic [WIDTH-1:0] FRAME_WIDTH = WIDTH'(1650);
    localparam logic [WIDTH-1:0] FRAME_HEIGHT = WIDTH'(750);
    localparam logic [WIDTH-1:0] ACTIVE_WIDTH = WIDTH'(1280);
    localparam logic [WIDTH-1:0] ACTIVE_HEIGHT = WIDTH'(720);
    localparam logic [WIDTH-1:0] H_PORCH = WIDTH'(110);
    localparam logic [WIDTH-1:0] H_SYNC = WIDTH'(40);
    localparam logic [WIDTH-1:0] V_PORCH = WIDTH'(5);
    localparam logic [WIDTH-1:0] V_SYNC = WIDTH'(5);

    localparam logic [WIDTH*2-1:0] FRAME_DURATION = 'd1237500;

    logic serial_clk;
    logic pixel_clk;

    logic [WIDTH-1:0] x;
    logic [WIDTH-1:0] y;

    logic hs, vs, de;

    logic hdmi_clk;
    logic [2:0][9:0] chan_vec;

    logic [WIDTH*2-1:0] frame_cnt;
    logic [WIDTH-1:0] box_x;
    logic [WIDTH-1:0] box_y;

    always_ff @(posedge pixel_clk) begin
        if (!rst_n) begin
            frame_cnt <= 0;
        end else if (frame_cnt == FRAME_DURATION - WIDTH'(1)) begin
            frame_cnt <= 0;
            box_x <= box_x == ACTIVE_WIDTH - WIDTH'(10) ? WIDTH'(10) : box_x + WIDTH'(10);
            box_y <= box_x == ACTIVE_WIDTH - WIDTH'(10) ? (box_y == ACTIVE_HEIGHT - WIDTH'(10) ? WIDTH'(0) : box_y + WIDTH'(10)) : box_y;
        end else begin
            frame_cnt <= frame_cnt + (WIDTH*2-1)'(1);
        end
    end

    logic [23:0] video;

    assign video = x >= box_x && x < box_x + WIDTH'(10) && y >= box_y && y < box_y + WIDTH'(10) ? 24'hff00a8 : 24'h0;

    hdmi_pll u_hdmi_pll
    ( .lock()
    , .clkout0(serial_clk)
    , .clkin(ref_clk)
    , .reset(~rst_n)
    );

    pixel_clkdiv u_pixel_clkdiv
    ( .clkout(pixel_clk)
    , .hclkin(serial_clk)
    , .resetn(rst_n)
    );

    hvtx_cursor #
    ( .WIDTH(WIDTH)
    , .FRAME_WIDTH(1650)
    , .FRAME_HEIGHT(750)
    ) u_cursor
    ( .i_clk(pixel_clk)
    , .i_rst(~rst_n)
    , .o_x(x)
    , .o_y(y)
    );

    hvtx_sync #
    ( .WIDTH(WIDTH)
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
    , .i_x(x)
    , .i_y(y)
    , .o_hs(hs)
    , .o_vs(vs)
    , .o_de(de)
    );

    hvtx_mod u_mod
    ( .i_pixel_clk(pixel_clk)
    , .i_serial_clk(serial_clk)
    , .i_rst(~rst_n)
    , .i_hs(hs)
    , .i_vs(vs)
    , .i_de(de)
    , .i_video(video)
    , .o_chan_vec(chan_vec)
    );

    hvtx_ser u_ser_a
    ( .i_pixel_clk(pixel_clk)
    , .i_serial_clk(serial_clk)
    , .i_rst(~rst_n)
    , .i_chan_vec(chan_vec)
    , .o_hdmi_clk_p(hdmi_clk_p_a)
    , .o_hdmi_clk_n(hdmi_clk_n_a)
    , .o_hdmi_chan_p(hdmi_chan_p_a)
    , .o_hdmi_chan_n(hdmi_chan_n_a)
    );

    hvtx_ser u_ser_b
    ( .i_pixel_clk(pixel_clk)
    , .i_serial_clk(serial_clk)
    , .i_rst(~rst_n)
    , .i_chan_vec(chan_vec)
    , .o_hdmi_clk_p(hdmi_clk_p_b)
    , .o_hdmi_clk_n(hdmi_clk_n_b)
    , .o_hdmi_chan_p(hdmi_chan_p_b)
    , .o_hdmi_chan_n(hdmi_chan_n_b)
    );

endmodule : top
