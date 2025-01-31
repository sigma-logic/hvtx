package h14tx_pkg;

    typedef enum logic [2:0] {
        Control,
        VideoActive,
        VideoPreamble,
        VideoGuard,
        DataIslandActive,
        DataIslandPreamble,
        DataIslandGuard
    } period_t;

    typedef struct packed {
        int bit_width;
        int bit_height;

        int frame_width;
        int frame_height;
        int active_width;
        int active_height;
        int h_front_porch;
        int h_sync_width;
        int v_front_porch;
        int v_sync_width;
        logic invert_polarity;
    } timings_cfg_t;

    typedef struct packed {
        lvds_pkg::pair_t clk;
        lvds_pkg::pair_t [2:0] chan;
    } tmds_t;

endpackage : h14tx_pkg
