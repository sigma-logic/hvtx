// Copyright (c) 2025 Sigma Logic

`include "h14tx/registers.svh"

module h14tx_rst_sync (
    input  logic clk,
    input  logic lock,
    input  logic ext_rst_n,
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

    `FF(state, next_state, Assert)
    `FFARNC(guard_counter, guard_counter + 4'b1, state != Guard, 4'd0)

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

endmodule : h14tx_rst_sync
