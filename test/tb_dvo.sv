`timescale 1ns / 1ps

`include "h14tx/cea861d.svh"

module tb_dvo
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::video_t;
    import h14tx_pkg::cea861d_config_t;
;

    logic clk, rst_n;

    clk_rst_gen #(0.5) u_clk_rst_gen (
        .clk  (clk),
        .rst_n(rst_n)
    );

    localparam integer Mode = 4;
    localparam cea861d_config_t CeaCfg = `CEA861D_CONFIG(Mode);

    video_t [2:0] video;
    assign video = {8'hFF, 8'hFF, 8'hFF};

    logic [CeaCfg.bit_width-1:0] x;
    logic [CeaCfg.bit_height-1:0] y;

    symbol_t [2:0] channels;

    h14tx_dvo #(.CeaCfg(CeaCfg)) u_dvo (
        .clk(clk),
        .rst_n(rst_n),
        .video(video),
        .x(x),
        .y(y),
        .channels(channels)
    );

    initial begin
        $dumpfile("wave.fst");
        $dumpvars;

        #1237510

        $finish;
    end

endmodule : tb_dvo

