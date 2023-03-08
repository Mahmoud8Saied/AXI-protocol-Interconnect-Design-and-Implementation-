module Qos_Arbiter #(
    parameter Slaves_Num='d2, Slaves_ID_Size=$clog2(Slaves_Num)
) (
    input  wire                      ACLK           ,
    input  wire                      ARESETN        ,
    input  wire                      S00_AXI_awvalid,
    input  wire  [3:0]               S00_AXI_awqos  , // for priority transactions
    input  wire                      S01_AXI_awvalid,
    input  wire  [3:0]               S01_AXI_awqos  , // for priority transactions
    input  wire                      Channel_Granted,
    input  wire                      Token          ,
    output wire                      Channel_Request,
    output reg  [Slaves_ID_Size-1:0] Selected_Slave
);
reg [Slaves_ID_Size-1:0] Slave;
reg Request;
always @(*) begin
    if (S01_AXI_awvalid && S00_AXI_awvalid) begin
        if (S00_AXI_awqos >= S01_AXI_awqos) begin
            Slave='b0;
        end else begin
            Slave='b1;
        end

    end else if (S00_AXI_awvalid) begin
        Slave='b0;
    end else if (S01_AXI_awvalid) begin
        Slave='b1;
    end else begin
        Slave='b0;
    end
end

    always @(*) begin
        if (!Channel_Granted) begin
            Request='b0;
        end else if ((S00_AXI_awvalid || S01_AXI_awvalid) ) begin
            Request='b1;
       end else begin
            Request='b0;
       end
    end
    assign Channel_Request = Request & (~ Token);
    
    always @(posedge ACLK or negedge ARESETN ) begin
        if (!ARESETN) begin
            Selected_Slave<='b0;
        end else if(Channel_Granted & (~ Token)) begin
            Selected_Slave<=Slave;
        end
    end
endmodule