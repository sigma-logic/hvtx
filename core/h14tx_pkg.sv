// Copyright (c) 2025 Sigma Logic

// verilator lint_off DECLFILENAME

`include "h14tx/macros.svh"

package h14tx_pkg;

    typedef struct packed {
        logic h;
        logic v;
    } sync_timings_t;

    typedef `VEC(2) ctl_t;
    typedef `VEC(4) data_t;
    typedef `VEC(8) video_t;

    typedef enum `VEC(3) {
        Control = 3'd0,
        VideoActive = 3'd1,
        VideoPreamble = 3'd2,
        VideoGuard = 3'd3,
        DataIslandActive = 3'd4,
        DataIslandPreamble = 3'd5,
        DataIslandGuard = 3'd6
    } period_t;

    typedef `VEC(10) symbol_t;

    virtual class frame #(
        parameter integer BitWidth = 11,
        parameter integer BitHeight = 10
    );

        typedef struct packed {
            `VEC(BitWidth) x;
            `VEC(BitHeight) y;
        } cursor_t;

        typedef struct packed {
            integer bit_width;
            integer bit_height;
            `VEC(BitWidth) frame_width;
            `VEC(BitHeight) frame_height;
            `VEC(BitWidth) active_width;
            `VEC(BitHeight) active_height;
            `VEC(BitWidth) h_front_porch;
            `VEC(BitHeight) v_front_porch;
            `VEC(BitWidth) h_sync_width;
            `VEC(BitHeight) v_sync_width;
            logic sync_polarity_invert;
        } timings_config_t;

    endclass

endpackage : h14tx_pkg
