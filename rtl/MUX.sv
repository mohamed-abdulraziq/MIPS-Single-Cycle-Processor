// sel = 1 -> IN1 , sel = 0 -> IN2
module MUX #(parameter width = 32)(
    input  logic [width-1:0] IN1,
    input  logic [width-1:0] IN2,
    input  logic             sel,
    output logic [width-1:0] out
);

assign out = sel ? IN1 : IN2;

endmodule