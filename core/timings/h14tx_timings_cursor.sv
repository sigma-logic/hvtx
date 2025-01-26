// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_timings_cursor
#(
    parameter integer BitWidth = 11,
    parameter integer BitHeight = 10,
    parameter logic [BitWidth-1:0] Width = BitWidth'(1650),
    parameter logic [BitHeight-1:0] Height = BitHeight'(720)
)
(
    input logic clk,
    input logic rst_n,
    output logic [BitWidth-1:0] x,
    output logic [BitHeight-1:0] y
);

    localparam logic [BitWidth-1:0] HLimit = BitWidth'(Width - 1);
    localparam logic [BitHeight-1:0] VLimit = BitHeight'(Height - 1);

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
