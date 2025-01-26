`timescale 1ns / 1ps

`include "h14tx/cea861d.svh"

module tb_timings
    import h14tx_pkg::period_t;
    import h14tx_pkg::cea861d_config_t;
;

    logic clk, rst_n;

    localparam integer VideoMode = 4;
    localparam cea861d_config_t CeaCfg = `CEA861D_CONFIG(VideoMode);

    logic [ CeaCfg.bit_width-1:0] x;
    logic [CeaCfg.bit_height-1:0] y;

    logic hsync, vsync;
    period_t period;

    clk_rst_gen u_clk_rst_gen (
        .clk  (clk),
        .rst_n(rst_n)
    );

    h14tx_timings_top u_timings (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .period(period)
    );

    initial begin
        $dumpfile("wave.fst");
        $dumpvars;

        // Wait until frame end
        #16666667

        // Wait extra ticks
        #1000

        $finish;
    end

endmodule : tb_timings
