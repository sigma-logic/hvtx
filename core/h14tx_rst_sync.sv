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
        WaitLock,
        WaitGuard,
        Deassert
    } state_t;

    state_t state, next_state;

    logic rst_n = ext_rst_n;

    `FF(state, next_state, Assert)
    `FFARNC(guard_counter, guard_counter + 1, state !== WaitGuard, 4'b0)
    `FF(sync_rst_n, state == Deassert, 1'b0)

    always_comb begin
        next_state = state;

        unique case (state)
            Assert: begin
                if (!lock) begin
                    next_state = WaitLock;
                end else if (ext_rst_n) begin
                    next_state = Deassert;
                end
            end
            WaitLock: begin
                if (lock) begin
                    next_state = WaitGuard;
                end
            end
            WaitGuard: begin
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
