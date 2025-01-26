`ifndef H14TX_CEA861D_SVH_
`define H14TX_CEA861D_SVH_

`define CEA861D_CONFIG(__format) \
__format == 4 ? '{4, 5, 25, 53, 11, 10, 1650, 750, 1280, 720, 110, 5, 40, 5, 1'b0}\
              : '{4, 5, 25, 53, 11, 10, 1650, 750, 1280, 720, 110, 5, 40, 5, 1'b0} 

`endif

