//==============================================================
//  Single-Cycle MIPS - Top Module
//==============================================================
module MIPI_Single_cyc_top #(
    parameter IMEM_DEPTH = 1024,   // بالبايت
    parameter DMEM_DEPTH = 1024    // بالبايت
)(
    input  logic        CLK,
    input  logic        rst_n,

    input  logic        imem_WE,
    input  logic [31:0] imem_WA,
    input  logic [31:0] imem_WD,

    output logic [31:0] PC_out,
    output logic [31:0] ALUResult_out
);

//--------------------------------------------------------------
// Internal signals
//--------------------------------------------------------------
// PC path
logic [31:0] PC, PCNext, PCPlus4, PCBranch, PCJump, PCBrMuxOut;
logic        PCSrc;

// Instruction
logic [31:0] Instr;

// Control signals
logic        MemtoReg, MemWrite, Branch, ALUSrc, RegDst, RegWrite, RegWrite_final, Jump;
logic [3:0]  ALUControl;
logic        Division_Error;

// Register file / datapath
logic [4:0]  WriteReg;
logic [31:0] RD1, RD2;
logic [31:0] SignImm;
logic [31:0] SrcA, SrcB, WriteData;
logic [31:0] ALUResult, ReadData, Result;
logic        Zero;


// // --------------------------------------------------------------
// // Instruction Opcode Type - Waveform Observation
// // --------------------------------------------------------------
// typedef enum logic [5:0] {
//     OP_R_TYPE = 6'b000000,
//     OP_BEQ   = 6'b000100,
//     OP_ADDI  = 6'b001000,
//     OP_J     = 6'b000010,
//     OP_LW    = 6'b100011,
//     OP_SW    = 6'b101011
// } opcode_t;

// // --------------------------------------------------------------
// // R-Type Function Type - Waveform Observation
// // --------------------------------------------------------------
// typedef enum logic [5:0] {
//     FUNCT_ADD  = 6'b100000,
//     FUNCT_SUB  = 6'b100010,
//     FUNCT_MUL  = 6'b011000,
//     FUNCT_DIV  = 6'b011010,
//     FUNCT_AND  = 6'b100100,
//     FUNCT_OR   = 6'b100101,
//     FUNCT_NAND = 6'b100110,
//     FUNCT_NOR  = 6'b100111,
//     FUNCT_XOR  = 6'b100001,
//     FUNCT_XNOR = 6'b100011,
//     FUNCT_EQ   = 6'b101000,
//     FUNCT_GT   = 6'b101010,
//     FUNCT_LT   = 6'b101011
// } funct_t;

// // Typed signals for waveform display
// opcode_t Op_Wave;
// funct_t  Funct_Wave;

// assign Op_Wave    = opcode_t'(Instr[31:26]);
// assign Funct_Wave = funct_t'(Instr[5:0]);


//--------------------------------------------------------------
// PC logic
//--------------------------------------------------------------
PC_cntrl u_pc (
    .CLK    (CLK),
    .rst_n  (rst_n),
    .PC_in  (PCNext),
    .PC_out (PC)
);

// PCPlus4 / PCBranch / PCJump
PC_plus4 u_pc_calc (
    .PC_in    (PC),
    .sign_imm (SignImm),
    .JTA      (Instr[25:0]),
    .PCPlus4  (PCPlus4),
    .PCBranch (PCBranch),
    .PCJump   (PCJump)
);

// PCSrc = Branch & Zero
assign PCSrc = Branch & Zero;

// Branch mux: 0 -> PCPlus4 , 1 -> PCBranch
MUX #(.width(32)) u_mux_pcsrc (
    .IN1 (PCBranch),
    .IN2 (PCPlus4),
    .sel (PCSrc),
    .out (PCBrMuxOut)
);

// Jump mux: 0 -> (branch mux output) , 1 -> PCJump
MUX #(.width(32)) u_mux_jump (
    .IN1 (PCJump),
    .IN2 (PCBrMuxOut),
    .sel (Jump),
    .out (PCNext)
);

//--------------------------------------------------------------
// Instruction Memory
//--------------------------------------------------------------
instruction_mem #(.Width(8), .Depth(IMEM_DEPTH)) u_imem (
    .CLK    (CLK),
    .WE     (imem_WE),
    .WA     (imem_WA),
    .WD     (imem_WD),
    .PC_Add (PC),
    .Instr  (Instr)
);

//--------------------------------------------------------------
// Control Unit   (Op = Instr[31:26] , Funct = Instr[5:0])
//--------------------------------------------------------------
control_unit u_ctrl (
    .Op         (Instr[31:26]),
    .Funct      (Instr[5:0]),
    .MemtoReg   (MemtoReg),
    .MemWrite   (MemWrite),
    .Branch     (Branch),
    .ALUControl (ALUControl),
    .ALUSrc     (ALUSrc),
    .RegDst     (RegDst),
    .RegWrite   (RegWrite),
    .Jump       (Jump)
);

//--------------------------------------------------------------
// WriteReg mux: RegDst=0 -> Instr[20:16] (rt) , RegDst=1 -> Instr[15:11] (rd)
//--------------------------------------------------------------
MUX #(.width(5)) u_mux_regdst (
    .IN1 (Instr[15:11]),
    .IN2 (Instr[20:16]),
    .sel (RegDst),
    .out (WriteReg)
);

//--------------------------------------------------------------
// Register File
//--------------------------------------------------------------
Reg_file u_rf (
    .CLK (CLK),
    .A1  (Instr[25:21]),
    .A2  (Instr[20:16]),
    .A3  (WriteReg),
    .WD3 (Result),
    .WE3 (RegWrite_final),
    .RD1 (RD1),
    .RD2 (RD2)
);

//--------------------------------------------------------------
// Sign Extend
//--------------------------------------------------------------
sign_ext u_se (
    .imm      (Instr[15:0]),
    .sign_imm (SignImm)
);

//--------------------------------------------------------------
// ALU
//--------------------------------------------------------------
assign SrcA      = RD1;
assign WriteData = RD2;

// SrcB mux: ALUSrc=0 -> RD2 , ALUSrc=1 -> SignImm
MUX #(.width(32)) u_mux_alusrc (
    .IN1 (SignImm),
    .IN2 (RD2),
    .sel (ALUSrc),
    .out (SrcB)
);

ALSU u_alu (
    .SrcA           (SrcA),
    .SrcB           (SrcB),
    .ALUControl     (ALUControl),
    .zero           (Zero),
    .Division_Error (Division_Error),
    .ALUResult      (ALUResult)
);

//--------------------------------------------------------------
// Data Memory
//--------------------------------------------------------------
Data_mem #(.Width(8), .Depth(DMEM_DEPTH)) u_dmem (
    .CLK (CLK),
    .WE  (MemWrite),
    .A   (ALUResult),
    .WD  (WriteData),
    .RD  (ReadData)
);

// Result mux: MemtoReg=0 -> ALUResult , MemtoReg=1 -> ReadData
MUX #(.width(32)) u_mux_memtoreg (
    .IN1 (ReadData),
    .IN2 (ALUResult),
    .sel (MemtoReg),
    .out (Result)
);

//--------------------------------------------------------------
// Observation ports
//--------------------------------------------------------------
assign PC_out        = PC;
assign ALUResult_out = ALUResult;
assign RegWrite_final = RegWrite & ~Division_Error;

endmodule