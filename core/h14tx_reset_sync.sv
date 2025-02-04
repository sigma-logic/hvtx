// Copyright (c) 2025 Sigma Logic

module h14tx_reset_sync (
    input logic clk,
    input logic ext_rst_n,

    output logic sync_rst_n
);

    logic [3:0] guard_counter;

    typedef enum logic [1:0] {
        Assert,
        Guard,
        Deassert
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge ext_rst_n) begin
        if (!ext_rst_n) begin
            state <= Assert;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk or negedge ext_rst_n) begin
        if (!ext_rst_n || state != Guard) begin
            guard_counter <= 0;
        end else begin
            guard_counter <= guard_counter + 4'd1;
        end
    end

    assign sync_rst_n = state == Deassert;

    always_comb begin
        next_state = state;

        case (state)
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
