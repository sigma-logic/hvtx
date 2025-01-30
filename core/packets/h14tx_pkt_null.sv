module h14tx_pkt_null
    import h14tx_pkg::packet_t;
(
    output packet_t packet /*synthesis syn_keep=1*/
);

    assign packet.header = 24'b0;
    assign packet.sub = {56'h0, 56'h0, 56'h0, 56'h0};

endmodule : h14tx_pkt_null
