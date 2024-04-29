`timescale 1ns / 1ps
module Program_Counter(clk, reset, PC_In, PC_Out, PCWrite);
// inputs
input clk, reset;
input [63:0] PC_In;
input PCWrite;
// outputs
output reg [63:0] PC_Out;

initial
	PC_Out=64'd0;
	
always @ (posedge clk) // posedge reset?
       
       if (reset == 1'b1) PC_Out = 64'b0;
	   else if (PCWrite == 1'b0) PC_Out = PC_Out;
	   else PC_Out = PC_In;

endmodule