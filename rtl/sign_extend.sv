module sign_ext (
    input  logic [15:0] imm,
    output logic [31:0] sign_imm
);

assign sign_imm = {{16{imm[15]}},imm};

endmodule