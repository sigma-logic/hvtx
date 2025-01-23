`timescale 1ps/1ps

`include "h14tx/macros.svh"
`include "h14tx/cea861d.svh"

module tb_encoding
    import h14tx_pkg::period_t;
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::ctl_t;
    import h14tx_pkg::data_t;
    import h14tx_pkg::video_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
    import h14tx_pkg::DataIslandActive;
    import h14tx_pkg::DataIslandPreamble;
    import h14tx_pkg::DataIslandGuard;
;

    logic clk, rst_n;

    clk_rst_gen u_clk_rst_gen (
        .clk(clk),
        .rst_n(rst_n)
    );

    ctl_t ctl [3];
    data_t data [3];
    video_t video [3];

    period_t period;

    symbol_t symbol;

    generate
        for (genvar i = 0; i < 3; i = i + 1) begin : gen_uut
            h14tx_encoding_top #(
                .Chan(i)
            ) u_encoding (
                .clk(clk),
                .rst_n(rst_n),
                .ctl(ctl[i]),
                .data(data[i]),
                .video(video[i]),
                .period(period),
                .symbol(symbol)
            );
        end
    endgenerate

    initial begin
        $dumpfile("wave.fst");
        $dumpvars;

        ctl = {2'b0, 2'b0, 2'b0};
        data = {4'b0, 4'b0, 4'b0};
        video = {8'b0, 8'b0, 8'b0};
        period = Control;

        #1

        #2 ctl = {2'b10, 2'b0, 2'b0};
        #2 ctl = {2'b01, 2'b01, 2'b0};
        #2 ctl = {2'b0, 2'b0, 2'b0};

        period = DataIslandPreamble; #2
        period = DataIslandGuard; #2
        period = DataIslandActive; #2

        #2 data = {4'b0111, 4'b0, 4'b0};
        #2 data = {4'b1101, 4'b1000, 4'b0001};

        period = VideoPreamble; #2
        period = VideoGuard; #2
        period = VideoActive; #2

        #2 video = {8'hFF, 8'hFF, 8'hFF};
        #2 video = {8'h00, 8'hFF, 8'hFF};
        #2 video = {8'hFF, 8'h00, 8'hFF};
        #2 video = {8'hFF, 8'hFF, 8'h00};
        #2 video = {8'hFF, 8'h00, 8'h00};
        #2 video = {8'h00, 8'hFF, 8'h00};
        #2 video = {8'h00, 8'h00, 8'hFF};
        #2 video = {8'h00, 8'h00, 8'h00};

        period = VideoActive; #2

        $finish;
    end

endmodule : tb_encoding
