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

    integer i;

    always_comb begin
        n1d = 4'b0;
        for (i = 0; i < 8; i++) begin
            n1d = n1d + {3'b0, video[i]};
        end

        case (ir[0] + ir[1] + ir[2] + ir[3] + ir[4] + ir[5] + ir[6] + ir[7])
            4'b0000: n1ir = 5'sd0;
            4'b0001: n1ir = 5'sd1;
            4'b0010: n1ir = 5'sd2;
            4'b0011: n1ir = 5'sd3;
            4'b0100: n1ir = 5'sd4;
            4'b0101: n1ir = 5'sd5;
            4'b0110: n1ir = 5'sd6;
            4'b0111: n1ir = 5'sd7;
            4'b1000: n1ir = 5'sd8;
            default: n1ir = 5'sd0;
        endcase

        n0ir = 5'sd8 - n1ir;
    end

    logic signed [4:0] dispadd;

    integer j;

    always_comb begin
        ir[0] = video[0];

        if (n1d > 4'd4 || (n1d == 4'd4 && video[0] == 1'b0)) begin
            for (j = 0; j < 7; j++) ir[j+1] = ir[j] ~^ video[j+1];

            ir[8] = 1'b0;
        end else begin
            for (j = 0; j < 7; j++) ir[j+1] = ir[j] ^ video[j+1];

            ir[8] = 1'b1;
        end

        if (disparity == 5'sd0 || (n1ir == n0ir)) begin
            symbol = {~ir[8], ir[8], ir[8] ? ir[7:0] : ~ir[7:0]};

            if (ir[8]) begin
                dispadd = n1ir - n0ir;
            end else begin
                dispadd = n0ir - n1ir;
            end
        end else if ((disparity > 5'sd0 && n1ir > n0ir) || (disparity < 5'sd0 && n1ir < n0ir)) begin
            symbol  = {1'b1, ir[8], ~ir[7:0]};
            dispadd = (n0ir - n1ir) + (ir[8] ? 5'sd2 : 5'sd0);
        end else begin
            symbol  = {1'b0, ir[8], ir[7:0]};
            dispadd = (n1ir - n0ir) - (~ir[8] ? 5'sd2 : 5'sd0);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !enable) begin
            disparity <= 0;
        end else begin
            disparity <= disparity + dispadd;
        end
    end

endmodule : h14tx_tmds8b10b
