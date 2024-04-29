`timescale 1ns / 1ps

module RISCV_SCProcessor(
    input clk, 
    input reset
    );
    
    wire [63:0] PC_in, PC_out, ReadData, ReadData1, ReadData2, WriteData, ImmData, Result; 
    wire [63:0] shifted_data, Data_Out, Out1, Out2;
    wire [31:0] Instruction;
    wire [6:0] opcode, func7; 
    wire [2:0] func3;  
    wire [4:0] RS1, RS2, RD;
    wire [3:0] Operation, Funct;
    wire [1:0] ALUOp;
    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Zero, Branch, PCSrc, BranchSelect ; 
    
    wire [63:0] dm1, dm2, dm3, dm4, dm5;
    
    // IF
    Adder FOURADDER(PC_out, 64'd4, Out1);
    Mux_2x1 BRANCH(Out1, Out2, (Branch & BranchSelect), PC_in);
    Program_Counter PC(clk, reset, PC_in, PC_out);
    Instruction_Memory IM(PC_out, Instruction); 
    
    // ID    
    Instruction_Parser IP(Instruction, opcode, RD, func3, RS1, RS2, func7);
    Imm_Gen IG(Instruction, ImmData);
    Control_Unit CU(opcode, ALUOp, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite);
    Register_File RF(WriteData, RS1, RS2, RD, RegWrite, clk, reset, ReadData1, ReadData2);
    Branch_Unit BU(func3, ReadData1, ReadData2, BranchSelect);
    
    // EXE 
    assign shifted_data = ImmData << 1;
    Adder BRANCHADDER(PC_out, shifted_data, Out2); 
    Mux_2x1 ALUSRC(ReadData2, ImmData, ALUSrc, Data_Out);
    assign Funct = {Instruction[30],Instruction[14:12]};
    ALU_Control ALUC(ALUOp, Funct, Operation);
    ALU64 ALU(ReadData1, Data_Out, Operation, Result, Zero);
    
    // MEM
    Data_Memory DM(Result, ReadData2, clk, MemWrite, MemRead, ReadData, dm1, dm2, dm3, dm4, dm5);
    
    // WB
    Mux_2x1 WB(Result, ReadData, MemtoReg, WriteData);
    
endmodule