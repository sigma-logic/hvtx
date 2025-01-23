`ifndef H14TX_CEA861D_SVH_
`define H14TX_CEA861D_SVH_

`define CEA861D_PLL(__format) \
.IDivSel(4),\
.ODiv0Sel(5),\
.ODiv1Sel(25),\
.MDivSel(53)

`define CEA861D_BIT_WIDTH(__format) 11
`define CEA861D_BIT_HEIGHT(__format) 10

`define CEA861D_TIMINGS(__format) \
.BitWidth(11),\
.BitHeight(10),\
.FrameWidth(1650),\
.FrameHeight(750),\
.ActiveWidth(1280),\
.ActiveHeight(720),\
.HFrontPorch(110),\
.HSyncWidth(40),\
.VFrontPorch(5),\
.VSyncWidth(5),\
.InvertPolarity(1'b0)

`endif
