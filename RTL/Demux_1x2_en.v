module Demux_1x2_en #(parameter width = 31) (
    //---------------------- Input Ports ----------------------
    input wire [width:0] in,

    input wire select,

    input wire enable,

    //---------------------- Output Ports ----------------------
    output reg [width:0] out1,out2

);
    
//---------------------- Code Start ----------------------
always @ (*)begin
    if(enable)begin
        case (select)
            1'b0: begin
                out1 = in;
                out2 = 0;
            end
            1'b1: begin
                out1 = 0;
                out2 = in;
            end
        endcase
    end
    else begin
        out1 = 1'bx;
        out2 = 1'bx;
    end
end

endmodule

