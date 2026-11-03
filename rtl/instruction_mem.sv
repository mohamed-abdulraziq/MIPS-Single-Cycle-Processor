module instruction_mem #(parameter Width = 8, parameter Depth = 1024)(
    input  logic                  CLK,
    input  logic                  WE,
    input  logic [31:0]           WA,
    input  logic [(4*Width)-1:0]  WD,
    input  logic [31:0]           PC_Add,
    output logic [(4*Width)-1:0]  Instr
);

`ifdef SYNTHESIS
logic [Width-1:0] instr_mem [Depth-1:0];
`else
logic [Width-1:0] instr_mem [Depth-1:0] = '{default: '0};
`endif

//Asynch read
assign Instr = {instr_mem[PC_Add+3],instr_mem[PC_Add+2],instr_mem[PC_Add+1],instr_mem[PC_Add]};

//Synch write
always_ff @(posedge CLK) begin
    if (WE) begin
        {instr_mem[WA+3],instr_mem[WA+2],instr_mem[WA+1],instr_mem[WA]} <= WD;
    end
end

endmodule
