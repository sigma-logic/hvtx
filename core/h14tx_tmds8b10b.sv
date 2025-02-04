// Copyright (c) 2025 Sigma Logic

module h14tx_tmds8b10b (
    input logic clk,
    input logic rst_n,

    input logic enable,
    input logic [7:0] video,

    output logic [9:0] symbol
);

    logic signed [4:0] disparity;
    logic [8:0] ir;

    logic [3:0] n1d;
    logic signed [4:0] n1ir;
    logic signed [4:0] n0ir;

    assign n1d  = 4'($countones(video));
    assign n1ir = 5'($countones(ir[7:0]));
    assign n0ir = 5'sd8 - 5'($countones(ir[7:0]));

    logic signed [4:0] dispadd;

    logic [9:0] next_symbol;

    always_comb begin
        ir[0] = video[0];

        if (n1d > 4'd4 || (n1d == 4'd4 && video[0] == 1'b0)) begin
            ir[1] = ir[0] ~^ video[1];
            ir[2] = ir[1] ~^ video[2];
            ir[3] = ir[2] ~^ video[3];
            ir[4] = ir[3] ~^ video[4];
            ir[5] = ir[4] ~^ video[5];
            ir[6] = ir[5] ~^ video[6];
            ir[7] = ir[6] ~^ video[7];

            ir[8] = 1'b0;
        end else begin
            ir[1] = ir[0] ^ video[1];
            ir[2] = ir[1] ^ video[2];
            ir[3] = ir[2] ^ video[3];
            ir[4] = ir[3] ^ video[4];
            ir[5] = ir[4] ^ video[5];
            ir[6] = ir[5] ^ video[6];
            ir[7] = ir[6] ^ video[7];

            ir[8] = 1'b1;
        end

        if (disparity == 5'sd0 || (n1ir == n0ir)) begin
            next_symbol = {~ir[8], ir[8], ir[8] ? ir[7:0] : ~ir[7:0]};
            dispadd = ir[8] ? n1ir - n0ir : n0ir - n1ir;
        end else if ((disparity > 5'sd0 && n1ir > n0ir) || (disparity < 5'sd0 && n1ir < n0ir)) begin
            next_symbol = {1'b1, ir[8], ~ir[7:0]};
            dispadd = (n0ir - n1ir) + (ir[8] ? 5'sd2 : 5'sd0);
        end else begin
            next_symbol = {1'b0, ir[8], ir[7:0]};
            dispadd = (n1ir - n0ir) - (~ir[8] ? 5'sd2 : 5'sd0);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !enable) begin
            disparity <= 0;
            symbol <= 10'b0;
        end else begin
            disparity <= disparity + dispadd;
            symbol <= next_symbol;
        end
    end

endmodule : h14tx_tmds8b10b
