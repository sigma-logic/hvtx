// Copyright (c) 2025 Sigma Logic

module h14tx_reset_sync (
    input logic clk,
    input logic ext_rst_n,
    input logic lock,

    output logic sync_rst_n
);

    logic [3:0] guard_counter;

    typedef enum logic [1:0] {
        Assert,
        Guard,
        Deassert
    } state_t;

    state_t state, next_state;

    logic rst_n;
    assign rst_n = ext_rst_n && lock;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= Assert;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || state != Guard) begin
            guard_counter <= 0;
        end else begin
            guard_counter <= guard_counter + 4'd1;
        end
    end

    assign sync_rst_n = state == Deassert;

    always_comb begin
        next_state = state;

        unique case (state)
            Assert: begin
                next_state = Guard;
            end
            Guard: begin
                if (&guard_counter) begin
                    next_state = Deassert;
                end
            end
            Deassert: begin
                if (!ext_rst_n) begin
                    next_state = Assert;
                end
            end
        endcase
    end

endmodule : h14tx_reset_sync
