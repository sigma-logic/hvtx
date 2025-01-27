// Copyright (c) 2025 Sigma Logic
// TODO: replace by Gowin's BCH

// Implementation of HDMI packet ECC calculation.
// By Sameer Puri https://github.com/sameer

`include "h14tx/registers.svh"

module h14tx_packet_assembler
    import h14tx_pkg::packet_t;
(
    input logic clk,
    input logic rst_n,
    input logic active,

    input packet_t packet,

    output logic [8:0] chunk,  // See Figure 5-4 Data Island Packet and ECC Structure
    output logic [4:0] counter = 5'd0
);

    `FFL(counter, counter + 5'd1, active, 0)

    // BCH packets 0 to 3 are transferred two bits at a time, see Section 5.2.3.4 for further information.
    logic [5:0] counter_t2 = {counter, 1'b0};
    logic [5:0] counter_t2_p1 = {counter, 1'b1};

    // Initialize parity bits to 0
    logic [7:0] parity[4:0] = '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0};

    logic [63:0] bch[3:0];
    assign bch[0] = {parity[0], packet.sub[0]};
    assign bch[1] = {parity[1], packet.sub[1]};
    assign bch[2] = {parity[2], packet.sub[2]};
    assign bch[3] = {parity[3], packet.sub[3]};
    logic [31:0] bch4 = {parity[4], packet.header};
//    assign chunk = {
//        bch[3][counter_t2_p1],
//        bch[2][counter_t2_p1],
//        bch[1][counter_t2_p1],
//        bch[0][counter_t2_p1],
//        bch[3][counter_t2],
//        bch[2][counter_t2],
//        bch[1][counter_t2],
//        bch[0][counter_t2],
//        bch4[counter]
//    };

    // See Figure 5-5 Error Correction Code generator. Generalization of a CRC with binary BCH.
    // See https://web.archive.org/web/20190520020602/http://hamsterworks.co.nz/mediawiki/index.php/Minimal_HDMI#Computing_the_ECC for an explanation of the implementation.
    // See https://en.wikipedia.org/wiki/BCH_code#Systematic_encoding:_The_message_as_a_prefix for further information.
    function automatic [7:0] next_ecc(input [7:0] ecc, logic next_bch_bit);
        begin
            next_ecc = (ecc >> 1) ^ ((ecc[0] ^ next_bch_bit) ? 8'b10000011 : 8'd0);
        end
    endfunction

    logic [7:0] parity_next[4:0];

    // The parity needs to be calculated 2 bits at a time for blocks 0 to 3.
    // There's 56 bits being sent 2 bits at a time over TMDS channels 1 & 2, so the parity bits wouldn't be ready in time otherwise.
    logic [7:0] parity_next_next[3:0];

    generate
        for (genvar i = 0; i < 5; i++) begin : parity_calc
            if (i == 4) begin
                assign parity_next[i] = next_ecc(parity[i], packet.header[counter]);
            end else begin
                assign parity_next[i] = next_ecc(parity[i], packet.sub[i][counter_t2]);
                assign parity_next_next[i] = next_ecc(parity_next[i], packet.sub[i][counter_t2_p1]);
            end
        end
    endgenerate

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parity <= '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        end else if (active) begin
            // Compute ECC only on subpacket data, not on itself
            if (counter < 5'd28) begin
                parity[3:0] <= parity_next_next;

                // Header only has 24 bits, whereas subpackets have 56 and 56 / 2 = 28.
                if (counter < 5'd24) begin
                    parity[4] <= parity_next[4];
                end
            end else if (counter == 5'd31) begin
                parity <= '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0};  // Reset ECC for next packet
            end
        end else begin
            parity <= '{8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        end
    end

    always_ff @(posedge clk) begin
        chunk <= {
            bch[3][counter_t2_p1],
            bch[2][counter_t2_p1],
            bch[1][counter_t2_p1],
            bch[0][counter_t2_p1],
            bch[3][counter_t2],
            bch[2][counter_t2],
            bch[1][counter_t2],
            bch[0][counter_t2],
            bch4[counter]
        };
    end

endmodule

