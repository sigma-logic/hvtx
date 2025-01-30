// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_encoding_ctl
    import h14tx_pkg::ctl_t;
    import h14tx_pkg::symbol_t;
(
    input ctl_t ctl,

    output symbol_t symbol /*synthesis syn_keep=1*/
);

    always_comb
        unique case (ctl)
            2'b00: symbol = 10'b1101010100;
            2'b01: symbol = 10'b0010101011;
            2'b10: symbol = 10'b0101010100;
            2'b11: symbol = 10'b1010101011;
        endcase

endmodule : h14tx_encoding_ctl
