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

module MulDiv(
  input         clock,
                reset,
  output        io_req_ready,	// src/main/scala/rocket/Multiplier.scala:42:14
  input         io_req_valid,	// src/main/scala/rocket/Multiplier.scala:42:14
  input  [3:0]  io_req_bits_fn,	// src/main/scala/rocket/Multiplier.scala:42:14
  input         io_req_bits_dw,	// src/main/scala/rocket/Multiplier.scala:42:14
  input  [31:0] io_req_bits_in1,	// src/main/scala/rocket/Multiplier.scala:42:14
                io_req_bits_in2,	// src/main/scala/rocket/Multiplier.scala:42:14
  input  [4:0]  io_req_bits_tag,	// src/main/scala/rocket/Multiplier.scala:42:14
  input         io_kill,	// src/main/scala/rocket/Multiplier.scala:42:14
                io_resp_ready,	// src/main/scala/rocket/Multiplier.scala:42:14
  output        io_resp_valid,	// src/main/scala/rocket/Multiplier.scala:42:14
  output [31:0] io_resp_bits_data,	// src/main/scala/rocket/Multiplier.scala:42:14
  output [4:0]  io_resp_bits_tag	// src/main/scala/rocket/Multiplier.scala:42:14
);

  wire        eOut = 1'h0;	// src/main/scala/rocket/Multiplier.scala:115:13
  reg  [2:0]  state;	// src/main/scala/rocket/Multiplier.scala:48:22
  reg  [3:0]  req_fn;	// src/main/scala/rocket/Multiplier.scala:50:16
  reg         req_dw;	// src/main/scala/rocket/Multiplier.scala:50:16
  reg  [31:0] req_in1;	// src/main/scala/rocket/Multiplier.scala:50:16
  reg  [31:0] req_in2;	// src/main/scala/rocket/Multiplier.scala:50:16
  reg  [4:0]  req_tag;	// src/main/scala/rocket/Multiplier.scala:50:16
  reg  [5:0]  count;	// src/main/scala/rocket/Multiplier.scala:51:18
  reg         neg_out;	// src/main/scala/rocket/Multiplier.scala:54:20
  reg         isHi;	// src/main/scala/rocket/Multiplier.scala:55:17
  reg         resHi;	// src/main/scala/rocket/Multiplier.scala:56:18
  reg  [32:0] divisor;	// src/main/scala/rocket/Multiplier.scala:57:20
  wire [32:0] mpcand = divisor;	// src/main/scala/rocket/Multiplier.scala:57:20, :108:26
  reg  [65:0] remainder;	// src/main/scala/rocket/Multiplier.scala:58:22
  wire [2:0]  decoded_plaInput;	// src/main/scala/chisel3/util/pla.scala:77:22
  wire [2:0]  decoded_invInputs = ~decoded_plaInput;	// src/main/scala/chisel3/util/pla.scala:77:22, :78:21
  wire [3:0]  decoded_invMatrixOutputs;	// src/main/scala/chisel3/util/pla.scala:120:37
  wire        decoded_andMatrixInput_0 = decoded_invInputs[0];	// src/main/scala/chisel3/util/pla.scala:78:21, :91:29
  wire        decoded_andMatrixInput_0_5 = decoded_invInputs[0];	// src/main/scala/chisel3/util/pla.scala:78:21, :91:29
  wire        decoded_andMatrixInput_0_1 = decoded_invInputs[2];	// src/main/scala/chisel3/util/pla.scala:78:21, :91:29
  wire        decoded_andMatrixInput_1 = decoded_invInputs[2];	// src/main/scala/chisel3/util/pla.scala:78:21, :91:29
  wire        decoded_andMatrixInput_1_1 = decoded_invInputs[2];	// src/main/scala/chisel3/util/pla.scala:78:21, :91:29
  wire        decoded_andMatrixInput_0_2 = decoded_invInputs[1];	// src/main/scala/chisel3/util/pla.scala:78:21, :91:29
  wire [1:0]  _decoded_T_2 = {decoded_andMatrixInput_0_2, decoded_andMatrixInput_1};	// src/main/scala/chisel3/util/pla.scala:91:29, :98:53
  wire        decoded_andMatrixInput_0_3 = decoded_plaInput[0];	// src/main/scala/chisel3/util/pla.scala:77:22, :90:45
  wire        decoded_andMatrixInput_0_4 = decoded_plaInput[1];	// src/main/scala/chisel3/util/pla.scala:77:22, :90:45
  wire        decoded_andMatrixInput_1_2 = decoded_plaInput[2];	// src/main/scala/chisel3/util/pla.scala:77:22, :90:45
  wire [1:0]  decoded_orMatrixOutputs_lo =
    {|{decoded_andMatrixInput_0, &_decoded_T_2},
     |{&_decoded_T_2, &{decoded_andMatrixInput_0_5, decoded_andMatrixInput_1_2}}};	// src/main/scala/chisel3/util/pla.scala:90:45, :91:29, :98:{53,70}, :102:36, :114:{19,36}
  wire [1:0]  decoded_orMatrixOutputs_hi =
    {decoded_andMatrixInput_0_1,
     |{&{decoded_andMatrixInput_0_3, decoded_andMatrixInput_1_1},
       decoded_andMatrixInput_0_4}};	// src/main/scala/chisel3/util/pla.scala:90:45, :91:29, :98:{53,70}, :102:36, :114:{19,36}
  wire [3:0]  decoded_orMatrixOutputs =
    {decoded_orMatrixOutputs_hi, decoded_orMatrixOutputs_lo};	// src/main/scala/chisel3/util/pla.scala:102:36
  wire [1:0]  decoded_invMatrixOutputs_lo = decoded_orMatrixOutputs[1:0];	// src/main/scala/chisel3/util/pla.scala:102:36, :120:37
  wire [1:0]  decoded_invMatrixOutputs_hi = decoded_orMatrixOutputs[3:2];	// src/main/scala/chisel3/util/pla.scala:102:36, :120:37
  assign decoded_invMatrixOutputs =
    {decoded_invMatrixOutputs_hi, decoded_invMatrixOutputs_lo};	// src/main/scala/chisel3/util/pla.scala:120:37
  wire [3:0]  decoded = decoded_invMatrixOutputs;	// src/main/scala/chisel3/util/pla.scala:81:23, :120:37
  assign decoded_plaInput = io_req_bits_fn[2:0];	// src/main/scala/chisel3/util/experimental/decode/decoder.scala:39:16, src/main/scala/chisel3/util/pla.scala:77:22
  wire        cmdMul = decoded[3];	// src/main/scala/chisel3/util/pla.scala:81:23, src/main/scala/rocket/Decode.scala:50:77, src/main/scala/rocket/Multiplier.scala:72:107
  wire        cmdHi = decoded[2];	// src/main/scala/chisel3/util/pla.scala:81:23, src/main/scala/rocket/Decode.scala:50:77, src/main/scala/rocket/Multiplier.scala:72:107
  wire        lhsSigned = decoded[1];	// src/main/scala/chisel3/util/pla.scala:81:23, src/main/scala/rocket/Decode.scala:50:77, src/main/scala/rocket/Multiplier.scala:72:107
  wire        rhsSigned = decoded[0];	// src/main/scala/chisel3/util/pla.scala:81:23, src/main/scala/rocket/Decode.scala:50:77, src/main/scala/rocket/Multiplier.scala:72:107
  wire        lhs_sign = lhsSigned & io_req_bits_in1[31];	// src/main/scala/rocket/Multiplier.scala:72:107, :78:{23,48}
  wire [15:0] hi = io_req_bits_in1[31:16];	// src/main/scala/rocket/Multiplier.scala:79:{17,43}
  wire [31:0] lhs_in = {hi, io_req_bits_in1[15:0]};	// src/main/scala/rocket/Multiplier.scala:79:17, :80:{9,15}
  wire        rhs_sign = rhsSigned & io_req_bits_in2[31];	// src/main/scala/rocket/Multiplier.scala:72:107, :78:{23,48}
  wire [15:0] hi_1 = io_req_bits_in2[31:16];	// src/main/scala/rocket/Multiplier.scala:79:{17,43}
  wire [31:0] rhs_in = {hi_1, io_req_bits_in2[15:0]};	// src/main/scala/rocket/Multiplier.scala:79:17, :80:{9,15}
  wire [32:0] subtractor = remainder[64:32] - divisor;	// src/main/scala/rocket/Multiplier.scala:57:20, :58:22, :85:{29,37}
  wire [31:0] result = resHi ? remainder[64:33] : remainder[31:0];	// src/main/scala/rocket/Multiplier.scala:56:18, :58:22, :86:{19,36,57}
  wire [31:0] negated_remainder = 32'h0 - result;	// src/main/scala/rocket/Multiplier.scala:50:16, :86:19, :87:27
  wire [64:0] mulReg = {remainder[65:33], remainder[31:0]};	// src/main/scala/rocket/Multiplier.scala:58:22, :86:57, :104:{21,31}
  wire        mplierSign = remainder[32];	// src/main/scala/rocket/Multiplier.scala:58:22, :105:31
  wire [31:0] mplier = mulReg[31:0];	// src/main/scala/rocket/Multiplier.scala:104:21, :106:24
  wire [32:0] accum = mulReg[64:32];	// src/main/scala/rocket/Multiplier.scala:104:21, :107:{23,37}
  wire [41:0] prod =
    {{34{mplierSign}}, mplier[7:0]} * {{9{mpcand[32]}}, mpcand} + {{9{accum[32]}}, accum};	// src/main/scala/rocket/Multiplier.scala:105:31, :106:24, :107:37, :108:26, :109:{38,67,76}
  wire [41:0] nextMulReg_hi = prod;	// src/main/scala/rocket/Multiplier.scala:109:76, :110:25
  wire [65:0] nextMulReg = {nextMulReg_hi, mplier[31:8]};	// src/main/scala/rocket/Multiplier.scala:106:24, :110:{25,38}
  wire        nextMplierSign = count == 6'h2 & neg_out;	// src/main/scala/rocket/Multiplier.scala:51:18, :54:20, :111:{32,61}
  wire [32:0] _eOutMask_T_2 = $signed(33'sh100000000 >>> {28'h0, count[1:0], 3'h0});	// src/main/scala/rocket/Multiplier.scala:51:18, :113:{44,72}
  wire [31:0] eOutMask = _eOutMask_T_2[31:0];	// src/main/scala/rocket/Multiplier.scala:113:{44,91}
  wire [64:0] eOutRes = mulReg >> 5'h0 - {count[1:0], 3'h0};	// src/main/scala/rocket/Multiplier.scala:51:18, :104:21, :113:72, :116:{27,38}
  wire [64:0] nextMulReg1 = nextMulReg[64:0];	// src/main/scala/rocket/Multiplier.scala:110:25, :117:26
  wire [33:0] remainder_hi = {nextMulReg1[64:32], nextMplierSign};	// src/main/scala/rocket/Multiplier.scala:111:61, :117:26, :118:{21,34}
  wire        unrolls_less = subtractor[32];	// src/main/scala/rocket/Multiplier.scala:85:37, :130:28
  wire [63:0] unrolls_hi =
    {unrolls_less ? remainder[63:32] : subtractor[31:0], remainder[31:0]};	// src/main/scala/rocket/Multiplier.scala:58:22, :85:37, :86:57, :130:28, :131:{10,14,24,45}
  wire [64:0] unrolls_0 = {unrolls_hi, ~unrolls_less};	// src/main/scala/rocket/Multiplier.scala:130:28, :131:{10,67}
  wire        divby0 = count == 6'h0 & ~unrolls_less;	// src/main/scala/rocket/Multiplier.scala:51:18, :130:28, :143:{24,32,35}, :165:11
  wire        outMul = ~(state[0]);	// src/main/scala/rocket/Multiplier.scala:48:22, :172:{23,52}
  wire [15:0] hiOut = result[31:16];	// src/main/scala/rocket/Multiplier.scala:86:19, :173:65, :174:18
  wire [15:0] loOut = result[15:0];	// src/main/scala/rocket/Multiplier.scala:86:19, :173:{18,82}
  wire        _io_resp_valid_output = state == 3'h6 | (&state);	// src/main/scala/rocket/Multiplier.scala:48:22, :178:{27,42,51}
  wire        _io_req_ready_output = state == 3'h0;	// src/main/scala/rocket/Multiplier.scala:48:22, :179:25
  wire        _GEN = state == 3'h1;	// src/main/scala/rocket/Multiplier.scala:48:22, :89:39
  wire        _GEN_0 = state == 3'h5;	// src/main/scala/rocket/Multiplier.scala:48:22, :98:39
  wire        _GEN_1 = state == 3'h2;	// src/main/scala/rocket/Multiplier.scala:48:22, :103:39
  wire        _GEN_2 = _GEN_1 & count == 6'h3;	// src/main/scala/rocket/Multiplier.scala:51:18, :98:57, :103:{39,50}, :121:{25,55}, :122:13
  wire        _GEN_3 = state == 3'h3;	// src/main/scala/rocket/Multiplier.scala:48:22, :126:39
  wire        _GEN_4 = count == 6'h20;	// src/main/scala/rocket/Multiplier.scala:51:18, :116:38, :135:17
  wire        _GEN_5 = _io_req_ready_output & io_req_valid;	// src/main/scala/chisel3/util/Decoupled.scala:52:35, src/main/scala/rocket/Multiplier.scala:179:25
  always @(posedge clock) begin
    if (reset)
      state <= 3'h0;	// src/main/scala/rocket/Multiplier.scala:48:22
    else if (_GEN_5)	// src/main/scala/chisel3/util/Decoupled.scala:52:35
      state <= cmdMul ? 3'h2 : {1'h0, ~(lhs_sign | rhs_sign), 1'h1};	// src/main/scala/rocket/Multiplier.scala:48:22, :72:107, :78:23, :115:13, :120:20, :162:{17,36,46}
    else if (io_resp_ready & _io_resp_valid_output | io_kill)	// src/main/scala/chisel3/util/Decoupled.scala:52:35, src/main/scala/rocket/Multiplier.scala:158:22, :178:42
      state <= 3'h0;	// src/main/scala/rocket/Multiplier.scala:48:22
    else if (_GEN_3 & _GEN_4)	// src/main/scala/rocket/Multiplier.scala:103:50, :126:{39,50}, :135:{17,42}, :136:13
      state <= {1'h1, ~neg_out, 1'h1};	// src/main/scala/rocket/Multiplier.scala:48:22, :54:20, :120:20, :136:19
    else if (_GEN_2)	// src/main/scala/rocket/Multiplier.scala:98:57, :103:50, :121:55, :122:13
      state <= 3'h6;	// src/main/scala/rocket/Multiplier.scala:48:22
    else if (_GEN_0)	// src/main/scala/rocket/Multiplier.scala:98:39
      state <= 3'h7;	// src/main/scala/rocket/Multiplier.scala:48:22, :100:11
    else if (_GEN)	// src/main/scala/rocket/Multiplier.scala:89:39
      state <= 3'h3;	// src/main/scala/rocket/Multiplier.scala:48:22
    if (_GEN_5) begin	// src/main/scala/chisel3/util/Decoupled.scala:52:35
      req_fn <= io_req_bits_fn;	// src/main/scala/rocket/Multiplier.scala:50:16
      req_dw <= io_req_bits_dw;	// src/main/scala/rocket/Multiplier.scala:50:16
      req_in1 <= io_req_bits_in1;	// src/main/scala/rocket/Multiplier.scala:50:16
      req_in2 <= io_req_bits_in2;	// src/main/scala/rocket/Multiplier.scala:50:16
      req_tag <= io_req_bits_tag;	// src/main/scala/rocket/Multiplier.scala:50:16
      count <= 6'h0;	// src/main/scala/rocket/Multiplier.scala:51:18, :165:11
      neg_out <= cmdHi ? lhs_sign : lhs_sign != rhs_sign;	// src/main/scala/rocket/Multiplier.scala:54:20, :72:107, :78:23, :166:{19,46}
      isHi <= cmdHi;	// src/main/scala/rocket/Multiplier.scala:55:17, :72:107
      divisor <= {rhs_sign, rhs_in};	// src/main/scala/rocket/Multiplier.scala:57:20, :78:23, :80:9, :167:19
      remainder <= {34'h0, lhs_in};	// src/main/scala/rocket/Multiplier.scala:58:22, :80:9, :91:17, :168:15
    end
    else begin	// src/main/scala/chisel3/util/Decoupled.scala:52:35
      if (_GEN_3) begin	// src/main/scala/rocket/Multiplier.scala:126:39
        count <= count + 6'h1;	// src/main/scala/rocket/Multiplier.scala:51:18, :120:20, :141:20
        remainder <= {1'h0, unrolls_0};	// src/main/scala/rocket/Multiplier.scala:58:22, :115:13, :131:10, :134:15
      end
      else if (_GEN_1) begin	// src/main/scala/rocket/Multiplier.scala:103:39
        count <= count + 6'h1;	// src/main/scala/rocket/Multiplier.scala:51:18, :120:20
        remainder <= {remainder_hi, nextMulReg1[31:0]};	// src/main/scala/rocket/Multiplier.scala:58:22, :117:26, :118:{21,67}
      end
      else if (_GEN_0 | _GEN & remainder[31])	// src/main/scala/rocket/Multiplier.scala:58:22, :89:{39,57}, :90:{20,27}, :91:17, :98:{39,57}, :99:15
        remainder <= {34'h0, negated_remainder};	// src/main/scala/rocket/Multiplier.scala:58:22, :87:27, :91:17
      neg_out <= ~(_GEN_3 & divby0 & ~isHi) & neg_out;	// src/main/scala/rocket/Multiplier.scala:54:20, :55:17, :126:{39,50}, :143:32, :156:{21,28,38}
      if (_GEN & divisor[31])	// src/main/scala/rocket/Multiplier.scala:57:20, :89:{39,57}, :93:{18,25}, :94:15
        divisor <= subtractor;	// src/main/scala/rocket/Multiplier.scala:57:20, :85:37
    end
    resHi <= ~_GEN_5 & (_GEN_3 & _GEN_4 | _GEN_2 ? isHi : ~_GEN_0 & resHi);	// src/main/scala/chisel3/util/Decoupled.scala:52:35, src/main/scala/rocket/Multiplier.scala:55:17, :56:18, :98:{39,57}, :101:11, :103:50, :121:55, :122:13, :123:13, :126:{39,50}, :135:{17,42}, :137:13, :161:22, :164:11
  end // always @(posedge)
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif // FIRRTL_BEFORE_INITIAL
    logic [31:0] _RANDOM[0:5];
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif // INIT_RANDOM_PROLOG_
      `ifdef RANDOMIZE_REG_INIT
        for (logic [2:0] i = 3'h0; i < 3'h6; i += 3'h1) begin
          _RANDOM[i] = `RANDOM;
        end
        state = _RANDOM[3'h0][2:0];	// src/main/scala/rocket/Multiplier.scala:48:22
        req_fn = _RANDOM[3'h0][6:3];	// src/main/scala/rocket/Multiplier.scala:48:22, :50:16
        req_dw = _RANDOM[3'h0][7];	// src/main/scala/rocket/Multiplier.scala:48:22, :50:16
        req_in1 = {_RANDOM[3'h0][31:8], _RANDOM[3'h1][7:0]};	// src/main/scala/rocket/Multiplier.scala:48:22, :50:16
        req_in2 = {_RANDOM[3'h1][31:8], _RANDOM[3'h2][7:0]};	// src/main/scala/rocket/Multiplier.scala:50:16
        req_tag = _RANDOM[3'h2][12:8];	// src/main/scala/rocket/Multiplier.scala:50:16
        count = _RANDOM[3'h2][18:13];	// src/main/scala/rocket/Multiplier.scala:50:16, :51:18
        neg_out = _RANDOM[3'h2][19];	// src/main/scala/rocket/Multiplier.scala:50:16, :54:20
        isHi = _RANDOM[3'h2][20];	// src/main/scala/rocket/Multiplier.scala:50:16, :55:17
        resHi = _RANDOM[3'h2][21];	// src/main/scala/rocket/Multiplier.scala:50:16, :56:18
        divisor = {_RANDOM[3'h2][31:22], _RANDOM[3'h3][22:0]};	// src/main/scala/rocket/Multiplier.scala:50:16, :57:20
        remainder = {_RANDOM[3'h3][31:23], _RANDOM[3'h4], _RANDOM[3'h5][24:0]};	// src/main/scala/rocket/Multiplier.scala:57:20, :58:22
      `endif // RANDOMIZE_REG_INIT
    end // initial
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif // FIRRTL_AFTER_INITIAL
  `endif // ENABLE_INITIAL_REG_
  assign io_req_ready = _io_req_ready_output;	// src/main/scala/rocket/Multiplier.scala:179:25
  assign io_resp_valid = _io_resp_valid_output;	// src/main/scala/rocket/Multiplier.scala:178:42
  assign io_resp_bits_data = {hiOut, loOut};	// src/main/scala/rocket/Multiplier.scala:173:18, :174:18, :177:27
  assign io_resp_bits_tag = req_tag;	// src/main/scala/rocket/Multiplier.scala:50:16
endmodule

