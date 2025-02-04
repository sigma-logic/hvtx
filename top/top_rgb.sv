// Copyright (c) 2025 Sigma Logic

module top_rgb
    import h14tx_pkg::timings_cfg_t;
(
    input logic ref_clk,
    input logic rst_n,

    output logic tmds_clk_p,
    output logic tmds_clk_n,
    output logic [2:0] tmds_chan_p,
    output logic [2:0] tmds_chan_n
);

//    OSC #(3) u_osc (ref_clk);

    logic serial_clk, pixel_clk, tmds_rst_n;

    h14tx_clk #(
        .IDiv(1),
        .MDiv(30),
        .ODiv(2)
    ) u_clk (
        .ref_clk(ref_clk),
        .rst_n(rst_n),
        .serial_clk(serial_clk),
        .pixel_clk(pixel_clk),
        .tmds_rst_n(tmds_rst_n)
    );

    logic [2:0][7:0] rgb  /*synthesis syn_keep=1*/;

    localparam timings_cfg_t TimingsCfg = '{12, 11, 2200, 1125, 1920, 1080, 88, 44, 4, 5, 1'b0};

    logic [ TimingsCfg.bit_width-1:0] x;
    logic [TimingsCfg.bit_height-1:0] y;

    logic [20:0] counter;

    assign rgb = {x, y, 3'b0};

    h14tx_rgb #(TimingsCfg) u_rgb (
        .pixel_clk(pixel_clk),
        .serial_clk(serial_clk),
        .rst_n(tmds_rst_n),
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
