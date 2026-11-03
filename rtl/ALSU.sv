module ALSU(
    input  logic signed [31:0] SrcA,
    input  logic signed [31:0] SrcB,
    input  logic        [3:0]  ALUControl,
    output logic               zero,
    output logic               Division_Error,
    output logic signed [31:0] ALUResult
);

assign zero = ~| ALUResult;
assign Division_Error = (SrcB == 0) && (ALUControl == 4'b0011); // Set error flag for division by zero

always_comb begin
    case (ALUControl)
        4'b0000: begin
               ALUResult = SrcA+SrcB;
              end
        4'b0001: begin
               ALUResult = SrcA-SrcB;
              end
        4'b0010: begin
               ALUResult = SrcA*SrcB;
              end
        4'b0011: begin
               if (SrcB == 0) begin
                   ALUResult = 32'b0; // Handle division by zero
               end 
               else begin
                  ALUResult = SrcA/SrcB;
               end
              end
        4'b0100: begin
               ALUResult = SrcA & SrcB;
              end
        4'b0101: begin
               ALUResult = SrcA | SrcB;
              end
        4'b0110: begin
               ALUResult = ~ (SrcA & SrcB);
              end
        4'b0111: begin
               ALUResult = ~ (SrcA | SrcB);
              end
        4'b1000: begin
               ALUResult =  (SrcA ^ SrcB);
              end
        4'b1001: begin
               ALUResult = ~ (SrcA ^ SrcB);
              end
        4'b1010: begin
              if (SrcA==SrcB)
                 ALUResult = 32'b1;
              else
                 ALUResult = 32'b0;
              end
        4'b1011: begin
               if (SrcA>SrcB)
                 ALUResult = 32'b10;
               else
                 ALUResult = 32'b0;
              end
        4'b1100: begin
               if (SrcA<SrcB)
                 ALUResult = 32'b11;
               else
                 ALUResult = 32'b0;
              end
        default: begin
               ALUResult = SrcA;
             end
    endcase
end

endmodule