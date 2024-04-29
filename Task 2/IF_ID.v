`timescale 1ns / 1ps

module IF_ID(clk, reset, PC_out, Instruction, IF_ID_PC_out, IF_ID_Instruction); 

//inputs
input clk, reset; // 1 bit 
input [31:0] Instruction; //32 bits
input [63:0] PC_out; //64 bits

//outputs
output reg [31:0] IF_ID_Instruction; //32 bits
output reg [63:0] IF_ID_PC_out; //64 bits

//Assigning values
always @ (posedge clk) // triggers re-evaluation on positive clk edge or active Flush signal
begin
    case (reset)
        1'b1: // reset on -- resetting 
            begin
            IF_ID_Instruction <= 0;
            IF_ID_PC_out <= 0;
            end
        1'b0: // reset off -- setting values
            begin
            IF_ID_Instruction <= Instruction;
            IF_ID_PC_out <= PC_out;
            end
    endcase
end
endmodule