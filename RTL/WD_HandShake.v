module WD_HandShake  (
    input  wire  ACLK,
    input  wire  ARESETN,
    input  wire  Valid_Signal,
    input  wire  Ready_Signal,
    input  wire  Last_Data   ,
    input  wire  HandShake_En,
    output reg   HandShake_Done  
);
    always @(posedge ACLK or negedge  ARESETN) begin
    if (!ARESETN) begin
        HandShake_Done<='b0;
    end else if(HandShake_En || HandShake_Done) begin
        HandShake_Done<='b0;
    end else if(Valid_Signal && Ready_Signal && Last_Data) begin
        HandShake_Done<='b1;
    end else begin
        HandShake_Done<='b0;
    end
end
endmodule




