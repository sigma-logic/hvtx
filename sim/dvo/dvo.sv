`include "h14tx/cea861d.svh"
`include "h14tx/macros.svh"

module dvo
    import h14tx_pkg::period_t;
();

    logic ref_clk, rst_n, lock;

    OSC #(.FREQ_DIV(3)) osc (.OSCOUT(ref_clk));

    localparam integer VideoMode = 4;
    localparam integer BitWidth = `CEA861D_BIT_WIDTH(VideoMode);
    localparam integer BitHeight = `CEA861D_BIT_HEIGHT(VideoMode);

    logic serial_clk, pixel_clk, timings_rst_n;

    h14tx_pll #(`CEA861D_PLL(VideoMode)) pll (
        .rst_n(rst_n),
        .ref_clk(ref_clk),
        .lock(lock),
        .pixel_clk(pixel_clk),
        .serial_clk(serial_clk),
        .timings_rst_n(timings_rst_n)
    );

    `VEC(BitWidth) x;
    `VEC(BitHeight) y;
    logic hsync, vsync;
    period_t period;

    h14tx_timings_top #(`CEA861D_TIMINGS(VideoMode)) timings_inst (
        .clk(pixel_clk),
        .rst_n(timings_rst_n),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .period(period)
    );

    initial begin
        $dumpfile("sim.fst");
        $dumpvars;

        rst_n = 1'b0;
        #1
        rst_n = 1'b1;

        @(posedge lock);
        $display("PLL locked");

        @(posedge hsync);
        $display("HSync reached");

        $finish;
    end

endmodule : dvo
