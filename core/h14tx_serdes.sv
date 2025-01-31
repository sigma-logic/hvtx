// Copyright (c) 2025 Sigma Logic

module h14tx_serdes
    import h14tx_pkg::tmds_t;
#(
    parameter string LvdsMode = "True"
) (
    input logic serial_clk,
    input logic pixel_clk,
    input logic rst,

    input logic [2:0][9:0] chan,

    output tmds_t tmds
);

    generate
        for (genvar i = 0; i < 3; i++) begin : gen_oser10
            logic serialized_chan;

            OSER10 u_chan_serde (
                .Q(serialized_chan),
                .D0(chan[i][0]),
                .D1(chan[i][1]),
                .D2(chan[i][2]),
                .D3(chan[i][3]),
                .D4(chan[i][4]),
                .D5(chan[i][5]),
                .D6(chan[i][6]),
                .D7(chan[i][7]),
                .D8(chan[i][8]),
                .D9(chan[i][9]),
                .PCLK(pixel_clk),
                .FCLK(serial_clk),
                .RESET(rst)
            );

            lvds_out #(LvdsMode) u_chan_lvds_out (
                .single(serialized_chan),
                .pair  (tmds.chan[i])
            );
        end
    endgenerate

    logic serialized_clk;

    OSER10 u_clk_serde (
        .Q(serialized_clk),
        .D0(1'b1),
        .D1(1'b1),
        .D2(1'b1),
        .D3(1'b1),
        .D4(1'b1),
        .D5(1'b0),
        .D6(1'b0),
        .D7(1'b0),
        .D8(1'b0),
        .D9(1'b0),
        .PCLK(pixel_clk),
        .FCLK(serial_clk),
        .RESET(rst)
    );

    lvds_out #(LvdsMode) u_clk_lvds_out (
        .single(serialized_clk),
        .pair  (tmds.clk)
    );

endmodule : h14tx_serdes
