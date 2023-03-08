module WD_MUX_2_1 #(parameter S_Write_data_bus_width='d32,S_Write_data_bytes_num=S_Write_data_bus_width/8

) (
    input  wire                          Selected_Slave,

    input  wire  [S_Write_data_bus_width-1:0]   S00_AXI_wdata,//Write data bus
    input  wire  [S_Write_data_bytes_num-1:0]   S00_AXI_wstrb, // strops identifes the active data lines
    input  wire                                 S00_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                 S00_AXI_wvalid, // write valid signal
   
    input  wire  [S_Write_data_bus_width-1:0]   S01_AXI_wdata,//Write data bus
    input  wire  [S_Write_data_bytes_num-1:0]   S01_AXI_wstrb, // strops identifes the active data lines
    input  wire                                 S01_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                 S01_AXI_wvalid, // write valid signal
   
    output reg  [S_Write_data_bus_width-1:0]   Sel_S_AXI_wdata,//Write data bus
    output reg  [S_Write_data_bytes_num-1:0]   Sel_S_AXI_wstrb, // strops identifes the active data lines
    output reg                                 Sel_S_AXI_wlast, // last signal to identify the last transfer in a burst
    output reg                                 Sel_S_AXI_wvalid // write valid signal
    
);


always @(*) begin
    if (!Selected_Slave) begin
        Sel_S_AXI_wdata=S00_AXI_wdata;
        Sel_S_AXI_wstrb=S00_AXI_wstrb;
        Sel_S_AXI_wlast=S00_AXI_wlast;
        Sel_S_AXI_wvalid=S00_AXI_wvalid;
    end else begin
        Sel_S_AXI_wdata=S01_AXI_wdata;
        Sel_S_AXI_wstrb=S01_AXI_wstrb;
        Sel_S_AXI_wlast=S01_AXI_wlast;
        Sel_S_AXI_wvalid=S01_AXI_wvalid;
    end

end
    
endmodule