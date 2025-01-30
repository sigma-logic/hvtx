// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_encoding_guard
    import h14tx_pkg::symbol_t;
#(
    parameter logic [1:0] Chan = 0
) (
    input symbol_t bypass_symbol,
    input logic guard_switch,

    output symbol_t symbol /*synthesis syn_keep=1*/
);

    localparam symbol_t Unknown = 10'bzzzzzzzzzz;

    generate
        if (Chan == 2'd0) begin : gen_vguard_chan_0
            assign symbol = guard_switch ? bypass_symbol : 10'b1011001100;
        end else if (Chan == 2'd1) begin : gen_vguard_chan_1
            assign symbol = 10'b0100110011;
        end else if (Chan == 2'd2) begin : gen_vguard_chan_2
            assign symbol = guard_switch ? 10'b0100110011 : 10'b1011001100;
        end else begin : gen_fuard_chan_unknown
            assign symbol = Unknown;
        end
    endgenerate

endmodule : h14tx_encoding_guard
