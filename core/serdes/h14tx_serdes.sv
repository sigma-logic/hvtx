// Copyright (c) 2025 Sigma Logic

module h14tx_serdes
    import h14tx_pkg::hdmi_tmds_t;
    import h14tx_pkg::diff_t;
    import h14tx_pkg::symbol_t;
(
    input logic pixel_clk,
    input logic serial_clk,
    input logic rst_n,

    input symbol_t [2:0] channels,

    output hdmi_tmds_t hdmi_out
);

    generate
        for (genvar chan = 0; chan < 3; chan = chan + 1) begin : gen_serchan
            h14tx_serchan u_serchan (
                .pixel_clk(pixel_clk),
                .serial_clk(serial_clk),
                .rst_n(rst_n),
                .symbol(channels[chan]),
                .pair(hdmi_out.chan[chan])
            );
        end
    endgenerate

    ELVDS_OBUF u_clk_obuf (
        .I (serial_clk),
        .O (hdmi_out.clk.p),
        .OB(hdmi_out.clk.n)
    );

endmodule : h14tx_serdes

