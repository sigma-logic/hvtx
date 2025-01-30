// Copyright (c) 2025 Sigma Logic

`include "h14tx/cea861d.svh"

module top_dvo
    import h14tx_pkg::cea861d_config_t;
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::video_t;
(
    input logic rst_n,
    input logic switch,

    output logic ref_clk_70mhz,

    output logic tmds_clk_p,
    output logic tmds_clk_n,
    output logic [2:0] tmds_chan_p,
    output logic [2:0] tmds_chan_n
);

    OSC #(3) u_osc (.OSCOUT(ref_clk_70mhz));

    logic pll_lock, pixel_clk, serial_clk, sync_rst_n;

    localparam integer Mode = 4;
    localparam cea861d_config_t CeaCfg = `CEA861D_CONFIG(Mode);

    h14tx_pll #(
        .IDivSel (CeaCfg.pll_idiv_sel),
        .ODiv0Sel(CeaCfg.pll_odiv0_sel),
        .ODiv1Sel(CeaCfg.pll_odiv1_sel),
        .MDivSel (CeaCfg.pll_mdiv_sel)
    ) u_pll (
        .ref_clk_70mhz(ref_clk_70mhz),
        .rst_n(rst_n),
        .lock(pll_lock),
        .pixel_clk(pixel_clk),
        .serial_clk(serial_clk)
    );

    h14tx_rst_sync u_rst_sync (
        .clk(pixel_clk),
        .lock(pll_lock),
        .ext_rst_n(rst_n),
        .sync_rst_n(sync_rst_n)
    );

    logic [CeaCfg.bit_width-1:0] x;
    logic [CeaCfg.bit_height-1:0] y;

    video_t [2:0] video /*synthesis syn_keep=1*/;
    assign video = switch ? 24'hFFFFFF : 24'h111111;

    symbol_t [2:0] channels /*synthesis syn_keep=1*/;

    h14tx_dvo #(
        .CeaCfg(CeaCfg)
    ) u_dvo (
        .clk(pixel_clk),
        .rst_n(sync_rst_n),
        .video(video),
        .x(x),
        .y(y),
        .channels(channels)
    );

    h14tx_serdes u_serdes (
        .pixel_clk(pixel_clk),
        .serial_clk(serial_clk),
        .rst_n(rst_n),
        .channels(channels),
        .hdmi_out(
        '{
            '{tmds_clk_p, tmds_clk_n},
            '{
                '{tmds_chan_p[2], tmds_chan_n[2]},
                '{tmds_chan_p[1], tmds_chan_n[1]},
                '{tmds_chan_p[0], tmds_chan_n[0]}
            }
        }
        )
    );

endmodule : top_dvo

