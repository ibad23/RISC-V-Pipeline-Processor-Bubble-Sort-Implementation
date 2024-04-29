`timescale 1ns / 1ps

module MEM_WB(clk, reset, 

EX_MEM_RegWrite, EX_MEM_MemToReg, // input control signals
ReadData, EX_MEM_ALU_Result, EX_MEM_RD, // inputs

MEM_WB_RegWrite, MEM_WB_MemToReg, // output control signals
MEM_WB_ReadData, MEM_WB_ALU_Result, MEM_WB_RD  // outputs
);

//inputs
input clk, reset, EX_MEM_RegWrite, EX_MEM_MemToReg; // 1 bit
input [4:0] EX_MEM_RD; // 5 bits
input [63:0] ReadData, EX_MEM_ALU_Result; // 64 bits

//outputs
output reg MEM_WB_RegWrite, MEM_WB_MemToReg; // 1 bit
output reg [4:0] MEM_WB_RD; //  5 bits
output reg [63:0] MEM_WB_ReadData, MEM_WB_ALU_Result; // 64 bits

//Assigning values
  always @(posedge clk) // triggers re-evaluation
  begin

    case(reset)
          1'b1: //reset on
            begin
                MEM_WB_RegWrite <= 0;
                MEM_WB_MemToReg <= 0;
                MEM_WB_ReadData <= 0;
                MEM_WB_ALU_Result <= 0;
                MEM_WB_RD <= 0;
            end

          1'b0: // reset off
            begin
                MEM_WB_RegWrite <= EX_MEM_RegWrite;
                MEM_WB_MemToReg <= EX_MEM_MemToReg;
                MEM_WB_ReadData <= ReadData;
                MEM_WB_ALU_Result <= EX_MEM_ALU_Result;
                MEM_WB_RD <=  EX_MEM_RD;
            end
   endcase

end
endmodule