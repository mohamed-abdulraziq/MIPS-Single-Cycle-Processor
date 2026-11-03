module Data_mem #(parameter Width = 8, parameter Depth = 1024)(
    input  logic                   CLK,
    input  logic                   WE,
    input  logic [31:0]            A,
    input  logic [(4*Width)-1:0]   WD,
    output logic [(4*Width)-1:0]   RD
);

`ifdef SYNTHESIS
logic [Width-1:0] data_mem [Depth-1:0];
`else
logic [Width-1:0] data_mem [Depth-1:0] = '{default: '0};
`endif

//Asynch read
assign RD = {data_mem[A+3],data_mem[A+2],data_mem[A+1],data_mem[A]};

//Synch write
always_ff @(posedge CLK) begin
    if (WE) begin
        {data_mem[A+3],data_mem[A+2],data_mem[A+1],data_mem[A]} <= WD;
    end
end

endmodule
