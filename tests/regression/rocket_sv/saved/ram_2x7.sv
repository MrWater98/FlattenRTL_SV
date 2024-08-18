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

// VCS coverage exclude_file
module ram_2x7(	// src/main/scala/chisel3/util/Decoupled.scala:274:95
  input        R0_addr,
               R0_en,
               R0_clk,
  output [6:0] R0_data,
  input        W0_addr,
               W0_en,
               W0_clk,
  input  [6:0] W0_data
);

  reg [6:0] Memory[0:1];	// src/main/scala/chisel3/util/Decoupled.scala:274:95
  always @(posedge W0_clk) begin	// src/main/scala/chisel3/util/Decoupled.scala:274:95
    if (W0_en & 1'h1)	// src/main/scala/chisel3/util/Decoupled.scala:274:95
      Memory[W0_addr] <= W0_data;	// src/main/scala/chisel3/util/Decoupled.scala:274:95
  end // always @(posedge)
  `ifdef ENABLE_INITIAL_MEM_	// src/main/scala/chisel3/util/Decoupled.scala:274:95
    reg [31:0] _RANDOM_MEM;	// src/main/scala/chisel3/util/Decoupled.scala:274:95
    initial begin	// src/main/scala/chisel3/util/Decoupled.scala:274:95
      `INIT_RANDOM_PROLOG_	// src/main/scala/chisel3/util/Decoupled.scala:274:95
      `ifdef RANDOMIZE_MEM_INIT	// src/main/scala/chisel3/util/Decoupled.scala:274:95
        for (logic [1:0] i = 2'h0; i < 2'h2; i += 2'h1) begin
          _RANDOM_MEM = `RANDOM;	// src/main/scala/chisel3/util/Decoupled.scala:274:95
          Memory[i[0]] = _RANDOM_MEM[6:0];	// src/main/scala/chisel3/util/Decoupled.scala:274:95
        end	// src/main/scala/chisel3/util/Decoupled.scala:274:95
      `endif // RANDOMIZE_MEM_INIT
    end // initial
  `endif // ENABLE_INITIAL_MEM_
  assign R0_data = R0_en ? Memory[R0_addr] : 7'bx;	// src/main/scala/chisel3/util/Decoupled.scala:274:95
endmodule

