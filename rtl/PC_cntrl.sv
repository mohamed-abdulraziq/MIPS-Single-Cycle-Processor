module PC_cntrl (
    input  logic         CLK,
    input  logic         rst_n,
    input  logic [31:0]  PC_in,
    output logic [31:0]  PC_out
);

always_ff @(posedge CLK or negedge rst_n) begin
    if (~rst_n) begin
        PC_out <= 0;
    end
    else begin
        PC_out <= PC_in;
    end
end

endmodule