// Copyright (c) 2025 Sigma Logic

module h14tx_timings
    import h14tx_pkg::timings_cfg_t;
    import h14tx_pkg::period_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
#(
    parameter timings_cfg_t Cfg = '{11, 10, 1650, 750, 1280, 720, 110, 40, 5, 5, 1'b0},

    parameter int BitWidth  = Cfg.bit_width,
    parameter int BitHeight = Cfg.bit_height,

    parameter logic [BitWidth-1:0] FrameWidth = BitWidth'(Cfg.frame_width),
    parameter logic [BitHeight-1:0] FrameHeight = BitHeight'(Cfg.frame_height),
    parameter logic [BitWidth-1:0] ActiveWidth = BitWidth'(Cfg.active_width),
    parameter logic [BitHeight-1:0] ActiveHeight = BitHeight'(Cfg.active_height),
    parameter logic [BitWidth-1:0] HFrontPorch = BitWidth'(Cfg.h_front_porch),
    parameter logic [BitWidth-1:0] HSyncWidth = BitWidth'(Cfg.h_sync_width),
    parameter logic [BitHeight-1:0] VFrontPorch = BitHeight'(Cfg.v_front_porch),
    parameter logic [BitHeight-1:0] VSyncWidth = BitHeight'(Cfg.v_sync_width),
    parameter logic InvertPolarity = Cfg.invert_polarity
) (
    input logic clk,
    input logic rst_n,

    output logic [ BitWidth-1:0] x,
    output logic [BitHeight-1:0] y,

    output logic hsync,
    output logic vsync,

    output period_t period
);

    // Advance cursor
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0;
            y <= 0;
        end else begin
            x <= x == FrameWidth - BitWidth'(1) ? BitWidth'(0) : x + BitWidth'(1);
            y <= x == FrameWidth - BitWidth'(1) ? (y == FrameHeight - BitHeight'(1) ? BitHeight'(0) : y + BitHeight'(1)) : y;
        end
    end

    // The timings looks like this (_ - blanking or data island, v - video, p - preamble,
    // g - guard, h - hsync, y - vsync, x - both vsync and hsync)
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h___
    // __________________________xyyy
    // yyyyyyyyyyyyyyyyyyyyyyyyyyxyyy
    // yyyyyyyyyyyyyyyyyyyyyyyyyyh_pg

    // Determine Horizontal Sync Pulse Range
    localparam [BitWidth-1:0] HSyncStart = ActiveWidth + HFrontPorch;
    localparam [BitWidth-1:0] HSyncEnd = HSyncStart + HSyncWidth;

    // Determine Vertical Sync Pulse Range
    localparam [BitHeight-1:0] VSyncStart = ActiveHeight + VFrontPorch;
    localparam [BitHeight-1:0] VSyncEnd = VSyncStart + VSyncWidth;

    always_comb begin
        hsync = x >= HSyncStart && x < HSyncEnd;

        if (y == VSyncStart) begin
            vsync = x >= HSyncStart;
        end else if (y == VSyncEnd - BitHeight'(1)) begin
            vsync = x < HSyncStart;
        end else begin
            vsync = y >= VSyncStart && y < VSyncEnd;
        end
    end

    // Periods boundaries
    localparam [BitWidth-1:0] VideoPreambleStart = FrameWidth - BitWidth'(10);
    localparam [BitWidth-1:0] VideoGuardStart = FrameWidth - BitWidth'(2);

    // Put video preamble at end of each active line except last one
    // and put on the end of the last frame line
    logic preamble_line;
    assign preamble_line = y < ActiveHeight - BitHeight'(1) || y == FrameHeight - BitHeight'(1);

    // Pick Period
    always_comb begin
        if (x < ActiveWidth && y < ActiveHeight) begin
            period = VideoActive;
        end else if (preamble_line && (x >= VideoPreambleStart && x < VideoGuardStart)) begin
            period = VideoPreamble;
        end else if (preamble_line && (x >= VideoGuardStart && x < FrameWidth)) begin
            period = VideoGuard;
        end else begin
            // Pick control period for the rest of time
            period = Control;
        end
    end

endmodule : h14tx_timings
