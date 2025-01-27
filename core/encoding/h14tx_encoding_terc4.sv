// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_encoding_terc4
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::data_t;
(
    input logic clk,
    input data_t data,

    output symbol_t symbol
);

    symbol_t s;

    always_comb begin
        unique case (data)
            4'b0000: s = 10'b1010011100;
            4'b0001: s = 10'b1001100011;
            4'b0010: s = 10'b1011100100;
            4'b0011: s = 10'b1011100010;
            4'b0100: s = 10'b0101110001;
            4'b0101: s = 10'b0100011110;
            4'b0110: s = 10'b0110001110;
            4'b0111: s = 10'b0100111100;
            4'b1000: s = 10'b1011001100;
            4'b1001: s = 10'b0100111001;
            4'b1010: s = 10'b0110011100;
            4'b1011: s = 10'b1011000110;
            4'b1100: s = 10'b1010001110;
            4'b1101: s = 10'b1001110001;
            4'b1110: s = 10'b0101100011;
            4'b1111: s = 10'b1011000011;
        endcase
    end

    `FFNR(symbol, s)

endmodule : h14tx_encoding_terc4

