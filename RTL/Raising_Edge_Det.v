module Raising_Edge_Det  (
    input  wire ACLK,
    input  wire ARESETN,
    input  wire Test_Singal,
    output reg  Raisung
);

reg reg_Test_Signal;
always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        reg_Test_Signal<='b0;
    end else begin
        reg_Test_Signal<=Test_Singal;
    end
end

always @(*) begin
    Raisung=(reg_Test_Signal ^ Test_Singal) & (Test_Singal);
end
endmodule