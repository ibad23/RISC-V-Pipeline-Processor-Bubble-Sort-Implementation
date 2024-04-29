`timescale 1ns / 1ps

module EX_MEM(clk, reset, 

ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_Branch, // input control signals
Adder_out, ALU_Result, Zero, ID_EX_ReadData2, ID_EX_RD,  // inputs

EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemToReg, EX_MEM_MemWrite, EX_MEM_Branch, // output control signals
EX_MEM_Adder_out, EX_MEM_ALU_Result, EX_MEM_Zero, EX_MEM_ReadData2, EX_MEM_RD); // outputs

//inputs
input clk, reset, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_Branch, Zero; // 1 bit
input [4:0] ID_EX_RD; // 5 bits
input [63:0] Adder_out, ALU_Result, ID_EX_ReadData2; // 64 bits

//outputs
output reg  EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemToReg, EX_MEM_MemWrite, EX_MEM_Branch, EX_MEM_Zero; // 1 bit
output reg [4:0] EX_MEM_RD; // 5 bits
output reg [63:0] EX_MEM_Adder_out, EX_MEM_ALU_Result, EX_MEM_ReadData2; // 64 bits

// input addermuxselectin,

//Assigning values
always @(posedge clk) // triggers re-evaluation
begin
        case (reset)
        1'b1: // reset on
        begin
            EX_MEM_RegWrite <= 0;
            EX_MEM_MemRead <= 0;
            EX_MEM_MemToReg <= 0;
            EX_MEM_MemWrite <= 0;
            EX_MEM_Branch <= 0;
            EX_MEM_Zero <= 0;
            EX_MEM_RD <= 0;
            EX_MEM_Adder_out <= 0;
            EX_MEM_ALU_Result <= 0;
            EX_MEM_ReadData2 <= 0;
        end

//        1'b0: // reset off
        default:
        begin
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemToReg <= ID_EX_MemToReg;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_Branch <= ID_EX_Branch;
            EX_MEM_Zero <= Zero;
            EX_MEM_RD <= ID_EX_RD;
            EX_MEM_Adder_out <= Adder_out;
            EX_MEM_ALU_Result <= ALU_Result;
            EX_MEM_ReadData2 <= ID_EX_ReadData2;
        end
    endcase

end
endmodule