module PC_plus4 (
    input  logic [31:0]  PC_in,
    input  logic [31:0]  sign_imm,
    input  logic [25:0]  JTA,
    output logic [31:0]  PCPlus4,
    output logic [31:0]  PCBranch,
    output logic [31:0]  PCJump
);

assign PCPlus4 = PC_in + 4;

assign PCBranch = (sign_imm << 2) + PCPlus4;

assign PCJump = {PCPlus4[31:28], JTA, 2'b00};

endmodule