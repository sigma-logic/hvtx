`timescale 1ps/1ps

module clk_rst_gen (
    output logic clk,
    output logic rst_n
);

    initial begin
        clk = 0'b0;
        rst_n = 1'b0;
        #1
        rst_n = 1'b1;

        clk = 1'b1;

        forever clk = #1 ~clk;
    end

endmodule : clk_rst_gen
