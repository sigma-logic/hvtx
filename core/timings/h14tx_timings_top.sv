// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"
`include "h14tx/macros.svh"

module h14tx_timings_top
    import h14tx_pkg::period_t;
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter `VEC(BitWidth) FrameWidth = 1650,
    parameter `VEC(BitHeight) FrameHeight = 750,
    parameter `VEC(BitWidth) ActiveWidth = 1280,
    parameter `VEC(BitHeight) ActiveHeight = 720,
    parameter `VEC(BitWidth) HFrontPorch = 110,
    parameter `VEC(BitHeight) HSyncWidth = 40,
    parameter `VEC(BitWidth) VFrontPorch = 5,
    parameter `VEC(BitHeight) VSyncWidth = 5,
    parameter logic InvertPolarity = 1'b0
) (
    input logic clk,
    input logic rst_n,

    output `VEC(BitWidth) x,
    output `VEC(BitHeight) y,

    output logic hsync,
    output logic vsync,
    output period_t period
);

    period_t video_period;
    period_t data_period;

    h14tx_timings_cursor #(
        .BitWidth(BitWidth),
        .BitHeight(BitHeight),
        .Width(FrameWidth),
        .Height(FrameHeight)
    ) u_cursor (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .y(y)
    );

    h14tx_timings_sync #(
        .BitWidth(BitWidth),
        .BitHeight(BitHeight),
        .HSyncStart(ActiveWidth + HFrontPorch),
        .HSyncEnd(ActiveWidth + HFrontPorch + HSyncWidth),
        .VSyncStart(ActiveHeight + VFrontPorch),
        .VSyncEnd(ActiveHeight + VFrontPorch + VSyncWidth)
    ) u_sync_timings (
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync)
    );

    h14tx_timings_video #(
        .BitWidth(BitWidth),
        .BitHeight(BitHeight),
        .FrameWidth(FrameWidth),
        .FrameHeight(FrameHeight),
        .ActiveWidth(ActiveWidth),
        .ActiveHeight(ActiveHeight)
    ) u_video_timings (
        .x(x),
        .y(y),
        .timings(video_period)
    );

    h14tx_timings_data #(
        .BitWidth(BitWidth),
        .BitHeight(BitHeight),
        .FrameWidth(FrameWidth),
        .ActiveWidth(ActiveWidth)
    ) u_data_timings (
        .x(x),
        .y(y),
        .timings(data_period)
    );

    assign period = period_t'(video_period + data_period);

endmodule : h14tx_timings_top
