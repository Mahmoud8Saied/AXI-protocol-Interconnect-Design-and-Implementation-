module AXI_Interconnect #(
    parameter Masters_Num='d2,Slaves_ID_Size=$clog2(Masters_Num),Address_width='d32,
              S00_Aw_len='d8,//!or 4 for AXI3
              S00_Write_data_bus_width='d32,S00_Write_data_bytes_num=S00_Write_data_bus_width/8,
              S00_AR_len='d8, //!or 4 for AXI3
              S00_Read_data_bus_width='d32,
              S01_Write_data_bus_width='d32,

              AXI4_Aw_len='d8,
              AXI3_Aw_len='d4,

              M00_Aw_len='d4,//!or 4 for AXI3
              M00_Write_data_bus_width='d32,M00_Write_data_bytes_num=M00_Write_data_bus_width/8,
              M00_AR_len='d4, //!or 4 for AXI3
              M00_Read_data_bus_width='d32,

              Is_Master_AXI_4='b1, //!

              // Added by Mahmoud
              M1_ID='d0,
              M2_ID='d1,
              Resp_ID_width   = 'd2,
              Num_Of_Masters  = 'd2,
              Num_Of_Slaves   = 'd2,
              Master_ID_Width = $clog2(Num_Of_Masters)



) (
/*                /****** Slave S01 Ports *******/
                    /******************************/
//* Slave General Ports
    input  wire                          S01_ACLK,
    input  wire                          S01_ARESETN,
//* Address Write Channel
    input  wire  [Address_width-1:0]     S01_AXI_awaddr,// the write address
    input  wire  [S00_Aw_len-1:0]        S01_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   S01_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   S01_AXI_awburst, // burst type
    input  wire  [1:0]                   S01_AXI_awlock , // lock type
    input  wire  [3:0]                   S01_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S01_AXI_awprot ,// identifies the level of protection
    input  wire  [3:0]                   S01_AXI_awqos  , // for priority transactions
    input  wire                          S01_AXI_awvalid, // Address write valid signal 
    output wire                          S01_AXI_awready, // Address write ready signal 

//* Write Data Channel
    
    input  wire  [S00_Write_data_bus_width-1:0]   S01_AXI_wdata,//Write data bus
    input  wire  [S00_Write_data_bytes_num-1:0]   S01_AXI_wstrb, // strops identifes the active data lines
    input  wire                                   S01_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                   S01_AXI_wvalid, // write valid signal
    output wire                                   S01_AXI_wready, // write ready signal

//*Write Response Channel
    output wire  [1:0]                   S01_AXI_bresp,//Write response
    output wire                          S01_AXI_bvalid, //Write response valid signal
    input  wire                          S01_AXI_bready, //Write response ready signal

//*Address Read Channel
    input  wire  [Address_width-1:0]     S01_AXI_araddr,// the write address
    input  wire  [S00_AR_len-1:0]        S01_AXI_arlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   S01_AXI_arsize,//number of bytes within the transfer
    input  wire  [1:0]                   S01_AXI_arburst, // burst type
    input  wire  [1:0]                   S01_AXI_arlock , // lock type
    input  wire  [3:0]                   S01_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S01_AXI_arprot ,// identifies the level of protection
    input  wire  [3:0]                   S01_AXI_arqos  , // for priority transactions
    input  wire                          S01_AXI_arvalid, // Address write valid signal 
    output wire                          S01_AXI_arready, // Address write ready signal 
    
//*Read Data Channel
    output wire  [S00_Read_data_bus_width-1:0]  S01_AXI_rdata,//Read Data Bus
    output wire  [1:0]                          S01_AXI_rresp, // Read Response
    output wire                                 S01_AXI_rlast, // Read Last Signal
    output wire                                 S01_AXI_rvalid, // Read Valid Signal 
    input  wire                                 S01_AXI_rready, // Read Ready Signal
/*                /***** Interconnect Ports *****/
                    /******************************/
    input  wire                          ACLK,
    input  wire                          ARESETN,
                
/*                /****** Slave S00 Ports *******/
                    /******************************/
//* Slave General Ports
    input  wire                          S00_ACLK,
    input  wire                          S00_ARESETN,

//* Address Write Channel
    input  wire  [Address_width-1:0]     S00_AXI_awaddr,// the write address
    input  wire  [S00_Aw_len-1:0]        S00_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   S00_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   S00_AXI_awburst, // burst type
    input  wire  [1:0]                   S00_AXI_awlock , // lock type
    input  wire  [3:0]                   S00_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S00_AXI_awprot ,// identifies the level of protection
    input  wire  [3:0]                   S00_AXI_awqos  , // for priority transactions
    input  wire                          S00_AXI_awvalid, // Address write valid signal 
    output wire                          S00_AXI_awready, // Address write ready signal 

//* Write Data Channel
    
    input  wire  [S00_Write_data_bus_width-1:0]   S00_AXI_wdata,//Write data bus
    input  wire  [S00_Write_data_bytes_num-1:0]   S00_AXI_wstrb, // strops identifes the active data lines
    input  wire                                   S00_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                   S00_AXI_wvalid, // write valid signal
    output wire                                   S00_AXI_wready, // write ready signal

//*Write Response Channel
    output wire  [1:0]                   S00_AXI_bresp,//Write response
    output wire                          S00_AXI_bvalid, //Write response valid signal
    input  wire                          S00_AXI_bready, //Write response ready signal

//*Address Read Channel
    input  wire  [Address_width-1:0]     S00_AXI_araddr,// the write address
    input  wire  [S00_AR_len-1:0]        S00_AXI_arlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                   S00_AXI_arsize,//number of bytes within the transfer
    input  wire  [1:0]                   S00_AXI_arburst, // burst type
    input  wire  [1:0]                   S00_AXI_arlock , // lock type
    input  wire  [3:0]                   S00_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S00_AXI_arprot ,// identifies the level of protection
    input  wire  [3:0]                   S00_AXI_arqos  , // for priority transactions
    input  wire                          S00_AXI_arvalid, // Address write valid signal 
    output wire                          S00_AXI_arready, // Address write ready signal 
    
//*Read Data Channel
    output wire  [S00_Read_data_bus_width-1:0]  S00_AXI_rdata,//Read Data Bus
    output wire  [1:0]                          S00_AXI_rresp, // Read Response
    output wire                                 S00_AXI_rlast, // Read Last Signal
    output wire                                 S00_AXI_rvalid, // Read Valid Signal 
    input  wire                                 S00_AXI_rready, // Read Ready Signal



/*                /****** Master M00 Ports *****/   
                  /*****************************/
//* Slave General Ports
    input  wire                          M00_ACLK,
    input  wire                          M00_ARESETN,

//* Address Write Channel              
    output wire [Slaves_ID_Size-1:0]     M00_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M00_AXI_awaddr,
    output wire [M00_Aw_len-1:0]         M00_AXI_awlen ,
    output wire [2:0]                    M00_AXI_awsize,  //number of bytes within the transfer
    output wire [1:0]                    M00_AXI_awburst,// burst type
    output wire [1:0]                    M00_AXI_awlock ,// lock type
    output wire [3:0]                    M00_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output wire [2:0]                    M00_AXI_awport ,// identifies the level of protection
    output wire                          M00_AXI_awvalid,// Address write valid signal 
    input  wire                          M00_AXI_awready,// Address write ready signal 
    
//* Write Data Channel
    output wire  [M00_Write_data_bus_width-1:0]   M00_AXI_wdata,//Write data bus
    output wire  [M00_Write_data_bytes_num-1:0]   M00_AXI_wstrb, // strops identifes the active data lines
    output wire                                   M00_AXI_wlast, // last signal to identify the last transfer in a burst
    output wire                                   M00_AXI_wvalid, // write valid signal
    input  wire                                   M00_AXI_wready, // write ready signal

//*Write Response Channel
    input  wire [Master_ID_Width-1:0]     M00_AXI_BID  ,
    input  wire [1:0]                    M00_AXI_bresp,//Write response
    input  wire                          M00_AXI_bvalid, //Write response valid signal
    output wire                          M00_AXI_bready, //Write response ready signal

//*Address Read Channel
    output wire  [Address_width-1:0]     M00_AXI_araddr,// the write address
    output wire  [M00_AR_len-1:0]        M00_AXI_arlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    output wire  [2:0]                   M00_AXI_arsize,//number of bytes within the transfer
    output wire  [1:0]                   M00_AXI_arburst, // burst type
    output wire  [1:0]                   M00_AXI_arlock , // lock type
    output wire  [3:0]                   M00_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    output wire  [2:0]                   M00_AXI_arprot ,// identifies the level of protection
    //output wire  [3:0]                   M00_AXI_arregion,
    //output wire  [3:0]                   M00_AXI_arqos  , // for priority transactions
    output wire                          M00_AXI_arvalid, // Address write valid signal 
    input  wire                          M00_AXI_arready, // Address write ready signal 

//*Read Data Channel
    input  wire  [M00_Read_data_bus_width-1:0]  M00_AXI_rdata,//Read Data Bus
    input  wire  [1:0]                          M00_AXI_rresp, // Read Response
    input  wire                                 M00_AXI_rlast, // Read Last Signal
    input  wire                                 M00_AXI_rvalid, // Read Valid Signal 
    output wire                                 M00_AXI_rready, // Read Ready Signal

/*                /****** Master M01 Ports *****/   
                  /*****************************/
    //* Slave General Ports
    input  wire                          M01_ACLK,
    input  wire                          M01_ARESETN,

    //* Address Write Channel              
     output wire [Slaves_ID_Size-1:0]    M01_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M01_AXI_awaddr,
    output wire [M00_Aw_len-1:0]         M01_AXI_awlen ,
    output wire [2:0]                    M01_AXI_awsize,  //number of bytes within the transfer
    output wire [1:0]                    M01_AXI_awburst,// burst type
    output wire [1:0]                    M01_AXI_awlock ,// lock type
    output wire [3:0]                    M01_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output wire [2:0]                    M01_AXI_awport ,// identifies the level of protection
    output wire                          M01_AXI_awvalid,// Address write valid signal 
    input  wire                          M01_AXI_awready,// Address write ready signal 

    //* Write Data Channel
    output wire  [M00_Write_data_bus_width-1:0]   M01_AXI_wdata,//Write data bus
    output wire  [M00_Write_data_bytes_num-1:0]   M01_AXI_wstrb, // strops identifes the active data lines
    output wire                                   M01_AXI_wlast, // last signal to identify the last transfer in a burst
    output wire                                   M01_AXI_wvalid, // write valid signal
    input  wire                                   M01_AXI_wready, // write ready signal

    //*Write Response Channel
    input  wire [Master_ID_Width-1:0]     M01_AXI_BID  ,
    input  wire [1:0]                    M01_AXI_bresp,//Write response
    input  wire                          M01_AXI_bvalid, //Write response valid signal
    output wire                          M01_AXI_bready, //Write response ready signal

    //*Address Read Channel
    output wire  [Address_width-1:0]     M01_AXI_araddr,// the write address
    output wire  [M00_AR_len-1:0]        M01_AXI_arlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    output wire  [2:0]                   M01_AXI_arsize,//number of bytes within the transfer
    output wire  [1:0]                   M01_AXI_arburst, // burst type
    output wire  [1:0]                   M01_AXI_arlock , // lock type
    output wire  [3:0]                   M01_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    output wire  [2:0]                   M01_AXI_arprot ,// identifies the level of protection
    output wire                          M01_AXI_arvalid, // Address write valid signal 
    input  wire                          M01_AXI_arready, // Address write ready signal 

    //*Read Data Channel
    input  wire  [M00_Read_data_bus_width-1:0]  M01_AXI_rdata,//Read Data Bus
    input  wire  [1:0]                          M01_AXI_rresp, // Read Response
    input  wire                                 M01_AXI_rlast, // Read Last Signal
    input  wire                                 M01_AXI_rvalid, // Read Valid Signal 
    output wire                                 M01_AXI_rready, // Read Ready Signal

    // Ports added by Mahmoud
    //input  wire [Master_ID_Width - 1 : 0]       M1_ID, M2_ID



   //!addresses ranges for each slave 
    input [31:0] slave0_addr1,
    input [31:0] slave0_addr2,

    input [31:0] slave1_addr1,
    input [31:0] slave1_addr2
   //! Wrong just for testing 

);
//------------------- Internal Signals -------------------
//****************Write Channels*********************/
wire AW_Access_Grant;
wire Write_Data_Finsh;
wire [Slaves_ID_Size-1:0] AW_Selected_Slave;
wire [Slaves_ID_Size-1:0] Write_Data_Master;
wire Last_Signal_Data;
wire Queue_Is_Full;
wire Token;
wire [(S00_Aw_len/'d2)-1:0] Rem; //Reminder of the divsion
wire [(S00_Aw_len/'d2)-1:0] Num_Of_Compl_Bursts; // Number of Complete Bursts
wire Is_Master_Part_Of_Split;
wire Load_The_Original_Signals;
// Added by mahmoud 
wire [Masters_Num - 1 : 0] Q_Enable_W_Data_Signal;
wire Is_Master_Part_Of_Split2,Write_Data_Finsh2,Write_Data_Master2;
// --------------------------------------------------------

//**************** Read Channels*********************/
//select lines for muxs and demuxs coming from controller:
wire             S_addr_wire;
wire             M0_data_wire;
wire             M1_data_wire;
wire             M_addr_wire;

//wires connecting between a mux and a demux:
wire             ARVALID_wire;
wire  [31:0]     ARADDR_wire;
wire  [3:0]      ARLEN_wire;
wire  [2:0]      ARSIZE_wire;
wire  [1:0]      ARBURST_wire;

wire             en_S0_wire;
wire             en_S1_wire;

wire             enable_S0_wire;
wire             enable_S1_wire;

wire             RREADY_S0_wire;
wire             RREADY_S1_wire;

wire             RREADY_S0_wire_2;
wire             RREADY_S1_wire_2;
// --------------------------------------------------------


//******************** Write Channel Comp ********************//
AW_Channel_Controller_Top #(
    .Masters_Num     (Masters_Num     ),
    .Address_width   (Address_width   ),
    .S00_Aw_len      (S00_Aw_len      ),
    .Is_Master_AXI_4 (Is_Master_AXI_4 ),
    .AXI4_Aw_len     (AXI4_Aw_len     ),
    .M00_Aw_len      (M00_Aw_len      ),
    .Num_Of_Slaves   (Num_Of_Slaves   )
)
u_AW_Channel_Controller_Top(
    .AW_Access_Grant           (AW_Access_Grant           ),
    .AW_Selected_Slave         (AW_Selected_Slave         ),
    .Queue_Is_Full             (Queue_Is_Full             ),
    .Token                     (Token                     ),
    .Rem                       (Rem                       ),
    .Num_Of_Compl_Bursts       (Num_Of_Compl_Bursts       ),
    .Load_The_Original_Signals (Load_The_Original_Signals ),
    .ACLK                      (ACLK                      ),
    .ARESETN                   (ARESETN                   ),
    .S00_ACLK                  (S00_ACLK                  ),
    .S00_ARESETN               (S00_ARESETN               ),
    .S00_AXI_awaddr            (S00_AXI_awaddr            ),
    .S00_AXI_awlen             (S00_AXI_awlen             ),
    .S00_AXI_awsize            (S00_AXI_awsize            ),
    .S00_AXI_awburst           (S00_AXI_awburst           ),
    .S00_AXI_awlock            (S00_AXI_awlock            ),
    .S00_AXI_awcache           (S00_AXI_awcache           ),
    .S00_AXI_awprot            (S00_AXI_awprot            ),
    .S00_AXI_awqos             (S00_AXI_awqos             ),
    .S00_AXI_awvalid           (S00_AXI_awvalid           ),
    .S00_AXI_awready           (S00_AXI_awready           ),
    .S01_ACLK                  (S01_ACLK                  ),
    .S01_ARESETN               (S01_ARESETN               ),
    .S01_AXI_awaddr            (S01_AXI_awaddr            ),
    .S01_AXI_awlen             (S01_AXI_awlen             ),
    .S01_AXI_awsize            (S01_AXI_awsize            ),
    .S01_AXI_awburst           (S01_AXI_awburst           ),
    .S01_AXI_awlock            (S01_AXI_awlock            ),
    .S01_AXI_awcache           (S01_AXI_awcache           ),
    .S01_AXI_awprot            (S01_AXI_awprot            ),
    .S01_AXI_awqos             (S01_AXI_awqos             ),
    .S01_AXI_awvalid           (S01_AXI_awvalid           ),
    .S01_AXI_awready           (S01_AXI_awready           ),
    .M00_ACLK                  (M00_ACLK                  ),
    .M00_ARESETN               (M00_ARESETN               ),
    .M00_AXI_awaddr_ID         (M00_AXI_awaddr_ID         ),
    .M00_AXI_awaddr            (M00_AXI_awaddr            ),
    .M00_AXI_awlen             (M00_AXI_awlen             ),
    .M00_AXI_awsize            (M00_AXI_awsize            ),
    .M00_AXI_awburst           (M00_AXI_awburst           ),
    .M00_AXI_awlock            (M00_AXI_awlock            ),
    .M00_AXI_awcache           (M00_AXI_awcache           ),
    .M00_AXI_awport            (M00_AXI_awport            ),
    .M00_AXI_awvalid           (M00_AXI_awvalid           ),
    .M00_AXI_awready           (M00_AXI_awready           ),
    .M01_ACLK                  (M01_ACLK                  ),
    .M01_ARESETN               (M01_ARESETN               ),
    .M01_AXI_awaddr_ID         (M01_AXI_awaddr_ID         ),
    .M01_AXI_awaddr            (M01_AXI_awaddr            ),
    .M01_AXI_awlen             (M01_AXI_awlen             ),
    .M01_AXI_awsize            (M01_AXI_awsize            ),
    .M01_AXI_awburst           (M01_AXI_awburst           ),
    .M01_AXI_awlock            (M01_AXI_awlock            ),
    .M01_AXI_awcache           (M01_AXI_awcache           ),
    .M01_AXI_awport            (M01_AXI_awport            ),
    .M01_AXI_awvalid           (M01_AXI_awvalid           ),
    .M01_AXI_awready           (M01_AXI_awready           ),
    .Q_Enable_W_Data           (Q_Enable_W_Data_Signal    )
);

/*Data Write Channel Mangers and MUXs*/


WD_Channel_Controller_Top #(
    .Slaves_Num               (Masters_Num               ),
    .Slaves_ID_Size           (Slaves_ID_Size           ),
    .Address_width            (Address_width            ),
    .S00_Write_data_bus_width (S00_Write_data_bus_width ),
    .S01_Write_data_bus_width (S01_Write_data_bus_width ),
    .M00_Write_data_bus_width (M00_Write_data_bus_width )
)
u_WD_Channel_Controller_Top(
    .AW_Selected_Slave (AW_Selected_Slave ),
    .AW_Access_Grant   (AW_Access_Grant   ),
    .Write_Data_Master (Write_Data_Master ),
    .Write_Data_Master2(Write_Data_Master2),
    .Write_Data_Finsh  (Write_Data_Finsh  ),
    .Write_Data_Finsh2(Write_Data_Finsh2  ),
    
    .Queue_Is_Full     (Queue_Is_Full     ),
    .Is_Master_Part_Of_Split(Is_Master_Part_Of_Split),
    .Is_Master_Part_Of_Split2(Is_Master_Part_Of_Split2),
    .Token             (Token             ),
    .ACLK              (ACLK              ),
    .ARESETN           (ARESETN           ),
    .S00_AXI_wdata     (S00_AXI_wdata     ),
    .S00_AXI_wstrb     (S00_AXI_wstrb     ),
    .S00_AXI_wlast     (S00_AXI_wlast     ),
    .S00_AXI_wvalid    (S00_AXI_wvalid    ),
    .S00_AXI_wready    (S00_AXI_wready    ),
    .S01_AXI_wdata     (S01_AXI_wdata     ),
    .S01_AXI_wstrb     (S01_AXI_wstrb     ),
    .S01_AXI_wlast     (S01_AXI_wlast     ),
    .S01_AXI_wvalid    (S01_AXI_wvalid    ),
    .S01_AXI_wready    (S01_AXI_wready    ),
    .M00_AXI_wdata     (M00_AXI_wdata     ),
    .M00_AXI_wstrb     (M00_AXI_wstrb     ),
    .M00_AXI_wlast     (M00_AXI_wlast     ),
    .M00_AXI_wvalid    (M00_AXI_wvalid    ),
    .M00_AXI_wready    (M00_AXI_wready    ),

    // ------------ Added by Mahmoud --------------------------- 
                 
    .M01_AXI_wdata      (M01_AXI_wdata         ),//Write data bus
    .M01_AXI_wstrb      (M01_AXI_wstrb         ), // strops identifes the active data lines
    .M01_AXI_wlast      (M01_AXI_wlast         ), // last signal to identify the last transfer in a burst
    .M01_AXI_wvalid     (M01_AXI_wvalid        ), // write valid signal
    .M01_AXI_wready     (M01_AXI_wready        ), // write ready signal
    .Q_Enable_W_Data_In (Q_Enable_W_Data_Signal)
);

//Write Responese Channel


BR_Channel_Controller_Top #(
    .Slaves_Num      (Masters_Num      ),
    .AXI4_Aw_len     (AXI4_Aw_len     ),
    .AXI3_Aw_len     (AXI3_Aw_len     ),
    .Num_Of_Masters  (Num_Of_Masters  ),
    .Num_Of_Slaves   (Num_Of_Slaves   ),
    .Master_ID_Width (Master_ID_Width ),
    .M1_ID           (M1_ID           ),
    .M2_ID           (M2_ID           )
)
u_BR_Channel_Controller_Top(
    .Write_Data_Master         (Write_Data_Master         ),
    .Write_Data_Finsh          (Write_Data_Finsh          ),
    .Rem                       (Rem                       ),
    .Num_Of_Compl_Bursts       (Num_Of_Compl_Bursts       ),
    .Is_Master_Part_Of_Split   (Is_Master_Part_Of_Split   ),
    .Load_The_Original_Signals (Load_The_Original_Signals ),
    .ACLK                      (ACLK                      ),
    .ARESETN                   (ARESETN                   ),
    .S01_AXI_bresp             (S01_AXI_bresp             ),
    .S01_AXI_bvalid            (S01_AXI_bvalid            ),
    .S01_AXI_bready            (S01_AXI_bready            ),
    .S00_AXI_bresp             (S00_AXI_bresp             ),
    .S00_AXI_bvalid            (S00_AXI_bvalid            ),
    .S00_AXI_bready            (S00_AXI_bready            ),
    .M00_AXI_BID               (M00_AXI_BID               ),
    .M00_AXI_bresp             (M00_AXI_bresp             ),
    .M00_AXI_bvalid            (M00_AXI_bvalid            ),
    .M00_AXI_bready            (M00_AXI_bready            ),
    .M01_AXI_BID               (M01_AXI_BID               ),
    .M01_AXI_bresp             (M01_AXI_bresp             ),
    .M01_AXI_bvalid            (M01_AXI_bvalid            ),
    .M01_AXI_bready            (M01_AXI_bready            )
);

//******************** Read Channel Comp ********************//
//---------------------- Code Start ----------------------

Controller Read_controller (
    .clkk                          (ACLK),
    .resett                        (ARESETN),
    .slave0_addr1                  (slave0_addr1),//! Range Is not an input 
    .slave0_addr2                  (slave0_addr2),//! Range Is not an input 
    .slave1_addr1                  (slave1_addr1),//!Range Is not an input 
    .slave1_addr2                  (slave1_addr2),//!Range Is not an input 
    .M_ADDR                        (ARADDR_wire), // Internal
    .S0_ARREADY                    (M00_AXI_arready),
    .S1_ARREADY                    (M01_AXI_arready),
    .M0_ARVALID                    (S00_AXI_arvalid),
    .M1_ARVALID                    (S01_AXI_arvalid),
    .M0_RREADY                     (S00_AXI_rready),
    .M1_RREADY                     (S01_AXI_rready),
    .S0_RVALID                     (M00_AXI_rvalid),
    .S1_RVALID                     (M01_AXI_rvalid),
    .S0_RLAST                      (M00_AXI_rlast),
    .S1_RLAST                      (M01_AXI_rlast),

    .select_slave_address          (S_addr_wire),// Internal
    .select_data_M0                (M0_data_wire),// Internal
    .select_data_M1                (M1_data_wire),// Internal
    .select_master_address         (M_addr_wire),// Internal
    .en_S0                         (en_S0_wire),// Internal
    .en_S1                         (en_S1_wire),// Internal
    .enable_S0                     (enable_S0_wire),// Internal
    .enable_S1                     (enable_S1_wire)// Internal

);

//-------------- Address Channel ---------------------

//------------------ ARVALID -------------------------
Mux_2x1 #(.width(0)) arvalid_mux (
    .in1        (S00_AXI_arvalid),
    .in2        (S01_AXI_arvalid),
    .sel        (M_addr_wire),

    .out        (ARVALID_wire)
);
Demux_1x2 #(.width(0)) arvalid_demux (
    .in             (ARVALID_wire),
    .select         (S_addr_wire),

    .out1           (M00_AXI_arvalid),
    .out2           (M01_AXI_arvalid)
);

//------------------ ARADDR -------------------------
Mux_2x1 #(.width(31)) araddr_mux (
    .in1        (S00_AXI_araddr),
    .in2        (S01_AXI_araddr),
    .sel        (M_addr_wire), 

    .out        (ARADDR_wire)
);
Demux_1x2 #(.width(31)) araddr_demux (
    .in             (ARADDR_wire),
    .select         (S_addr_wire),

    .out1           (M00_AXI_araddr),
    .out2           (M01_AXI_araddr)
);

//------------------ ARLEN -------------------------
Mux_2x1 #(.width(3)) arlen_mux (
    .in1        (S00_AXI_arlen[3:0]),
    .in2        (S01_AXI_arlen[3:0]),
    .sel        (M_addr_wire), 

    .out        (ARLEN_wire)
);
Demux_1x2 #(.width(3)) arlen_demux (
    .in             (ARLEN_wire),
    .select         (S_addr_wire),

    .out1           (M00_AXI_arlen),
    .out2           (M01_AXI_arlen)
);

//------------------ ARSIZE -------------------------
Mux_2x1 #(.width(2)) arsize_mux (
    .in1        (S00_AXI_arsize),
    .in2        (S01_AXI_arsize),
    .sel        (M_addr_wire), 

    .out        (ARSIZE_wire)
);
Demux_1x2 #(.width(2)) arsize_demux (
    .in             (ARSIZE_wire),
    .select         (S_addr_wire),

    .out1           (M00_AXI_arsize),
    .out2           (M01_AXI_arsize)
);

//------------------ ARBURST -------------------------
Mux_2x1 #(.width(1)) arburst_mux (
    .in1        (S00_AXI_arburst),
    .in2        (S01_AXI_arburst),
    .sel        (M_addr_wire), 

    .out        (ARBURST_wire)
);
Demux_1x2 #(.width(1)) arburst_demux (
    .in             (ARBURST_wire),
    .select         (S_addr_wire),

    .out1           (M00_AXI_arburst),
    .out2           (M01_AXI_arburst)
);

//------------------ ARREADY -------------------------
Mux_2x1 #(.width(0)) arready_mux (
    .in1        (M00_AXI_arready),
    .in2        (M01_AXI_arready),
    .sel        (S_addr_wire), 

    .out        (ARREADY_wire)
);
Demux_1x2 #(.width(0)) arready_demux (
    .in             (ARREADY_wire),
    .select         (M_addr_wire),

    .out1           (S00_AXI_arready),
    .out2           (S01_AXI_arready)
);

//---------------- Data Channel ---------------------

//------------------ RREADY -------------------------
/*Demux_1x2_en #(.width(0)) rready_demux (
    .in             (S00_AXI_rready),
    .select         (M0_data_wire),
    .enable         (),
    .out1           (M00_AXI_rready),
    .out2           (RREADY_S1)
);
Demux_1x2_en #(.width(0)) rready_demux2 (
    .in             (S01_AXI_rready),
    .select         (M1_data_wire),
    .enable         (),
    .out1           (M00_AXI_rready),
    .out2           (RREADY_S1)
);*/
Demux_1x2 #(.width(0)) rready_demux (
    .in             (S00_AXI_rready),
    .select         (M0_data_wire),

    .out1           (RREADY_S0_wire),
    .out2           (RREADY_S1_wire)
);
Demux_1x2 #(.width(0)) rready_demux2 (
    .in             (S01_AXI_rready),
    .select         (M1_data_wire),

    .out1           (RREADY_S0_wire_2),
    .out2           (RREADY_S1_wire_2)
);

Mux_2x1 #(.width(0)) rready_mux (
    .in1        (RREADY_S0_wire),
    .in2        (RREADY_S0_wire_2),
    .sel        (en_S0_wire), 

    .out        (M00_AXI_rready)
);
Mux_2x1 #(.width(0)) rready_mux2 (
    .in1        (RREADY_S1_wire),
    .in2        (RREADY_S1_wire_2),
    .sel        (en_S1_wire), 

    .out        (M01_AXI_rready)
);
/*Mux_2x1_en #(.width(0)) rready_mux (
    .in1        (S00_AXI_rready),
    .in2        (S01_AXI_rready),
    .sel        (en_S0_wire), 
    .enable     (enable_S0_wire),

    .out        (M00_AXI_rready)
);
Mux_2x1_en #(.width(0)) rready_mux2 (
    .in1        (S00_AXI_rready),
    .in2        (S01_AXI_rready),
    .sel        (en_S1_wire), 
    .enable     (enable_S1_wire),

    .out        (RREADY_S1)
);*/
//------------------ RVALID -------------------------
Mux_2x1 #(.width(0)) rvalid_mux (
    .in1        (M00_AXI_rvalid),
    .in2        (M01_AXI_rvalid),
    .sel        (M0_data_wire), 

    .out        (S00_AXI_rvalid)
);
Mux_2x1 #(.width(0)) rvalid_mux2 (
    .in1        (M00_AXI_rvalid),
    .in2        (M01_AXI_rvalid),
    .sel        (M1_data_wire), 

    .out        (S01_AXI_rvalid)
);

//------------------ RDATA -------------------------
Mux_2x1 #(.width(31)) rdata_mux (
    .in1        (M00_AXI_rdata),
    .in2        (M01_AXI_rdata),
    .sel        (M0_data_wire), 

    .out        (S00_AXI_rdata)
);
Mux_2x1 #(.width(31)) rdata_mux2 (
    .in1        (M00_AXI_rdata),
    .in2        (M01_AXI_rdata),
    .sel        (M1_data_wire), 

    .out        (S01_AXI_rdata)
);

//------------------ RLAST -------------------------
Mux_2x1 #(.width(0)) rlast_mux (
    .in1        (M00_AXI_rlast),
    .in2        (M01_AXI_rlast),
    .sel        (M0_data_wire), 

    .out        (S00_AXI_rlast)
);
Mux_2x1 #(.width(0)) rlast_mux2 (
    .in1        (M00_AXI_rlast),
    .in2        (M01_AXI_rlast),
    .sel        (M1_data_wire), 

    .out        (S01_AXI_rlast)
);

//------------------ RRESP -------------------------
Mux_2x1 #(.width(1)) rresp_mux (
    .in1        (M00_AXI_rresp),
    .in2        (M01_AXI_rresp),
    .sel        (M0_data_wire), 

    .out        (S00_AXI_rresp)
);
Mux_2x1 #(.width(1)) rresp_mux2 (
    .in1        (M00_AXI_rresp),
    .in2        (M01_AXI_rresp),
    .sel        (M1_data_wire), 

    .out        (S01_AXI_rresp)
);


endmodule