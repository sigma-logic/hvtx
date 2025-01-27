// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_encoding_ctl
    import h14tx_pkg::ctl_t;
    import h14tx_pkg::symbol_t;
(
    input clk,
    input ctl_t ctl,

    output symbol_t symbol
);

    symbol_t s;

    always_comb
        unique case (ctl)
            2'b00: s = 10'b1101010100;
            2'b01: s = 10'b0010101011;
            2'b10: s = 10'b0101010100;
            2'b11: s = 10'b1010101011;
        endcase

    `FFNR(symbol, s)

endmodule : h14tx_encoding_ctl
