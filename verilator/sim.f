-Wall
-Wno-fatal
-j 0
--assert
--trace-fst
--trace-structs
--x-assign unique
--x-initial unique
-sv
-Iinclude
--binary

-f verilator/core.f

test/clk_rst_gen.sv
test/tb_timings.sv
test/tb_encoding.sv
test/tb_pkt_assembly.sv
test/tb_rst_sync.sv
test/tb_dvo.sv

