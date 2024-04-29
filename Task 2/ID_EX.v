`timescale 1ns / 1ps

module ID_EX (clk, reset, 

RegWrite, MemRead, MemToReg, MemWrite, Branch, ALUOp, ALUSrc, // control signals
IF_ID_PC_out, ReadData1, ReadData2, ImmData, RS1, RS2, RD, Funct, // inputs

ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_Branch, ID_EX_ALUOp, ID_EX_ALUSrc, // control signals
ID_EX_PC_out, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_ImmData, ID_EX_RS1, ID_EX_RS2, ID_EX_RD, ID_EX_Funct); // outputs

//inputs
input clk, reset, RegWrite, MemRead, MemToReg, MemWrite, Branch, ALUSrc; //1 bit
input [1:0] ALUOp; // 2 bits
input [63:0] IF_ID_PC_out, ReadData1, ReadData2, ImmData; // 64 bits
input [3:0] Funct; // 4 bits
input [4:0] RS1, RS2, RD; // 5 bits

//outputs
output reg ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_Branch, ID_EX_ALUSrc; // 1 bit
output reg [1:0] ID_EX_ALUOp; //2 bits
output reg [63:0] ID_EX_PC_out, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_ImmData; // 64 bits
output reg [3:0] ID_EX_Funct; // 4 bits
output reg [4:0] ID_EX_RS1, ID_EX_RS2, ID_EX_RD ; // 5 bits

//Assigning values
always @(posedge clk) // -- triggers re-evaluation
begin
    
    case (reset)
    
        1'b1: // when reset is on
        begin
            ID_EX_RegWrite <= 0;
            ID_EX_MemRead <= 0;
            ID_EX_MemToReg <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_Branch <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_ALUOp <= 0; // or <= 2'b0;
            ID_EX_PC_out <= 0;
            ID_EX_ReadData1 <= 0; // or <= 64'd0;
            ID_EX_ReadData2 <= 0; // or <= 64'd0;
            ID_EX_ImmData <= 0; // or <= 64'd0;
            ID_EX_Funct <= 0; // or <= 4'd0;
            ID_EX_RS1 <= 0; // or <= 5'b0;
            ID_EX_RS2 <= 0; // or <= 5'b0;
            ID_EX_RD <= 0; // or <= 5'b0;
        end
        
        1'b0: // when reset is 0
        begin
            ID_EX_RegWrite <= RegWrite;
            ID_EX_MemRead <= MemRead;
            ID_EX_MemToReg <= MemToReg;
            ID_EX_MemWrite <= MemWrite;
            ID_EX_Branch <= Branch;
            ID_EX_ALUSrc <= ALUSrc;
            ID_EX_ALUOp <= ALUOp;
            ID_EX_PC_out <= IF_ID_PC_out;
            ID_EX_ReadData1 <= ReadData1;
            ID_EX_ReadData2 <= ReadData2;
            ID_EX_ImmData <= ImmData;
            ID_EX_Funct <= Funct;
            ID_EX_RS1 <= RS1;
            ID_EX_RS2 <= RS2;
            ID_EX_RD <= RD;
        end     
    endcase 
      
end
endmodule