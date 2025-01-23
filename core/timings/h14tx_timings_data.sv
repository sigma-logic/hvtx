// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"
`include "h14tx/macros.svh"

module h14tx_timings_data
    import h14tx_pkg::period_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::DataIslandPreamble;
    import h14tx_pkg::DataIslandGuard;
    import h14tx_pkg::DataIslandActive;
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter `VEC(BitWidth) FrameWidth = BitWidth'(1650),
    parameter `VEC(BitWidth) ActiveWidth = BitWidth'(1280)
) (
    input `VEC(BitWidth) x,
    input `VEC(BitHeight) y,

    output period_t timings
);

    localparam `VEC(10) HardLimit = 10'd18;

    localparam `VEC(10) PacketsFit =
        (FrameWidth
            - ActiveWidth // VD period
            - 2 // V guard
            - 8 // V preamble
            - 4 // Min V control period
            - 2 // DI trailing guard
            - 2 // DI leading guard
            - 8 // DI premable
            - 4 // Min DI control period
        ) / 32;

    localparam `VEC(10) MaxPackets = PacketsFit > HardLimit ? HardLimit : PacketsFit;
    localparam `VEC(10) MaxPacketsClocks = MaxPackets * 32;

    localparam `VEC(BitWidth) PreambleStart = ActiveWidth + 4;
    localparam `VEC(BitWidth) LeadingGuardStart = ActiveWidth + 4 + 8;
    localparam `VEC(BitWidth) ActiveStart = ActiveWidth + 4 + 8 + 2;
    localparam `VEC(BitWidth) TrailingGuardStart = ActiveWidth + MaxPacketsClocks;
    localparam `VEC(BitWidth) TrailingGuardEnd = TrailingGuardStart + 2;

    always_comb begin
        if (x >= PreambleStart && x < LeadingGuardStart) begin
            timings = DataIslandPreamble;
        end
        else if (
            (x >= LeadingGuardStart && x < ActiveStart) ||
            (x >= TrailingGuardStart && x < TrailingGuardEnd)
        ) begin
            timings = DataIslandGuard;
        end
        else if (x >= ActiveStart && x < TrailingGuardStart) begin
            timings = DataIslandActive;
        end
        else begin
            timings = Control;
        end
    end

endmodule : h14tx_timings_data
