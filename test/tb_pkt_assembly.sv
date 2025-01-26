`timescale 1ns/1ps

module tb_pkt_assembly;

    logic rst_n, clk;

    clk_rst_gen #(0.5) u_clk_rst_gen (
        .clk  (clk),
        .rst_n(rst_n)
    );

    logic [23:0] header;
    logic [55:0] sub[3:0];

    h14tx_pkt_avi_info_frame u_avi_info_frame_pkt (
        .header(header),
        .sub(sub)
    );

    logic [4:0] counter;
    logic [8:0] chunk;

    h14tx_packet_assembler u_pkt_assembler (
        .clk(clk),
        .rst_n(rst_n),
        .active(1'b1),
        .header(header),
        .sub(sub),
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

