module WR_HandShake  (
    input  wire  ACLK,
    input  wire  ARESETN,
    input  wire  Valid_Signal,
    input  wire  Ready_Signal,
    input  wire  HandShake_En,
    output reg   HandShake_Done  
);
    always @(posedge ACLK or negedge  ARESETN) begin
    if (!ARESETN) begin
        HandShake_Done<='b1;
    end else if(HandShake_En) begin
        HandShake_Done<='b0;
    end else if(Valid_Signal && Ready_Signal) begin
        HandShake_Done<='b1;
    end
end

endmodule




