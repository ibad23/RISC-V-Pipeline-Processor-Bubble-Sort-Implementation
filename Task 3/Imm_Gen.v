`timescale 1ns / 1ps

module Imm_Gen(instruc,imm_data);

//input
input [31:0] instruc; // 32 bits

//output
output reg [63:0] imm_data; // 64 bits

//always statement
always @(instruc) //parameters which trigger reevaluation- their values change
begin 

// conditions
// opcode differs in all three instruction types in 5th and 6th bits
// addi -- opcode 00 ; ld -- opcode 00 -- I type
// sd -- opcode 01 - S type
// beq -- opcode 1x --SB type

if (instruc[5]==0 && instruc[6] == 0) // I Format
imm_data[11:0] <= instruc[31:20]; // since in I type format the immediate field contains a 12 bit immediate in bits in the beginning


else if (instruc[5]==1 && instruc[6] == 0) // S Format
begin
imm_data[4:0] <= instruc[11:7]; // since S type contains two fields with divided imeediate field
imm_data[11:5] <= instruc[31:25]; 
end

else if (instruc[5]==1 && instruc[6] == 1)// SB Format 
begin
imm_data[11] <= instruc[31];
imm_data[10] <= instruc[7];
imm_data[9:4] <= instruc[30:25];
imm_data[3:0] <= instruc[11:8];
end
else // default case
begin
imm_data <= 64'h0000000000000000;
end
end

always @(*)
begin

//padding other bits based on the 11th bit
if (imm_data[11] == 1)
imm_data[63:12] <= 52'hfffffffffffff; 
else
imm_data[63:12] <= 52'b0;
end
endmodule