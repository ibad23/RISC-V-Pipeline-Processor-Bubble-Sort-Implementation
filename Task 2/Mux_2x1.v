`timescale 1ns / 1ps

module Mux_2x1(a, b, sel, data_out); //defining func parameters

//Inputs -- 3 inputs: 2 data inputs & 1 selection line
input [63:0] a; // 64 bits
input [63:0] b; //64 bits
input sel; // 1 bit

//outputs -- 1 output: 64 bit
output reg [63:0] data_out;

//always statement
always @(a,b,sel) //parameters which trigger reevaluation- their values change
begin

case(sel)  //2 inputs-  2 possibilities
    0 : data_out <= a; //if sel = 0 then data is a else b
    1:  data_out <= b; 
endcase

end
endmodule