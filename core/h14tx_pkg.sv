// Copyright (c) 2025 Sigma Logic

// verilator lint_off DECLFILENAME

package h14tx_pkg;

    typedef struct packed {
        logic h;
        logic v;
    } sync_timings_t;

    typedef logic [1:0] ctl_t;
    typedef logic [3:0] data_t;
    typedef logic [7:0] video_t;

    typedef enum logic [2:0] {
        Control = 3'd0,
        VideoActive = 3'd1,
        VideoPreamble = 3'd2,
        VideoGuard = 3'd3,
        DataIslandActive = 3'd4,
        DataIslandPreamble = 3'd5,
        DataIslandGuard = 3'd6
    } period_t;

    typedef logic [9:0] symbol_t;

    typedef struct packed {
        logic p;
        logic n;
    } diff_t;

    typedef struct packed {
        diff_t clk;
        diff_t [3:0] chan;
    } hdmi_tmds_t;

    typedef struct packed {
        integer pll_idiv_sel;
        integer pll_odiv0_sel;
        integer pll_odiv1_sel;
        integer pll_mdiv_sel;
        integer bit_width;
        integer bit_height;
        integer timings_frame_width;
        integer timings_frame_height;
        integer timings_active_width;
        integer timings_active_height;
        integer timings_h_front_porch;
        integer timings_v_front_porch;
        integer timings_h_sync_width;
        integer timings_v_sync_width;
        logic   timings_invert_polarity;
    } cea861d_config_t;

endpackage : h14tx_pkg

