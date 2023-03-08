module BReady_MUX_2_1  (
    input  wire     Selected_Slave,
    input  wire     S00_AXI_bready,
    input  wire     S01_AXI_bready,
    output reg      Sele_S_AXI_bready
);

always @(*) begin
    if (!Selected_Slave) begin
        Sele_S_AXI_bready=S00_AXI_bready;
    end else begin
        Sele_S_AXI_bready=S01_AXI_bready;
    end

end
    
endmodule