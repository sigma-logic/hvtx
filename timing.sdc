//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11 
//Created Time: 2025-02-03 19:14:42
create_clock -name ref_clk -period 20 -waveform {0 10} [get_ports {ref_clk}]
