// Copyright (c) 2025 Sigma Logic

`include "h14tx/cea861d.svh"

module h14tx_dvo
    import h14tx_pkg::cea861d_config_t;
    import h14tx_pkg::period_t;
    import h14tx_pkg::ctl_t;
    import h14tx_pkg::data_t;
    import h14tx_pkg::video_t;
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
    import h14tx_pkg::DataIslandActive;
    import h14tx_pkg::DataIslandPreamble;
    import h14tx_pkg::DataIslandGuard;

#(
    parameter integer Mode = 4
) (
    input logic clk_70mhz,
    input logic rst_n
);

    localparam cea861d_config_t CeaCfg = `CEA861D_CONFIG(Mode);

    logic lock, pixel_clk, serial_clk;

    h14tx_pll #(
        .IDivSel (CeaCfg.pll_idiv_sel),
        .ODiv0Sel(CeaCfg.pll_odiv0_sel),
        .ODiv1Sel(CeaCfg.pll_odiv1_sel),
        .MDivSel (CeaCfg.pll_mdiv_sel)
    ) u_pll (
        .ref_clk_70mhz(clk_70mhz),
        .rst_n(rst_n),
        .lock(lock),
        .pixel_clk(pixel_clk),
        .serial_clk(serial_clk)
    );

    logic timings_rst_n;

    h14tx_rst_sync u_rst_sync (
        .clk(pixel_clk),
        .lock(lock),
        .ext_rst_n(rst_n),
        .sync_rst_n(timings_rst_n)
    );

    logic [ CeaCfg.bit_width-1:0] x;
    logic [CeaCfg.bit_height-1:0] y;

    logic hsync, vsync;

    period_t period;

    h14tx_timings_top #(
        .BitWidth(CeaCfg.bit_width),
        .BitHeight(CeaCfg.bit_height),
        .FrameWidth(CeaCfg.timings_frame_width),
        .FrameHeight(CeaCfg.timings_frame_height),
        .ActiveWidth(CeaCfg.timings_active_width),
        .ActiveHeight(CeaCfg.timings_active_height),
        .HFrontPorch(CeaCfg.timings_h_front_porch),
        .VFrontPorch(CeaCfg.timings_v_front_porch)
    ) u_timings (
        .clk(pixel_clk),
        .rst_n(timings_rst_n),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .period(period)
    );

    ctl_t   [2:0] ctl;
    data_t  [2:0] data;
    video_t [2:0] video;

    // Setup Control Period
    always_comb begin
        ctl[0] = {hsync, vsync};

        unique case (period)
            VideoPreamble: ctl[1] = 2'b01;
            DataIslandPreamble: begin
                ctl[1] = 2'b01;
                ctl[2] = 2'b01;
            end
            default: begin
                ctl[1] = 2'b00;
                ctl[2] = 2'b00;
            end
        endcase
    end

    generate
        for (genvar i = 0; i < 3; i = i + 1) begin : gen_chan
            symbol_t symbol;

            h14tx_encoding_top #(
                .Chan(i)
            ) u_encoder (
                .clk(pixel_clk),
                .rst_n(timings_rst_n),
                .ctl(ctl[i]),
                .data(data[i]),
                .video(video[i]),
                .period(period),
                .symbol(symbol)
            );
        end
    endgenerate

endmodule : h14tx_dvo

