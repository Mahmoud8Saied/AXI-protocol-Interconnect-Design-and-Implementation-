module Mux_2x1_en #(parameter width = 31)
(
//---------------------- Input Ports ----------------------
input wire [width:0] in1,in2,

input wire sel,

input wire enable,

//---------------------- Output Ports ----------------------
output reg [width:0] out

);

//---------------------- Code Start ----------------------
always @ (*)begin
    if(enable)begin
        case (sel)
        1'b0: out = in1; //select first input if selection line has 0 on it
        1'b1: out = in2; //select second input if selection line has 1 on it
        endcase
    end
    else begin
        out = 0;
    end
end
endmodule

