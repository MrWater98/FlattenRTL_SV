// Parameterized Adder Module with an additional shift parameter
module Adder #(
    parameter WIDTH = 8,  // Default bit width is 8 bits
    parameter SHIFT = 0   // Default shift amount is 0 bits
)(a,b,sum);
    input [WIDTH-1:0] a;
    input [WIDTH-1:0] b;     // Two inputs
    output [WIDTH-1+SHIFT:0] sum; // Output sum with shift

// Compute the sum of the inputs and apply shift
assign sum = (a + b) << SHIFT;

endmodule

// Top Level Module
module TopModule #(
    parameter adder1_WIDTH=8,
    parameter adder1_SHIFT=0,
    parameter adder2_WIDTH=16,
    parameter adder2_SHIFT=1)(a1, b1, a2, b2, sum1, sum2);
    input [7:0] a1, b1;         // Inputs for the first adder
    input [15:0] a2, b2;         // Inputs for the second adder
    output [7:0] sum1;           // Output for the first adder (no shift applied, acts as before)
    output [15+1:0] sum2;         // Output for the second adder with an extra bit to accommodate for shift



// Instantiate the first adder with a width of 8 bits and no shift
    wire[adder1_WIDTH-1:0] adder1_a;
    wire[adder1_WIDTH-1:0] adder1_b;
    wire[adder1_WIDTH-1+adder1_SHIFT:0] adder1_sum;
    wire[adder2_WIDTH-1:0] adder2_a;
    wire[adder2_WIDTH-1:0] adder2_b;
    wire[adder2_WIDTH-1+adder2_SHIFT:0] adder2_sum;

    assign  adder1_sum =( adder1_a + adder1_b )<< adder1_SHIFT ;
    

// Instantiate the second adder with a width of 16 bits and a shift of 1 bit

    assign  adder1_sum =( adder1_a + adder1_b )<< adder1_SHIFT ;
    assign adder1_a = a1;
    assign adder1_b = b1;
    assign sum1 = adder1_sum;
    assign adder2_a = a2;
    assign adder2_b = b2;
    assign sum2 = adder2_sum;
    

endmodule

