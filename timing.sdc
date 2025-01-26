//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11 
//Created Time: 2025-01-18 17:45:29
create_clock -name refclk -period 14.286 -waveform {0 10} [get_ports {ref_clk_70mhz}]
