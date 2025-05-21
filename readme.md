# Hdmi Video Transmitter (HVTX)

### Features
* For **Arora** FPGA family
* **Compact** - not exceed **100** LUTs, **100** FFs
* **Modular** - Divided into convenient modules

### Notes
* **Video Only** - only for clean video output
* **RGB888** - the only format supported, but theoretically can do more as it modular
* **DVI** - doesn't use preamble and guard intervals to stay simple

### In The Future
* **AXI** streaming support
* Integrated **DPLL** to mitigate timing violations

## Modules and usage
Just copy core [file](https://github.com/sigma-logic/hvtx/tree/main/src/hvtx.sv) to your project

Complete example can be found [here](https://github.com/sigma-logic/hvtx/tree/main/src/top.sv)

#### `hvtx_cursor`
Slides the cursor over a frame of the specified size
```sv
hvtx_cursor #
( .WIDTH(WIDTH)
, .FRAME_WIDTH(1650)
, .FRAME_HEIGHT(750)
) u_cursor
( .i_clk(pixel_clk)
, .i_rst(~rst_n)
, .o_x(x)
, .o_y(y)
);
```

#### `hvtx_sync`
Generates synchronization pulses based on the cursor position in the frame
```sv
hvtx_sync #
( .WIDTH(WIDTH)
, .FRAME_WIDTH(1650)
, .FRAME_HEIGHT(750)
, .ACTIVE_WIDTH(1280)
, .ACTIVE_HEIGHT(720)
, .H_PORCH(110)
, .H_SYNC(40)
, .V_PORCH(5)
, .V_SYNC(5)
) u_sync
( .i_clk(pixel_clk)
, .i_x(x)
, .i_y(y)
, .o_hs(hs) // H Sync
, .o_vs(vs) // V Sync
, .o_de(de) // Active video
);
```

#### `hvtx_mod`
Combines current timings and active video data and produces a vector of 3 modulated tmds 10-bit symbols (per channel) ready for transmission  
```sv
hvtx_mod u_mod
( .i_pixel_clk(pixel_clk)
, .i_serial_clk(serial_clk)
, .i_rst(~rst_n)
, .i_hs(hs)
, .i_vs(vs)
, .i_de(de)
, .i_video(video)
, .o_chan_vec(chan_vec)
);
```

#### `hvtx_ser`
Serializes tmds symbols and passes them to the LVDS output buffer. Serial clock should be **5** times faster than pixel clock. It is recommended to synthesize fast clock and then divide it by 5 to get pixel clock.
```sv
hvtx_ser u_ser
( .i_pixel_clk(pixel_clk)
, .i_serial_clk(serial_clk)
, .i_rst(~rst_n)
, .i_chan_vec(chan_vec)
, .o_hdmi_clk_p(hdmi_clk_p_a)
, .o_hdmi_clk_n(hdmi_clk_n_a)
, .o_hdmi_chan_p(hdmi_chan_p_a)
, .o_hdmi_chan_n(hdmi_chan_n_a)
);
```
