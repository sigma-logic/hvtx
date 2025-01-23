// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"
`include "h14tx/macros.svh"

module h14tx_timings_sync
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter `VEC(BitWidth) HSyncStart = BitWidth'(1280 + 110),
    parameter `VEC(BitWidth) HSyncEnd = BitWidth'(1280 + 110 + 40),
    parameter `VEC(BitHeight) VSyncStart = BitHeight'(720 + 5),
    parameter `VEC(BitHeight) VSyncEnd = BitHeight'(720 + 5 + 5)
)
(
    input `VEC(BitWidth) x,
    input `VEC(BitHeight) y,
    output logic hsync,
    output logic vsync
);

    always_comb begin
        hsync = x >= HSyncStart && x < HSyncEnd;

        if (y == VSyncStart) begin
            vsync = x >= HSyncStart;
        end
        else if (y == VSyncEnd - BitWidth'(1)) begin
            vsync = x < HSyncStart;
        end
        else begin
            vsync = y >= VSyncStart && y < VSyncEnd;
        end
    end

endmodule : h14tx_timings_sync
