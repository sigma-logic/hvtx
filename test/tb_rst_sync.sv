`timescale 1ns/1ps

module tb_rst_sync;

    logic rst_n, clk, sync_rst_n, lock;

    clk_rst_gen #(0.5) u_clk_rst_gen (
        .clk(clk),
        .rst_n(rst_n)
    );

    h14tx_rst_sync u_rst_sync (
        .clk(clk),
        .lock(lock),
        .ext_rst_n(rst_n),
        .sync_rst_n(sync_rst_n)
    );

    initial begin
        $dumpfile("wave.fst");
        $dumpvars;

        lock = 1'b0;
        #4
        lock = 1'b1;
        #20
        rst_n = 1'b0;
        #1
        rst_n = 1'b1;
        #4
        rst_n = 1'b0;
        #0.01
        rst_n = 1'b1;
        #4
        lock = 1'b0;
        #0.5
        lock = 1'b1;
        #20
    
        $finish;
    end

endmodule : tb_rst_sync;
