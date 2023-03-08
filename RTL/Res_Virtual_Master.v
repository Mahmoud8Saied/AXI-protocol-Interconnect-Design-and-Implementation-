module Res_Virtual_Master #(
    parameter AXI4_Aw_len='d8,AXI3_Aw_len='d4
) (
    input  wire  ACLK,
    input  wire  ARESETN,
    input  wire  Load_The_Original_Signals,
    input  wire  [(AXI4_Aw_len/'d2)-1:0]  Num_Of_Compl_Bursts,
    input  wire [(AXI4_Aw_len/'d2)-1:0] Rem,
    input  wire [1:0]     Slave_bresp,
    input  wire   Slave_bvalid,
    input  wire   Sele_S_AXI_bready,
    input  wire   Res_HandShake,
    input  wire   Trans_Split,
    output reg    Disconnect_Master,
    output reg                      Virtual_Sele_S_AXI_bready,
    output wire [1:0]                Virtual_M00_AXI_bresp,
    output wire                      Virtual_M00_AXI_bvalid

);
    wire  Enable;//!
    reg  [1:0]     Virtual_Master_bresp;
    reg  [(AXI4_Aw_len/2)-1:0]       Num_of_Resp;
    reg Virtual_Master_bready;
    reg Load;

    always @(posedge ACLK or negedge ARESETN  ) begin
        if (!ARESETN) begin
            Load<='b0;
        end else begin
            Load<=Load_The_Original_Signals;
        end
    end

    always @(posedge ACLK or negedge ARESETN ) begin
        if (!ARESETN) begin
            Num_of_Resp<='b0;
        end else if(Load ) begin //! 
            if (Rem != 'b0) begin
                Num_of_Resp<=Num_Of_Compl_Bursts+'b1;
            end else begin
                Num_of_Resp<=Num_Of_Compl_Bursts;
            end
        end else if (Res_HandShake && (|Num_of_Resp) ) begin //!
            Num_of_Resp<=Num_of_Resp-'b1;
        end
    end

    always @(posedge ACLK or negedge ARESETN ) begin
        if (!ARESETN) begin
            Virtual_Master_bresp<='b0;
        end else if(Load && Enable) begin //! 
            Virtual_Master_bresp<='b0;
        end else if ((Virtual_Master_bresp=='b00) )begin
            Virtual_Master_bresp<=Slave_bresp;
        end
    end
    
    always @(*) begin
        if (Slave_bvalid) begin
            Virtual_Master_bready='b1;
        end else begin
            Virtual_Master_bready='b0;
        end
    end

assign Virtual_M00_AXI_bvalid=Slave_bvalid;
assign Virtual_M00_AXI_bresp=Virtual_Master_bresp;

    always @(*) begin
        
            if (Num_of_Resp >'d1) begin
                Virtual_Sele_S_AXI_bready=Virtual_Master_bready;
                Disconnect_Master='b1;
            end else begin
                Virtual_Sele_S_AXI_bready=Sele_S_AXI_bready;
                Disconnect_Master='b0;
            end
        
    end

    assign Enable=(~|Num_of_Resp);

endmodule