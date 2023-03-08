module AW_MUX_2_1 #(parameter Address_width='d32,S_Aw_len='d8//!or 4 for AXI3
) (
    input  wire                          Selected_Slave,

    input  wire  [Address_width-1:0]     S00_AXI_awaddr,// the write address
    input  wire  [S_Aw_len-1:0]          S00_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   S00_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   S00_AXI_awburst, // burst type
    input  wire  [1:0]                   S00_AXI_awlock , // lock type
    input  wire  [3:0]                   S00_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S00_AXI_awprot ,// identifies the level of protection
    //input  wire  [3:0]                   S00_AXI_awqos  , // for priority transactions
    input  wire                          S00_AXI_awvalid, // Address write valid signal 

    input  wire  [Address_width-1:0]     S01_AXI_awaddr,// the write address
    input  wire  [S_Aw_len-1:0]          S01_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   S01_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   S01_AXI_awburst, // burst type
    input  wire  [1:0]                   S01_AXI_awlock , // lock type
    input  wire  [3:0]                   S01_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S01_AXI_awprot ,// identifies the level of protection
    //input  wire  [3:0]                   S01_AXI_awqos  , // for priority transactions
    input  wire                          S01_AXI_awvalid, // Address write valid signal


    output  reg  [Address_width-1:0]     Sel_S_AXI_awaddr,// the write address
    output  reg  [S_Aw_len-1:0]          Sel_S_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    output  reg  [2:0]                   Sel_S_AXI_awsize,//number of bytes within the transfer
    output  reg  [1:0]                   Sel_S_AXI_awburst, // burst type
    output  reg  [1:0]                   Sel_S_AXI_awlock , // lock type
    output  reg  [3:0]                   Sel_S_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    output  reg  [2:0]                   Sel_S_AXI_awprot ,// identifies the level of protection
    //output  reg  [3:0]                   Sel_S_AXI_awqos  , // for priority transactions
    output  reg                          Sel_S_AXI_awvalid // Address write valid signal  
   
);


always @(*) begin
    if (!Selected_Slave) begin
        Sel_S_AXI_awaddr  =S00_AXI_awaddr;       
        Sel_S_AXI_awlen   =S00_AXI_awlen; 
        Sel_S_AXI_awsize  =S00_AXI_awsize;
        Sel_S_AXI_awburst =S00_AXI_awburst;
        Sel_S_AXI_awlock  =S00_AXI_awlock ;
        Sel_S_AXI_awcache =S00_AXI_awcache;
        Sel_S_AXI_awprot  =S00_AXI_awprot ;
        Sel_S_AXI_awvalid =S00_AXI_awvalid;
        
    end else begin
        Sel_S_AXI_awaddr  =S01_AXI_awaddr;       
        Sel_S_AXI_awlen   =S01_AXI_awlen; 
        Sel_S_AXI_awsize  =S01_AXI_awsize;
        Sel_S_AXI_awburst =S01_AXI_awburst;
        Sel_S_AXI_awlock  =S01_AXI_awlock ;
        Sel_S_AXI_awcache =S01_AXI_awcache;
        Sel_S_AXI_awprot  =S01_AXI_awprot ;
        Sel_S_AXI_awvalid =S01_AXI_awvalid;
        
    end

end
    
endmodule