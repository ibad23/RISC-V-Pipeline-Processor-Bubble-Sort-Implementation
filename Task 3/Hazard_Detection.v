`timescale 1ns / 1ps

module Hazard_Detection(ID_EX_RD, IF_ID_RS1, IF_ID_RS2, ID_EX_MemRead, ID_EX_Control_Mux_Out, IF_ID_Write, PCWrite);

input [4:0] ID_EX_RD, IF_ID_RS1, IF_ID_RS2;
input ID_EX_MemRead;
output reg ID_EX_Control_Mux_Out;
output reg IF_ID_Write, PCWrite;

always @(*)
begin

    if (ID_EX_MemRead && (ID_EX_RD == IF_ID_RS1 || ID_EX_RD == IF_ID_RS2)) // Load Use Hazard then Stall!
    begin
        ID_EX_Control_Mux_Out = 0;
        IF_ID_Write = 0;
        PCWrite = 0;
    end
    else
    begin
        ID_EX_Control_Mux_Out = 1;
        IF_ID_Write = 1;
        PCWrite = 1;
    end
end
endmodule