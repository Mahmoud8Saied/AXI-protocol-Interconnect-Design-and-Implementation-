module Resp_Queue #(
    parameter Slaves_Num='d2,ID_Size=$clog2(Slaves_Num)
) (
    input  wire                 ACLK,
    input  wire                 ARESETN,
    input  wire [ID_Size-1:0]   Slave_ID,
    input  wire                 AW_Access_Grant,
    input  wire                 Write_Data_Finsh,
    output reg                  Queue_Is_Full,
    output wire                 Write_Data_HandShake_En_Pulse,
    output wire  [ID_Size-1:0]  Write_Data_Master
);
integer i;
reg [ID_Size-1:0] Queue [Slaves_Num-1:0];

reg [ID_Size:0] Read_Pointer,Write_Pointer;
wire Write_Data_HandShake_En;
reg Pulse;

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        for (i =0 ;i<Slaves_Num ;i=i+1 ) begin
            Queue[i]<='b0;
        end
    end else if (AW_Access_Grant) begin
        Queue[Write_Pointer[0]]<=Slave_ID;
    end
end

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        Write_Pointer<='b0;
    end else if (AW_Access_Grant) begin
        Write_Pointer<=Write_Pointer+'b1;
    end
end
always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Read_Pointer<='b0;
    end else if (Write_Data_Finsh) begin
        Read_Pointer<=Read_Pointer+'b1;
    end
end
assign Write_Data_Master=Queue[Read_Pointer[0]];
assign Write_Data_HandShake_En = (Read_Pointer != Write_Pointer) ;

always @(*) begin 
    if ((Read_Pointer[ID_Size] !=Write_Pointer[ID_Size]) && (Read_Pointer[ID_Size-1:0] ==Write_Pointer[ID_Size-1:0]) ) begin
        Queue_Is_Full='b1;
    end else begin
        Queue_Is_Full='b0;
    end

end

always @(posedge  ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Pulse<='b0;
    end else begin
        Pulse<=Write_Data_HandShake_En;
    end
end
assign Write_Data_HandShake_En_Pulse= (~Pulse) & Write_Data_HandShake_En;
endmodule