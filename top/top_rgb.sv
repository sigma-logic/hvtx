// Copyright (c) 2025 Sigma Logic

module top_rgb
    import simple_pll_pkg::pll_channels_t;
    import h14tx_pkg::timings_cfg_t;
(
    input logic rst_n,

    output logic ref_clk_70mhz,

    output logic tmds_clk_p,
    output logic tmds_clk_n,
    output logic [2:0] tmds_chan_p,
    output logic [2:0] tmds_chan_n
);

    // On-Chip Oscillator 210Mhz / 3 = 70Mhz
    OSC #(3) u_osc (ref_clk_70mhz);

    logic pll_lock;
    pll_channels_t pll;

    logic serial_clk, pixel_clk;
    logic sync_rst_n;

    assign serial_clk = pll.clk_0;
    assign pixel_clk  = pll.clk_1;

    simple_pll #(
        .RefClkMhz("70"),
        .IDiv(2),
        .ODiv0(5),
        .ODiv1(25),
        .MDiv(53),
        .Clk0En(1'b1),
        .Clk1En(1'b1)
    ) u_pll (
        .ref_clk(ref_clk_70mhz),
        .rst(~rst_n),
        .lock(pll_lock),

        .channels(pll)
    );

    h14tx_reset_sync u_reset_sync (
        .clk(pixel_clk),
        .ext_rst_n(rst_n),
        .lock(pll_lock),
        .sync_rst_n(sync_rst_n)
    );

    logic [2:0][7:0] rgb  /*synthesis syn_keep=1*/;
    assign rgb = 24'hFFFFFF;

    localparam timings_cfg_t TimingsCfg = '{11, 10, 1650, 750, 1280, 720, 110, 40, 5, 5, 1'b0};

    logic [ TimingsCfg.bit_width-1:0] x;
    logic [TimingsCfg.bit_height-1:0] y;

    h14tx_rgb #(TimingsCfg) u_rgb (
        .pixel_clk(pixel_clk),
        .serial_clk(serial_clk),
        .rst_n(sync_rst_n),
        .rgb(rgb),
        .x(x),
        .y(y),
        .tmds(
        '{
            '{tmds_clk_p, tmds_clk_n},
            {
                '{tmds_chan_p[2], tmds_chan_n[2]},
                '{tmds_chan_p[1], tmds_chan_n[1]},
                '{tmds_chan_p[0], tmds_chan_n[0]}
            }
        }
        )
    );

endmodule : top_rgb
