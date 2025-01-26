`ifndef H14TX_REGISTERS_SVH_
`define H14TX_REGISTERS_SVH_

`define REG_DFLT_CLK clk
`define REG_DFLT_RST rst
`define REG_DFLT_RSTN rst_n

// Flip-Flop with asynchronous active-low reset
// __q: Q output of FF
// __d: D input of FF
// __reset_value: value assigned upon reset
// (__clk: clock input)
// (__arst_n: asynchronous reset, active-low)
`define FF(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RSTN) \
    always_ff @(posedge (__clk) or negedge (__arst_n)) begin                         \
        if (!__arst_n) begin                                                         \
            __q <= (__reset_value);                                                  \
        end else begin                                                               \
            __q <= (__d);                                                            \
        end                                                                          \
    end

// Flip-Flop with asynchronous active-high reset
// __q: Q output of FF
// __d: D input of FF
// __reset_value: value assigned upon reset
// __clk: clock input
// __arst: asynchronous reset, active-high
`define FFAR(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst = `REG_DFLT_RST)       \
    always_ff @(posedge (__clk) or posedge (__arst)) begin \
        if (__arst) begin                                  \
        __q <= (__reset_value);                            \
        end else begin                                     \
        __q <= (__d);                                      \
        end                                                \
    end

// Flip-Flop with synchronous active-high reset
// __q: Q output of FF
// __d: D input of FF
// __reset_value: value assigned upon reset
// __clk: clock input
// __reset_clk: reset input, active-high
`define FFSR(__q, __d, __reset_value, __clk, __reset_clk) \
    always_ff @(posedge (__clk)) begin                    \
    __q <= (__reset_clk) ? (__reset_value) : (__d);       \
    end

// Flip-Flop with synchronous active-low reset
// __q: Q output of FF
// __d: D input of FF
// __reset_value: value assigned upon reset
// __clk: clock input
// __reset_n_clk: reset input, active-low
`define FFSRN(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __reset_n_clk = `REG_DFLT_RST) \
    always_ff @(posedge (__clk)) begin                       \
        __q <= (!__reset_n_clk) ? (__reset_value) : (__d);   \
    end

// Always-enable Flip-Flop without reset
// __q: Q output of FF
// __d: D input of FF
// __clk: clock input
`define FFNR(__q, __d, __clk = `REG_DFLT_CLK)          \
    always_ff @(posedge (__clk)) begin \
        __q <= (__d);                  \
    end

`endif


// Flip-Flop with asynchronous active-low reset and synchronous clear
// __q: Q output of FF
// __d: D input of FF
// __clear: assign reset value into FF
// __reset_value: value assigned upon reset
// __clk: clock input
// __arst_n: asynchronous reset, active-low
`define FFARNC(__q, __d, __clear, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RSTN) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin        \
    if (!__arst_n) begin                                          \
      __q <= (__reset_value);                                     \
    end else begin                                                \
      if (__clear) begin                                          \
        __q <= (__reset_value);                                   \
      end else begin                                              \
        __q <= (__d);                                             \
      end                                                         \
    end                                                           \
  end

// Flip-Flop with load-enable and asynchronous active-low reset (implicit clock and reset)
// __q: Q output of FF
// __d: D input of FF
// __load: load d value into FF
// __reset_value: value assigned upon reset
// (__clk: clock input)
// (__arst_n: asynchronous reset, active-low)
`define FFL(__q, __d, __load, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RSTN) \
    always_ff @(posedge (__clk) or negedge (__arst_n)) begin                                    \
        if (!__arst_n) begin                                                                      \
            __q <= (__reset_value);                                                                 \
        end else begin                                                                            \
            if (__load) begin                                                                       \
                __q <= (__d);                                                                         \
            end                                                                                     \
        end                                                                                       \
    end
