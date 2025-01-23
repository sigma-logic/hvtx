`timescale 1ps/1ps

`include "h14tx/macros.svh"
`include "h14tx/cea861d.svh"

module tb_timings
    import h14tx_pkg::period_t;
;

    logic clk, rst_n;

    localparam integer VideoMode = 4;
    localparam integer BitWidth = `CEA861D_BIT_WIDTH(VideoMode);
    localparam integer BitHeight = `CEA861D_BIT_HEIGHT(VideoMode);

    `VEC(BitWidth) x;
    `VEC(BitHeight) y;

    logic hsync, vsync;
    period_t period;

    clk_rst_gen u_clk_rst_gen (
        .clk(clk),
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
        #1237500

        // Wait extra ticks
        #1000

        $finish;
    end

endmodule : tb_timings
