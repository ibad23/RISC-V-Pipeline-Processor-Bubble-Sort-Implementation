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
    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Zero, Branch;
    
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
    wire [63:0] reg1, reg2, reg3; // x18, x20, x21
    
    // Forwarding wires
    wire [1:0] Forward_A, Forward_B;
    wire [63:0] Forward_A_Output, Forward_B_Output;
    
    // Load Use Data Hazard Detection Unit wires
    wire ID_EX_Control_Mux_Out, IF_ID_Write, PCWrite;
    
    // Branch Hazard wires
    wire Branch_Mux;
    wire Is_Greater, Final_Zero;
    
    assign Branch_Mux = EX_MEM_Zero & EX_MEM_Branch;

    // IF
    Adder FOURADDER(64'd4, PC_out, Out1);
    Mux_2x1 BRANCH(Out1, EX_MEM_Adder_out, Branch_Mux, PC_in);
    Program_Counter PC(clk, reset, PC_in, PC_out, PCWrite);
    Instruction_Memory IM(PC_out, Instruction); 
    
    IF_ID Pipeline1(clk, Branch_Mux, // reset 
             PC_out, Instruction, IF_ID_PC_out, IF_ID_Instruction, IF_ID_Write);
    
    // ID 
    Instruction_Parser IP(IF_ID_Instruction, opcode, RD, func3, RS1, RS2, func7);
    assign Funct = {IF_ID_Instruction[30],IF_ID_Instruction[14:12]};
    
    Hazard_Detection LoadUseHazard(ID_EX_RD, RS1, RS2, ID_EX_MemRead, ID_EX_Control_Mux_Out, IF_ID_Write, PCWrite);

    Imm_Gen IG(IF_ID_Instruction, ImmData);
    Control_Unit CU(opcode, ALUOp, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ID_EX_Control_Mux_Out); // Mux Inside
     
    Register_File RF(WriteData, RS1, RS2, MEM_WB_RD, MEM_WB_RegWrite, clk, reset, ReadData1, ReadData2, 
    reg1, reg2, reg3);
    
    ID_EX Pipeline2(clk, Branch_Mux, // reset 
            RegWrite, MemRead, MemtoReg, MemWrite, Branch, ALUOp, ALUSrc, // control signals
            IF_ID_PC_out, ReadData1, ReadData2, ImmData, RS1, RS2, RD, Funct, // inputs
            ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_Branch, ID_EX_ALUOp, ID_EX_ALUSrc, // control signals
            ID_EX_PC_out, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_ImmData, ID_EX_RS1, ID_EX_RS2, ID_EX_RD, ID_EX_Funct
            ); // outputs
                    
    // EXE 
    assign shifted_data = ID_EX_ImmData << 1;
    Adder BRANCHADDER(ID_EX_PC_out, shifted_data, Adder_out); 
    ALU_Control ALUC(ID_EX_ALUOp, ID_EX_Funct, Operation);
    
    Forwarding_Unit F_Unit(ID_EX_RS1, ID_EX_RS2, EX_MEM_RD, EX_MEM_RegWrite, MEM_WB_RD, MEM_WB_RegWrite, Forward_A, Forward_B);
    Mux_3x1 ForwardA_Mux(ID_EX_ReadData1, WriteData, EX_MEM_ALU_Result, Forward_A, Forward_A_Output);
    Mux_3x1 ForwardB_Mux(ID_EX_ReadData2, WriteData, EX_MEM_ALU_Result, Forward_B, Forward_B_Output);
    
    Mux_2x1 MuxALUSrc(Forward_B_Output, ID_EX_ImmData, ID_EX_ALUSrc, Data_Out);
    ALU64 ALU(Forward_A_Output, Data_Out, Operation, ALU_Result, Zero, Is_Greater);
    assign Final_Zero = ID_EX_Funct[2] ? Is_Greater : Zero;
    
    EX_MEM Pipeline3(clk, Branch_Mux, // reset 
            ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_Branch, // input control signals
            Adder_out, ALU_Result, Final_Zero, Forward_B_Output, ID_EX_RD,  // inputs
            // BranchSelect instead of Zero
            EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_Branch, // output control signals
            EX_MEM_Adder_out, EX_MEM_ALU_Result, EX_MEM_Zero, EX_MEM_ReadData2, EX_MEM_RD // outputs
            );
    
    // MEM
    Data_Memory DM(EX_MEM_ALU_Result, EX_MEM_ReadData2, clk, EX_MEM_MemWrite, EX_MEM_MemRead, ReadData,
    dm1, dm2, dm3, dm4, dm5);
    
    MEM_WB Pipeline4(clk, 1'b0, // resest 
            EX_MEM_RegWrite, EX_MEM_MemtoReg, // input control signals
            ReadData, EX_MEM_ALU_Result, EX_MEM_RD, // inputs
            MEM_WB_RegWrite, MEM_WB_MemtoReg, // output control signals
            MEM_WB_ReadData, MEM_WB_ALU_Result, MEM_WB_RD  // outputs
            );
    
    // WB
    Mux_2x1 WB(MEM_WB_ALU_Result, MEM_WB_ReadData, MEM_WB_MemtoReg, WriteData);
    
endmodule