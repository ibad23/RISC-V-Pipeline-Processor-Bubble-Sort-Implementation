`timescale 1ns / 1ps

module Forwarding_Unit(ID_EX_RS1, ID_EX_RS2, EX_MEM_RD, EX_MEM_RegWrite, MEM_WB_RD, MEM_WB_RegWrite, Forward_A, Forward_B);

input [4:0] ID_EX_RS1, ID_EX_RS2, EX_MEM_RD, MEM_WB_RD;
input EX_MEM_RegWrite, MEM_WB_RegWrite;
output reg [1:0] Forward_A, Forward_B;

always @(*)
begin

// Forward A

//1a. EX/MEM.RegisterRd == ID/EX.RegisterRs1
if ((EX_MEM_RD == ID_EX_RS1) && (EX_MEM_RegWrite == 1) && (EX_MEM_RD != 0))
    Forward_A = 2'b10;
    
//2a. MEM/WB.RegisterRd == ID/EX.RegisterRs1
else if ((MEM_WB_RD == ID_EX_RS1) && (MEM_WB_RegWrite == 1) && (MEM_WB_RD != 0) && !(EX_MEM_RegWrite == 1 && EX_MEM_RD != 0 && EX_MEM_RD == ID_EX_RS1))
    Forward_A = 2'b01;
    
else
    Forward_A = 2'b00;

// Forward B

//1b. EX/MEM.RegisterRd == ID/EX.RegisterRs2
if ((EX_MEM_RD == ID_EX_RS2) && (EX_MEM_RegWrite == 1) && (EX_MEM_RD != 0))
    Forward_B = 2'b10;
    
//2b. MEM/WB.RegisterRd == ID/EX.RegisterRs2
else if ((MEM_WB_RD == ID_EX_RS2) && (MEM_WB_RegWrite == 1) && (MEM_WB_RD != 0) && !(EX_MEM_RegWrite == 1 && EX_MEM_RD != 0 && EX_MEM_RD == ID_EX_RS2))
    Forward_B = 2'b01;
    
else
    Forward_B = 2'b00;
end

endmodule