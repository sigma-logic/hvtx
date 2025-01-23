`include "h14tx/registers.svh"
`include "h14tx/macros.svh"

module h14tx_timings_video
    import h14tx_pkg::period_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter `VEC(BitWidth) FrameWidth = BitWidth'(1650),
    parameter `VEC(BitHeight) FrameHeight = BitHeight'(750),
    parameter `VEC(BitWidth) ActiveWidth = BitWidth'(1280),
    parameter `VEC(BitHeight) ActiveHeight = BitHeight'(720)
) (
    input `VEC(BitWidth) x,
    input `VEC(BitHeight) y,

    output period_t timings
);

    localparam `VEC(BitWidth) GuardStart = FrameWidth - BitWidth'(2);
    localparam `VEC(BitWidth) PreambleStart = FrameWidth - GuardStart - BitWidth'(8);

    logic guarding_line;

    assign guarding_line = y < ActiveHeight - BitHeight'(1) || y == FrameHeight - BitHeight'(1);

    always_comb begin
        if (x < ActiveWidth && y < ActiveHeight) begin
            timings = VideoActive;
        end
        else if (guarding_line && x >= PreambleStart && x < GuardStart) begin
            timings = VideoPreamble;
        end
        else if (guarding_line && x >= PreambleStart && x < ActiveWidth) begin
            timings = VideoGuard;
        end
        else begin
            timings = Control;
        end
    end

endmodule : h14tx_timings_video
