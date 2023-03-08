module Write_Arbiter #(parameter Slaves_Num='d2, Slaves_ID_Size=$clog2(Slaves_Num)
                                
)
(
    input  wire   ACLK           ,
    input  wire   ARESETN        ,
    input  wire   S00_AXI_awvalid,
    input  wire   S01_AXI_awvalid,
    input  wire   Channel_Granted,
    output reg    Channel_Request,
    output reg  [Slaves_ID_Size-1:0]   Selected_Slave

);
 reg [Slaves_ID_Size-1:0]   Slave;
 reg Request;

    always @(*) begin
        if (!Channel_Granted) begin
            Channel_Request='b0;
        end else if ((S00_AXI_awvalid || S01_AXI_awvalid) ) begin
            Channel_Request='b1;
       end else begin
            Channel_Request='b0;
       end
    end


    always @(*) begin
        if (S00_AXI_awvalid) begin
            Slave='b0;
        end else if (S01_AXI_awvalid) begin
            Slave='b1;
        end else begin
            Slave='b0;
        end
    end

    

    always @(posedge ACLK or negedge ARESETN ) begin
        if (!ARESETN) begin
            Selected_Slave<='b0;
        end else if(Channel_Granted) begin
            Selected_Slave<=Slave;
        end
    end
endmodule