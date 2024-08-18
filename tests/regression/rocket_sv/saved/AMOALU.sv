// Generated by CIRCT firtool-1.61.0
// Standard header to adapt well known macros for register randomization.
`ifndef RANDOMIZE
  `ifdef RANDOMIZE_MEM_INIT
    `define RANDOMIZE
  `endif // RANDOMIZE_MEM_INIT
`endif // not def RANDOMIZE
`ifndef RANDOMIZE
  `ifdef RANDOMIZE_REG_INIT
    `define RANDOMIZE
  `endif // RANDOMIZE_REG_INIT
`endif // not def RANDOMIZE

// RANDOM may be set to an expression that produces a 32-bit random unsigned value.
`ifndef RANDOM
  `define RANDOM $random
`endif // not def RANDOM

// Users can define INIT_RANDOM as general code that gets injected into the
// initializer block for modules with registers.
`ifndef INIT_RANDOM
  `define INIT_RANDOM
`endif // not def INIT_RANDOM

// If using random initialization, you can also define RANDOMIZE_DELAY to
// customize the delay used, otherwise 0.002 is used.
`ifndef RANDOMIZE_DELAY
  `define RANDOMIZE_DELAY 0.002
`endif // not def RANDOMIZE_DELAY

// Define INIT_RANDOM_PROLOG_ for use in our modules below.
`ifndef INIT_RANDOM_PROLOG_
  `ifdef RANDOMIZE
    `ifdef VERILATOR
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM
    `else  // VERILATOR
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM #`RANDOMIZE_DELAY begin end
    `endif // VERILATOR
  `else  // RANDOMIZE
    `define INIT_RANDOM_PROLOG_
  `endif // RANDOMIZE
`endif // not def INIT_RANDOM_PROLOG_

// Include register initializers in init blocks unless synthesis is set
`ifndef SYNTHESIS
  `ifndef ENABLE_INITIAL_REG_
    `define ENABLE_INITIAL_REG_
  `endif // not def ENABLE_INITIAL_REG_
`endif // not def SYNTHESIS

// Include rmemory initializers in init blocks unless synthesis is set
`ifndef SYNTHESIS
  `ifndef ENABLE_INITIAL_MEM_
    `define ENABLE_INITIAL_MEM_
  `endif // not def ENABLE_INITIAL_MEM_
`endif // not def SYNTHESIS

// Standard header to adapt well known macros for prints and assertions.

// Users can define 'PRINTF_COND' to add an extra gate to prints.
`ifndef PRINTF_COND_
  `ifdef PRINTF_COND
    `define PRINTF_COND_ (`PRINTF_COND)
  `else  // PRINTF_COND
    `define PRINTF_COND_ 1
  `endif // PRINTF_COND
`endif // not def PRINTF_COND_

// Users can define 'ASSERT_VERBOSE_COND' to add an extra gate to assert error printing.
`ifndef ASSERT_VERBOSE_COND_
  `ifdef ASSERT_VERBOSE_COND
    `define ASSERT_VERBOSE_COND_ (`ASSERT_VERBOSE_COND)
  `else  // ASSERT_VERBOSE_COND
    `define ASSERT_VERBOSE_COND_ 1
  `endif // ASSERT_VERBOSE_COND
`endif // not def ASSERT_VERBOSE_COND_

// Users can define 'STOP_COND' to add an extra gate to stop conditions.
`ifndef STOP_COND_
  `ifdef STOP_COND
    `define STOP_COND_ (`STOP_COND)
  `else  // STOP_COND
    `define STOP_COND_ 1
  `endif // STOP_COND
`endif // not def STOP_COND_

module AMOALU(
  input  [3:0]  io_mask,	// src/main/scala/rocket/AMOALU.scala:57:14
  input  [4:0]  io_cmd,	// src/main/scala/rocket/AMOALU.scala:57:14
  input  [31:0] io_lhs,	// src/main/scala/rocket/AMOALU.scala:57:14
                io_rhs,	// src/main/scala/rocket/AMOALU.scala:57:14
  output [31:0] io_out_unmasked	// src/main/scala/rocket/AMOALU.scala:57:14
);

  wire [31:0] adder_out_mask = 32'hFFFFFFFF;	// src/main/scala/rocket/AMOALU.scala:74:16
  wire [3:0]  less_signed_mask = 4'h2;	// src/main/scala/rocket/AMOALU.scala:87:29
  wire        max = io_cmd == 5'hD | io_cmd == 5'hF;	// src/main/scala/rocket/AMOALU.scala:66:{20,33,43}
  wire        min = io_cmd == 5'hC | io_cmd == 5'hE;	// src/main/scala/rocket/AMOALU.scala:67:{20,33,43}
  wire        add = io_cmd == 5'h8;	// src/main/scala/rocket/AMOALU.scala:68:20
  wire        _logic_xor_T_1 = io_cmd == 5'hA;	// src/main/scala/rocket/AMOALU.scala:69:26
  wire        logic_and = _logic_xor_T_1 | io_cmd == 5'hB;	// src/main/scala/rocket/AMOALU.scala:69:{26,38,48}
  wire        logic_xor = io_cmd == 5'h9 | _logic_xor_T_1;	// src/main/scala/rocket/AMOALU.scala:69:26, :70:{26,39}
  wire [31:0] adder_out = io_lhs + io_rhs;	// src/main/scala/rocket/AMOALU.scala:75:21
  wire        less_signed = ~(io_cmd[1]);	// src/main/scala/rocket/AMOALU.scala:88:{17,25}
  wire        less =
    io_lhs[31] == io_rhs[31] ? io_lhs < io_rhs : less_signed ? io_lhs[31] : io_rhs[31];	// src/main/scala/rocket/AMOALU.scala:81:35, :88:25, :90:{10,12,18,23,58}
  wire [31:0] minmax = (less ? min : max) ? io_lhs : io_rhs;	// src/main/scala/rocket/AMOALU.scala:66:33, :67:33, :90:10, :96:{19,23}
  wire [31:0] logic_0 =
    (logic_and ? io_lhs & io_rhs : 32'h0) | (logic_xor ? io_lhs ^ io_rhs : 32'h0);	// src/main/scala/rocket/AMOALU.scala:69:38, :70:39, :98:{8,27,42}, :99:{8,27}
  wire [31:0] out = add ? adder_out : logic_and | logic_xor ? logic_0 : minmax;	// src/main/scala/rocket/AMOALU.scala:68:20, :69:38, :70:39, :75:21, :96:19, :98:42, :101:8, :102:{8,19}
  wire [15:0] wmask_lo = {{8{io_mask[1]}}, {8{io_mask[0]}}};	// src/main/scala/rocket/AMOALU.scala:105:30
  wire [15:0] wmask_hi = {{8{io_mask[3]}}, {8{io_mask[2]}}};	// src/main/scala/rocket/AMOALU.scala:93:49, :105:30
  wire [31:0] wmask = {wmask_hi, wmask_lo};	// src/main/scala/rocket/AMOALU.scala:105:30
  assign io_out_unmasked = out;	// src/main/scala/rocket/AMOALU.scala:101:8
endmodule

