`timescale 1ns / 1ps

module RISCV_SCProcessor(
    input clk, 
    input reset
    );
    // Single Cycle wires
    wire [63:0] PC_in, PC_out, ReadData, ReadData1, ReadData2, WriteData, ImmData, ALU_Result; 
    wire [63:0] shifted_data, Data_Out, Out1, Adder_out;
    wire [31:0] Instruction;
    wire [6:0] opcode, func7; 
    wire [2:0] func3;  
    wire [4:0] RS1, RS2, RD;
    wire [3:0] Operation, Funct;
    wire [1:0] ALUOp;
    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Zero, Branch, BranchSelect ; // PCSrc 
    
    // IF_ID wires
    wire [63:0] IF_ID_PC_out;
    wire [31:0] IF_ID_Instruction;
    
    // ID_EX wires
    wire ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_Branch, ID_EX_ALUSrc; // 1 bit
    wire [1:0] ID_EX_ALUOp; //2 bits
    wire [63:0] ID_EX_PC_out, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_ImmData; // 64 bits
    wire [3:0] ID_EX_Funct; // 4 bits
    wire [4:0] ID_EX_RS1, ID_EX_RS2, ID_EX_RD ; // 5 bits
    
    // EX_MEM wires
    wire  EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_Branch, EX_MEM_Zero; // 1 bit
    wire [4:0] EX_MEM_RD; // 5 bits
    wire [63:0] EX_MEM_Adder_out, EX_MEM_ALU_Result, EX_MEM_ReadData2; // 64 bits
    
    // MEM_WB wires
    wire MEM_WB_RegWrite, MEM_WB_MemtoReg; // 1 bit
    wire [4:0] MEM_WB_RD; //  5 bits
    wire [63:0] MEM_WB_ReadData, MEM_WB_ALU_Result; // 64 bits
    
    // Checking Data Memory wires
    wire [63:0] dm1, dm2, dm3, dm4, dm5;
    
    // Checking Register File wires
    wire [63:0] reg1, reg2, reg3;
    
    // IF
    Adder FOURADDER(64'd4, PC_out, Out1);
//    Mux_2x1 BRANCH(Out1, EX_MEM_Adder_out, (Branch & BranchSelect), PC_in);
     Mux_2x1 BRANCH(Out1, EX_MEM_Adder_out, (EX_MEM_Branch & EX_MEM_Zero), PC_in);
    Program_Counter PC(clk, reset, PC_in, PC_out);
    Instruction_Memory IM(PC_out, Instruction); 
    
    IF_ID Pipeline1(clk, reset, PC_out, Instruction, IF_ID_PC_out, IF_ID_Instruction);
    
    // ID    
    assign Funct = {IF_ID_Instruction[30],IF_ID_Instruction[14:12]};
    Instruction_Parser IP(IF_ID_Instruction, opcode, RD, func3, RS1, RS2, func7);
    Imm_Gen IG(IF_ID_Instruction, ImmData);
    Control_Unit CU(opcode, ALUOp, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite);
    Register_File RF(WriteData, RS1, RS2, MEM_WB_RD, MEM_WB_RegWrite, clk, reset, ReadData1, ReadData2, reg1, reg2, reg3);
    Branch_Unit BU(func3, ReadData1, ReadData2, BranchSelect);
    
    ID_EX Pipeline2(clk, reset, 
            RegWrite, MemRead, MemtoReg, MemWrite, Branch, ALUOp, ALUSrc, // control signals
            IF_ID_PC_out, ReadData1, ReadData2, ImmData, RS1, RS2, RD, Funct, // inputs
            ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_Branch, ID_EX_ALUOp, ID_EX_ALUSrc, // control signals
            ID_EX_PC_out, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_ImmData, ID_EX_RS1, ID_EX_RS2, ID_EX_RD, ID_EX_Funct
            ); // outputs
                    
    // EXE 
    assign shifted_data = ID_EX_ImmData << 1;
    Adder BRANCHADDER(ID_EX_PC_out, shifted_data, Adder_out); 
    Mux_2x1 MuxALUSrc(ID_EX_ReadData2, ID_EX_ImmData, ID_EX_ALUSrc, Data_Out);
    ALU_Control ALUC(ID_EX_ALUOp, ID_EX_Funct, Operation);
    ALU64 ALU(ID_EX_ReadData1, Data_Out, Operation, ALU_Result, Zero);
    
    EX_MEM Pipeline3(clk, reset, 
            ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_Branch, // input control signals
            Adder_out, ALU_Result, BranchSelect, ID_EX_ReadData2, ID_EX_RD,  // inputs
            // BranchSelect instead of Zero
            EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_Branch, // output control signals
            EX_MEM_Adder_out, EX_MEM_ALU_Result, EX_MEM_Zero, EX_MEM_ReadData2, EX_MEM_RD // outputs
            );
    
    // MEM
    Data_Memory DM(EX_MEM_ALU_Result, EX_MEM_ReadData2, clk, EX_MEM_MemWrite, EX_MEM_MemRead, ReadData,
    dm1, dm2, dm3, dm4, dm5);
    
    MEM_WB Pipeline4(clk, reset, 
            EX_MEM_RegWrite, EX_MEM_MemtoReg, // input control signals
            ReadData, EX_MEM_ALU_Result, EX_MEM_RD, // inputs
            MEM_WB_RegWrite, MEM_WB_MemtoReg, // output control signals
            MEM_WB_ReadData, MEM_WB_ALU_Result, MEM_WB_RD  // outputs
            );
    
    // WB
    Mux_2x1 WB(MEM_WB_ALU_Result, MEM_WB_ReadData, MEM_WB_MemtoReg, WriteData);
    
endmodule