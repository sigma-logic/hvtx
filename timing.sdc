//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11 
//Created Time: 2025-01-27 14:36:32
create_clock -name refclk -period 14.286 -waveform {0 10} [get_ports {ref_clk_70mhz}]
create_generated_clock -name pixel_clk -source [get_ports {ref_clk_70mhz}] -master_clock refclk -divide_by 50 -multiply_by 53 [get_nets {pixel_clk}]
create_generated_clock -name serial_clk -source [get_ports {ref_clk_70mhz}] -master_clock refclk -divide_by 10 -multiply_by 53 [get_nets {serial_clk}]
