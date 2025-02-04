// Copyright (c) 2025 Sigma Logic

module h14tx_channel
    import h14tx_pkg::period_t;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoGuard;
#(
    parameter bit [1:0] Chan = 0
) (
    input logic clk,
    input logic rst_n,

    input period_t period,

    input logic [1:0] ctl,
    input logic [7:0] video,

    output logic [9:0] symbol
);

    logic [9:0] ctl_s;

    // Encode Control symbol
    always_comb
        unique case (ctl)
            2'b00: ctl_s = 10'b1101010100;
            2'b01: ctl_s = 10'b0010101011;
            2'b10: ctl_s = 10'b0101010100;
            2'b11: ctl_s = 10'b1010101011;
        endcase

    logic [9:0] video_s;

    // Encode Active video
    h14tx_tmds8b10b u_tmds8b10b (
        .clk(clk),
        .rst_n(rst_n),
        .enable(period == VideoActive),
        .video(video),
        .symbol(video_s)
    );

    logic [9:0] guard_s;

    // Set Guard Band
    always_comb
        unique case (Chan)  /*synthesis full_case*/
            0: guard_s = 10'b1011001100;
            1: guard_s = 10'b0100110011;
            2: guard_s = 10'b1011001100;
        endcase

    // Pick symbol based on current period
    always_comb
        case (period)
            VideoActive: symbol = video_s;
            VideoGuard: symbol = guard_s;
            default: symbol = ctl_s;
        endcase

endmodule : h14tx_channel
