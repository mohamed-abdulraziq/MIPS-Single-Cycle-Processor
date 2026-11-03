module control_unit (
    input  logic [5:0]  Op,
    input  logic [5:0]  Funct,
    output logic        MemtoReg,
    output logic        MemWrite,
    output logic        Branch,
    output logic [3:0]  ALUControl,
    output logic        ALUSrc,
    output logic        RegDst,
    output logic        RegWrite,
    output logic        Jump
);

// --------------------------------------------------------------
// ALU Operation Type
// --------------------------------------------------------------
typedef enum logic [1:0] {
    ALUOP_DEFAULT  = 2'b00,
    ALUOP_BEQ       = 2'b01,
    ALUOP_RTYPE     = 2'b10,
    ALUOP_RESERVED  = 2'b11
} aluop_t;

aluop_t ALUOp;

// ---------------- Main Decoder ----------------
always_comb begin
    ALUOp       = ALUOP_DEFAULT;
    MemtoReg    = 1'b0;
    MemWrite    = 1'b0;
    Branch      = 1'b0;
    ALUSrc      = 1'b0;
    RegDst      = 1'b0;
    RegWrite    = 1'b0;
    Jump        = 1'b0;

    case (Op)
        6'b000000: begin  // R-type
            ALUOp  = ALUOP_RTYPE;
            RegDst = 1'b1;
            // Enable register write only for supported R-type instructions.
            case (Funct)
                6'b100000, // ADD
                6'b100010, // SUB
                6'b011000, // MUL
                6'b011010, // DIV
                6'b100100, // AND
                6'b100101, // OR
                6'b100110, // NAND
                6'b100111, // NOR
                6'b100001, // XOR
                6'b100011, // XNOR
                6'b101000, // EQ
                6'b101010, // GT
                6'b101011: // LT
                    RegWrite = 1'b1;
                default:
                    RegWrite = 1'b0;
            endcase
        end
        6'b100011: begin  // lw
            ALUOp    = ALUOP_DEFAULT;
            MemtoReg = 1'b1;
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
        end
        6'b101011: begin  // sw
            ALUOp    = ALUOP_DEFAULT;
            MemWrite = 1'b1;
            ALUSrc   = 1'b1;
        end
        6'b000100: begin  // beq
            ALUOp  = ALUOP_BEQ;
            Branch = 1'b1;
        end
        6'b001000: begin  // addi
            ALUOp    = ALUOP_DEFAULT;
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
        end
        6'b000010: begin  // j
            Jump = 1'b1;
        end

        default: ;
    endcase
end

// ---------------- ALU Decoder ----------------
always_comb begin
    casez ({ALUOp, Funct})

        8'b00_??????: ALUControl = 4'b0000; // ADD
        8'b01_??????: ALUControl = 4'b0001; // SUB

        8'b1?_100000: ALUControl = 4'b0000; // ADD
        8'b1?_100010: ALUControl = 4'b0001; // SUB
        8'b1?_011000: ALUControl = 4'b0010; // MUL
        8'b1?_011010: ALUControl = 4'b0011; // DIV
        8'b1?_100100: ALUControl = 4'b0100; // AND
        8'b1?_100101: ALUControl = 4'b0101; // OR
        8'b1?_100110: ALUControl = 4'b0110; // NAND
        8'b1?_100111: ALUControl = 4'b0111; // NOR
        8'b1?_100001: ALUControl = 4'b1000; // XOR
        8'b1?_100011: ALUControl = 4'b1001; // XNOR
        8'b1?_101000: ALUControl = 4'b1010; // EQ
        8'b1?_101010: ALUControl = 4'b1011; // GT
        8'b1?_101011: ALUControl = 4'b1100; // LT

        default: ALUControl = 4'b0000;
    endcase
end

endmodule
