module Reg_file (
    input  logic        CLK,
    input  logic [4:0]  A1,
    input  logic [4:0]  A2,
    input  logic [4:0]  A3,
    input  logic [31:0] WD3,
    input  logic        WE3,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

`ifdef SYNTHESIS
logic [31:0] REG_FILE [31:0];
`else
logic [31:0] REG_FILE [31:0] = '{default: 32'd0};
`endif

assign RD1 = (A1 != 0) ? REG_FILE[A1] : 0;
assign RD2 = (A2 != 0) ? REG_FILE[A2] : 0;

always_ff @(posedge CLK) begin
    // Prevent writes to R0 to keep it hardwired to zero.
    if (WE3 && A3 != 0) begin
        REG_FILE[A3] <= WD3;
    end
end

endmodule