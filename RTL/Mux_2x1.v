module Mux_2x1 #(parameter width = 31)
(
//---------------------- Input Ports ----------------------
input wire [width:0] in1,in2,

input wire sel,

//---------------------- Output Ports ----------------------
output reg [width:0] out

);

//---------------------- Code Start ----------------------
always @ (*)begin
case (sel)
1'b0: out = in1; //select first input if selection line has 0 on it
1'b1: out = in2; //select second input if selection line has 1 on it
endcase
end
endmodule
