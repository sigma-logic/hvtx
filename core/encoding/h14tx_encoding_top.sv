// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_encoding_top
    import h14tx_pkg::period_t;
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::ctl_t;
    import h14tx_pkg::data_t;
    import h14tx_pkg::video_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
    import h14tx_pkg::DataIslandActive;
    import h14tx_pkg::DataIslandPreamble;
    import h14tx_pkg::DataIslandGuard;
#(
    parameter integer Chan = 0
) (
    input logic clk,
    input logic rst_n,

    input ctl_t   ctl,
    input data_t  data,
    input video_t video,

    input period_t period,

    output symbol_t symbol
);

    symbol_t ctl_s, data_s, video_s, guard_s;

    h14tx_encoding_ctl u_ctl_enc (
        .ctl(ctl),
        .symbol(ctl_s)
    );

    h14tx_encoding_terc4 u_terc4_enc (
        .data  (data),
        .symbol(data_s)
    );

    h14tx_encoding_tmds u_tmds_enc (
        .clk(clk),
        .rst_n(rst_n && period == VideoActive),
        .video(video),
        .symbol(video_s)
    );

    h14tx_encoding_guard #(
        .Chan(Chan)
    ) u_gaurd_enc (
        .guard_switch(period == DataIslandGuard),
        .bypass_symbol(data_s),
        .symbol(guard_s)
    );

    symbol_t symbol_sel;

    always_comb begin
        unique case (period)
            Control: symbol_sel = ctl_s;
            VideoPreamble: symbol_sel = ctl_s;
            DataIslandPreamble: symbol_sel = ctl_s;
            VideoGuard: symbol_sel = guard_s;
            DataIslandGuard: symbol_sel = guard_s;
            VideoActive: symbol_sel = video_s;
            DataIslandActive: symbol_sel = data_s;
        endcase
    end

    `FFNR(symbol, symbol_sel)

endmodule : h14tx_encoding_top
