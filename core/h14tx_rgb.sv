// Copyright (c) 2025 Sigma Logic

module h14tx_rgb
    import h14tx_pkg::timings_cfg_t;
    import h14tx_pkg::tmds_t;
    import h14tx_pkg::period_t;
    import h14tx_pkg::VideoPreamble;
#(
    parameter timings_cfg_t TimingsCfg = '{11, 10, 1650, 750, 1280, 720, 110, 40, 5, 5, 1'b0}
) (
    input logic pixel_clk,
    input logic serial_clk,
    input logic rst_n,

    input logic [2:0][7:0] rgb,

    output logic [ TimingsCfg.bit_width-1:0] x,
    output logic [TimingsCfg.bit_height-1:0] y,

    output tmds_t tmds
);

    logic hsync, vsync;

    period_t period;

    h14tx_timings #(TimingsCfg) u_timings (
        .clk(pixel_clk),
        .rst_n(rst_n),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .period(period)
    );

    logic [2:0][1:0] ctl;

    assign ctl[0] = {vsync, hsync};
    assign ctl[2:1] = period == VideoPreamble ? 4'b0001 : 4'b0000;

    logic [2:0][9:0] chan;

    generate
        for (genvar i = 0; i < 3; i++) begin : gen_channel
            h14tx_channel #(i) u_channel (
                .clk(pixel_clk),
                .rst_n(rst_n),
                .period(period),
                .ctl(ctl[i]),
                .video(rgb[i]),
                .symbol(chan[i])
            );
        end
    endgenerate

    h14tx_serdes u_serdes (
        .serial_clk(serial_clk),
        .pixel_clk(pixel_clk),
        .rst(~rst_n),
        .chan(chan),
        .tmds(tmds)
    );

endmodule : h14tx_rgb
