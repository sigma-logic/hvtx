// Copyright (c) 2025 Sigma Logic

module h14tx_timings_data
    import h14tx_pkg::period_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::DataIslandPreamble;
    import h14tx_pkg::DataIslandGuard;
    import h14tx_pkg::DataIslandActive;
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter logic [BitWidth-1:0] FrameWidth = BitWidth'(1650),
    parameter logic [BitWidth-1:0] ActiveWidth = BitWidth'(1280)
) (
    input logic [BitWidth-1:0] x,
    input logic [BitHeight-1:0] y,

    output period_t timings
);

    localparam logic [10:0] HardLimit = 10'd18;

    localparam logic [10:0] PacketsFit =
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

    localparam logic [10:0] MaxPackets = PacketsFit > HardLimit ? HardLimit : PacketsFit;
    localparam logic [10:0] MaxPacketsClocks = MaxPackets * 32;

    localparam logic [BitWidth-1:0] PreambleStart = ActiveWidth + 4;
    localparam logic [BitWidth-1:0] LeadingGuardStart = ActiveWidth + 4 + 8;
    localparam logic [BitWidth-1:0] ActiveStart = ActiveWidth + 4 + 8 + 2;
    localparam logic [BitWidth-1:0] TrailingGuardStart = ActiveWidth + MaxPacketsClocks;
    localparam logic [BitWidth-1:0] TrailingGuardEnd = TrailingGuardStart + 2;

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
