`timescale 1ns/1ps

module tb_pkt_assembly
    import h14tx_pkg::packet_t;
;

    logic rst_n, clk;

    clk_rst_gen #(0.5) u_clk_rst_gen (
        .clk  (clk),
        .rst_n(rst_n)
    );

    packet_t packet;

    h14tx_pkt_null u_null_pkt (
        .pkt(packet)
    );

    logic [4:0] counter;
    logic [8:0] chunk;

    h14tx_packet_assembler u_pkt_assembler (
        .clk(clk),
        .rst_n(rst_n),
        .active(1'b1),
        .packet(packet),
        .chunk(chunk),
        .counter(counter)
    );

    initial begin
        $dumpfile("wave.fst");
        $dumpvars;

        #32;

        $finish;
    end

endmodule : tb_pkt_assembly

