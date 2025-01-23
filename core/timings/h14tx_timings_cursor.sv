// Copyright (c) 2025 Sigma Logic

`include "h14tx/macros.svh"
`include "h14tx/registers.svh"

module h14tx_timings_cursor
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter `VEC(BitWidth) Width = BitWidth'(1650),
    parameter `VEC(BitHeight) Height = BitHeight'(720)
)
(
    input logic clk,
    input logic rst_n,
    output `VEC(BitWidth) x,
    output `VEC(BitHeight) y
);

    localparam `VEC(BitWidth) HLimit = BitWidth'(Width - 1);
    localparam `VEC(BitHeight) VLimit = BitHeight'(Height - 1);

    `FFARNC(
        x,
        x + BitWidth'(1),
        x == HLimit,
        0
    )

    `FFARNC(
        y,
        x == HLimit ? y + BitHeight'(1) : y,
        y == VLimit,
        0
    )

endmodule : h14tx_timings_cursor
