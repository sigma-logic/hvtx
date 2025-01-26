`timescale 1ns / 1ps

module clk_rst_gen #(
    parameter real Period = 6.734
) (
    output logic clk,
    output logic rst_n
);

    initial begin
        clk   = 0'b0;
        rst_n = 1'b0;
        #1 rst_n = 1'b1;

        clk = 1'b1;

        forever clk = #(Period) ~clk;
    end

endmodule : clk_rst_gen

