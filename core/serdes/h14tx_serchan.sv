// Copyright (c) 2025 Sigma Logic

module h14tx_serchan
    import h14tx_pkg::symbol_t;
    import h14tx_pkg::diff_t;
(
    input logic pixel_clk,
    input logic serial_clk,
    input logic rst_n,

    input symbol_t symbol,

    output diff_t pair
);

    logic serialized_chan;

    OSER10 tmds_serde (
        .Q(serialized_chan),
        .D0(symbol[0]),
        .D1(symbol[1]),
        .D2(symbol[2]),
        .D3(symbol[3]),
        .D4(symbol[4]),
        .D5(symbol[5]),
        .D6(symbol[6]),
        .D7(symbol[7]),
        .D8(symbol[8]),
        .D9(symbol[9]),
        .PCLK(pixel_clk),
        .FCLK(serial_clk),
        .RESET(~rst_n)
    );

    ELVDS_OBUF tmds_obuf (
        .I (serialized_chan),
        .O (pair.p),
        .OB(pair.n)
    );

endmodule : h14tx_serchan
