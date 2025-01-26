module h14tx_pkt_null (
    output logic [23:0] header,
    output logic [55:0] sub [3:0]
);

    assign header = 24'b0;
    assign sub = {56'h0, 56'h0, 56'h0, 56'h0};

endmodule : h14tx_pkt_null

