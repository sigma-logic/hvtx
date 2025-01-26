// Copyright (c) 2025 Sigma Logic

module h14tx_timings_video
    import h14tx_pkg::period_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter logic [BitWidth-1:0] FrameWidth = BitWidth'(1650),
    parameter logic [BitHeight-1:0] FrameHeight = BitHeight'(750),
    parameter logic [BitWidth-1:0] ActiveWidth = BitWidth'(1280),
    parameter logic [BitHeight-1:0] ActiveHeight = BitHeight'(720)
) (
    input logic [ BitWidth-1:0] x,
    input logic [BitHeight-1:0] y,

    output period_t timings
);

    localparam logic [BitWidth-1:0] GuardStart = FrameWidth - BitWidth'(2);
    localparam logic [BitWidth-1:0] PreambleStart = FrameWidth - BitWidth'(10);

    logic guarding_line;

    assign guarding_line = y < ActiveHeight - BitHeight'(1) || y == FrameHeight - BitHeight'(1);

    always_comb begin
        if (x < ActiveWidth && y < ActiveHeight) begin
            timings = VideoActive;
        end else if (guarding_line && x >= PreambleStart && x < GuardStart) begin
            timings = VideoPreamble;
        end else if (guarding_line && x >= GuardStart && x < FrameWidth) begin
            timings = VideoGuard;
        end else begin
            timings = Control;
        end
    end

endmodule : h14tx_timings_video
