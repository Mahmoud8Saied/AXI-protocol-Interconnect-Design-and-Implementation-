module Write_Addr_Channel_Dec #(
    parameter  Num_OF_Masters='d2,
    parameter  Masters_ID_Size=$clog2(Num_OF_Masters),
    parameter  Address_width='d32,
    parameter  AXI3_Aw_len='d4 ,
   
    
    parameter Num_Of_Slaves = 2,
    parameter Base_Addr_Width = $clog2(Num_Of_Slaves)
) (
    // Ports of the selected master from the arbiter

    input  wire  [Masters_ID_Size-1:0]   Master_AXI_awaddr_ID,
    input  wire  [Address_width-1:0]     Master_AXI_awaddr,// the write address
    input  wire  [AXI3_Aw_len-1:0]        Master_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   Master_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   Master_AXI_awburst, // burst type
    input  wire  [1:0]                   Master_AXI_awlock , // lock type
    input  wire  [3:0]                   Master_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   Master_AXI_awprot ,// identifies the level of protection
    input  wire                          Master_AXI_awvalid, // Address write valid signal 
    
    output reg   [Masters_ID_Size-1:0]   M00_AXI_awaddr_ID,
    output reg  [Address_width-1:0]      M00_AXI_awaddr,
    output reg  [AXI3_Aw_len-1:0]        M00_AXI_awlen ,
    output reg  [2:0]                    M00_AXI_awsize,  //number of bytes within the transfer
    output reg  [1:0]                    M00_AXI_awburst,// burst type
    output reg  [1:0]                    M00_AXI_awlock ,// lock type
    output reg  [3:0]                    M00_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output reg  [2:0]                    M00_AXI_awport ,// identifies the level of protection
    output reg                           M00_AXI_awvalid,// Address write valid signal 
    input  wire                          M00_AXI_awready,// Address write ready signal 

    output reg   [Masters_ID_Size-1:0]   M01_AXI_awaddr_ID,
    output reg  [Address_width-1:0]      M01_AXI_awaddr,
    output reg  [AXI3_Aw_len-1:0]        M01_AXI_awlen ,
    output reg  [2:0]                    M01_AXI_awsize,  //number of bytes within the transfer
    output reg  [1:0]                    M01_AXI_awburst,// burst type
    output reg  [1:0]                    M01_AXI_awlock ,// lock type
    output reg  [3:0]                    M01_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output reg  [2:0]                    M01_AXI_awport ,// identifies the level of protection
    output reg                           M01_AXI_awvalid,// Address write valid signal 
    input  wire                          M01_AXI_awready,// Address write ready signal 

    output reg                           Sel_Slave_Ready,
    output reg [Num_Of_Slaves - 1 : 0]   Q_Enables
);


// Slaves Base Addresses:
localparam Slave0_Base_Addr = {{(Base_Addr_Width-1){1'b0}}, 1'b0},
           Slave1_Base_Addr = {{(Base_Addr_Width-1){1'b0}}, 1'b1};

wire [Base_Addr_Width - 1 : 0] Base_Addr_Master;
assign Base_Addr_Master = Master_AXI_awaddr[Address_width-1:Address_width-Base_Addr_Width];


always @(*) 
    begin
        
        case (Base_Addr_Master)
            Slave0_Base_Addr : 
                begin   
                    Q_Enables = 'b1; 

                    Sel_Slave_Ready =M00_AXI_awready;
                    M00_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M00_AXI_awaddr =Master_AXI_awaddr;
                    M00_AXI_awlen=Master_AXI_awlen;
                    M00_AXI_awsize=Master_AXI_awsize;
                    M00_AXI_awburst=Master_AXI_awburst;
                    M00_AXI_awlock=Master_AXI_awlock;
                    M00_AXI_awcache=Master_AXI_awcache;
                    M00_AXI_awport=Master_AXI_awprot;
                    M00_AXI_awvalid = Master_AXI_awvalid;    


                    M01_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M01_AXI_awaddr =Master_AXI_awaddr;
                    M01_AXI_awlen=Master_AXI_awlen;
                    M01_AXI_awsize=Master_AXI_awsize;
                    M01_AXI_awburst=Master_AXI_awburst;
                    M01_AXI_awlock=Master_AXI_awlock;
                    M01_AXI_awcache=Master_AXI_awcache;
                    M01_AXI_awport=Master_AXI_awprot;
                    M01_AXI_awvalid = 'b0;    
                end

            Slave1_Base_Addr :
                begin

                    Q_Enables = 'b10; 

                    M00_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M00_AXI_awaddr =Master_AXI_awaddr;
                    M00_AXI_awlen=Master_AXI_awlen;
                    M00_AXI_awsize=Master_AXI_awsize;
                    M00_AXI_awburst=Master_AXI_awburst;
                    M00_AXI_awlock=Master_AXI_awlock;
                    M00_AXI_awcache=Master_AXI_awcache;
                    M00_AXI_awport=Master_AXI_awprot;
                    M00_AXI_awvalid = 'b0; 

                    Sel_Slave_Ready =M01_AXI_awready;
                    M01_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M01_AXI_awaddr =Master_AXI_awaddr;
                    M01_AXI_awlen=Master_AXI_awlen;
                    M01_AXI_awsize=Master_AXI_awsize;
                    M01_AXI_awburst=Master_AXI_awburst;
                    M01_AXI_awlock=Master_AXI_awlock;
                    M01_AXI_awcache=Master_AXI_awcache;
                    M01_AXI_awport=Master_AXI_awprot;
                    M01_AXI_awvalid = Master_AXI_awvalid;    

                end  
            default: 
                begin         
                    Q_Enables = 'b1; 
                    Sel_Slave_Ready =M00_AXI_awready;
                    M00_AXI_awaddr =Master_AXI_awaddr;
                    M00_AXI_awlen=Master_AXI_awlen;
                    M00_AXI_awsize=Master_AXI_awsize;
                    M00_AXI_awburst=Master_AXI_awburst;
                    M00_AXI_awlock=Master_AXI_awlock;
                    M00_AXI_awcache=Master_AXI_awcache;
                    M00_AXI_awport=Master_AXI_awprot;
                    M00_AXI_awvalid = Master_AXI_awvalid;    


                    M01_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M01_AXI_awaddr =Master_AXI_awaddr;
                    M01_AXI_awlen=Master_AXI_awlen;
                    M01_AXI_awsize=Master_AXI_awsize;
                    M01_AXI_awburst=Master_AXI_awburst;
                    M01_AXI_awlock=Master_AXI_awlock;
                    M01_AXI_awcache=Master_AXI_awcache;
                    M01_AXI_awport=Master_AXI_awprot;
                    M01_AXI_awvalid = 'b0;    
                end
        endcase

    end

endmodule

//    if (!rst) begin

    //     Write_Addr_Channel_To_Slave0 <= {{(Write_Address_Channel_width-1){1'b0}}, 1'b0}; 
    //     Write_Addr_Channel_To_Slave1 <= {{(Write_Address_Channel_width-1){1'b0}}, 1'b0}; 
    //     Write_Addr_Channel_To_Slave2 <= {{(Write_Address_Channel_width-1){1'b0}}, 1'b0};

    //  end
    // else 

