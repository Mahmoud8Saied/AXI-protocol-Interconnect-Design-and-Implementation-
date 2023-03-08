module AW_HandShake_Checker
(
    input  wire  ACLK,
    input  wire  ARESETN,
    input  wire  Valid_Signal,
    input  wire  Ready_Signal,
    input  wire  Channel_Request,
    output reg   HandShake_Done 
);

always @(posedge ACLK or negedge  ARESETN) begin
    if (!ARESETN) begin
        HandShake_Done<='b1;
    end else if(Channel_Request) begin
        HandShake_Done<='b0;
        
    end else if(Valid_Signal && Ready_Signal) begin
        HandShake_Done<='b1;
    end
end



endmodule