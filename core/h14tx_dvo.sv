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
    import h14tx_pkg::packet_t;
#(
    parameter integer Mode = 4,
    parameter cea861d_config_t CeaCfg = `CEA861D_CONFIG(Mode)
) (
    input logic clk,
    input logic rst_n,

    input video_t [2:0] video,

    output logic [ CeaCfg.bit_width-1:0] x,
    output logic [CeaCfg.bit_height-1:0] y,

    output symbol_t [2:0] channels
);

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
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .period(period)
    );

    packet_t packet;

    h14tx_pkt_avi_info_frame u_avi_info_frame_pkt (.clk(clk), .packet(packet));

    logic [8:0] chunk;
    logic [4:0] counter;

    h14tx_packet_assembler u_pkt_assembler (
        .clk(clk),
        .rst_n(rst_n),
        .active(period == DataIslandActive),
        .packet(packet),
        .counter(counter),
        .chunk(chunk)
    );

    ctl_t  [2:0] ctl;
    data_t [2:0] data;

    assign ctl[0] = {hsync, vsync};
    assign data = {chunk[8:5], chunk[4:1], hsync, vsync, x != 0, chunk[0]};

    always_comb begin
        if (period == VideoPreamble) begin
            ctl[2:1] = 4'b0001;
        end else if (period == DataIslandPreamble) begin
            ctl[2:1] = 4'b0101;
        end else begin
            ctl[2:1] = 4'b0000;
        end
    end

    generate
        for (genvar i = 0; i < 3; i = i + 1) begin : gen_chan
            h14tx_encoding_top #(i) u_encoder (
                .clk(clk),
                .rst_n(rst_n),
                .ctl(ctl[i]),
                .data(data[i]),
                .video(video[i]),
                .period(period),
                .symbol(channels[i])
            );
        end
    endgenerate
endmodule : h14tx_dvo

