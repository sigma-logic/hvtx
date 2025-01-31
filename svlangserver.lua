return {
  includeIndexing = {
    "core/**/*.{v,sv,svh}",
    "include/**/*.{sv,svh}",
    "test/**/*.{sv,svh}",
    "top/**/*.{sv,svh}"
  },
  excludeIndexing = {"core/h14tx_pkg.sv"},
  launchConfiguration = "verilator -f verilator/lsp.f",
  formatCommand = "verible-verilog-format --flagfile verible-format.f",
}
