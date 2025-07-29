//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11 
//Created Time: 2025-05-23 12:26:11
create_clock -name ref_clk -period 20 -waveform {0 10} [get_ports {ref_clk}]
create_generated_clock -name serial_clk -source [get_ports {ref_clk}] -master_clock ref_clk -divide_by 5 -multiply_by 37 [get_nets {serial_clk}]
create_generated_clock -name pixel_clk -source [get_nets {serial_clk}] -master_clock serial_clk -divide_by 5 [get_nets {pixel_clk}]
