module AW_Channel_Controller_Top #(
    parameter Masters_Num='d2,Slaves_ID_Size=$clog2(Masters_Num),Address_width='d32,
              S00_Aw_len='d8,//!or 4 for AXI3
              Is_Master_AXI_4='b0, //!
              AXI4_Aw_len='d8,
              M00_Aw_len='d4,
              // Added by Mahmoud
              Num_Of_Slaves = 2

) (
 output wire                      AW_Access_Grant,
 output wire [Slaves_ID_Size-1:0] AW_Selected_Slave,
 input  wire                      Queue_Is_Full,
 output wire                      Token,
 output wire [(AXI4_Aw_len/'d2)-1:0] Rem, //Reminder of the divsion
 output wire [(AXI4_Aw_len/'d2)-1:0] Num_Of_Compl_Bursts, // Number of Complete Bursts
 output wire                         Load_The_Original_Signals,
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
    
                  /****** Master M01 Ports *****/ // Added by mahmoud  

                  /*****************************/
    //* Slave General Ports
    input  wire                          M01_ACLK,
    input  wire                          M01_ARESETN,

    //* Address Write Channel  
    output wire [Slaves_ID_Size-1:0]     M01_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M01_AXI_awaddr,
    output wire [M00_Aw_len-1:0]         M01_AXI_awlen ,
    output wire [2:0]                    M01_AXI_awsize,  //number of bytes within the transfer
    output wire [1:0]                    M01_AXI_awburst,// burst type
    output wire [1:0]                    M01_AXI_awlock ,// lock type
    output wire [3:0]                    M01_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output wire [2:0]                    M01_AXI_awport ,// identifies the level of protection
    output wire                          M01_AXI_awvalid,// Address write valid signal 
    input  wire                          M01_AXI_awready,// Address write ready signal 

    //Q Enables....... Added by Mahmoud

    output wire [Num_Of_Slaves - 1 : 0]   Q_Enable_W_Data

);

wire AW_HandShake_Done;
wire AW_Channel_Request;
wire Sel_S_AXI_awvalid ;// Address write valid signal  

wire req;
wire Channel_Req_burst;

wire  [Address_width-1:0]      AXI4_Sel_S_AXI_awaddr;
wire  [AXI4_Aw_len-1:0]        AXI4_Sel_S_AXI_awlen;
wire  [2:0]                    AXI4_Sel_S_AXI_awsize;
wire  [1:0]                    AXI4_Sel_S_AXI_awburst;
wire  [1:0]                    AXI4_Sel_S_AXI_awlock ;
wire  [3:0]                    AXI4_Sel_S_AXI_awcache;
wire  [2:0]                    AXI4_Sel_S_AXI_awprot ;
wire                           AXI4_Sel_S_AXI_awvalid;
wire                           Disconnect_Master;

//----------------Mahmoud Added this--------------------------

wire  [Address_width-1:0]  M00_AXI_awaddr_Signal;  
wire  [2:0]                M00_AXI_awsize_Signal;  
wire  [M00_Aw_len-1:0]     M00_AXI_awlen_Signal;   
wire  [1 : 0]              M00_AXI_awburst_Signal; 
wire                       Sel_S_AXI_awvalid_Signal; 
wire  [1 : 0]              M00_AXI_awlock_Signal; 
wire  [3 : 0]              M00_AXI_awcache_Signal;
wire  [2 : 0]              M00_AXI_awport_Signal; 



wire                       Sel_Slave_Ready_Signal;
wire                       Master_Valid_Flag;

// -----------------------------------------------------------

wire AW_IS_Done;
// assign M00_AXI_awvalid=Sel_S_AXI_awvalid_Signal;
/*  Address Write Channel Mangers and MUXs*/
Qos_Arbiter #(
    .Slaves_Num     (Masters_Num     )
)
u_Qos_Arbiter(
	.ACLK            (ACLK            ),
    .ARESETN         (ARESETN         ),
    .S00_AXI_awvalid (S00_AXI_awvalid ),
    .S00_AXI_awqos   (S00_AXI_awqos   ),
    .S01_AXI_awvalid (S01_AXI_awvalid ),
    .S01_AXI_awqos   (S01_AXI_awqos   ),
    .Channel_Granted (AW_HandShake_Done ),
    .Token           (Token),
    .Channel_Request (AW_Channel_Request ),
    .Selected_Slave  (AW_Selected_Slave  )
);
        

assign req = Channel_Req_burst | AW_Channel_Request;

Faling_Edge_Detc u_Faling_Edge_Detc(
    .ACLK        (ACLK        ),
    .ARESETN     (ARESETN     ),
    .Test_Singal (AW_HandShake_Done ),
    .Falling     (AW_Access_Grant     )
);

Raising_Edge_Det u_Raising_Edge_Det(
    .ACLK        (ACLK        ),
    .ARESETN     (ARESETN     ),
    .Test_Singal (AW_HandShake_Done ),
    .Raisung     (AW_IS_Done     )
);


AW_HandShake_Checker u_Address_Write_HandShake_Checker(
    .ACLK           (ACLK           ),
    .ARESETN        (ARESETN        ),
    .Valid_Signal   (Sel_S_AXI_awvalid_Signal   ),
    .Ready_Signal   (Sel_Slave_Ready_Signal   ), //TODO
    .Channel_Request(req),
    .HandShake_Done (AW_HandShake_Done )
);

Demux_1_2 u_Demux_Address_Write_Ready(
    .Selection_Line (AW_Selected_Slave ),
    .Input_1        (Sel_Slave_Ready_Signal & (~Disconnect_Master)        ),
    .Output_1       (S00_AXI_awready       ),
    .Output_2       (S01_AXI_awready       )
);

AW_MUX_2_1 u_AW_MUX_2_1(
    .Selected_Slave   (AW_Selected_Slave   ),

    .S00_AXI_awaddr    (S00_AXI_awaddr    ),
    .S00_AXI_awlen     (S00_AXI_awlen     ),
    .S00_AXI_awsize    (S00_AXI_awsize    ),
    .S00_AXI_awburst   (S00_AXI_awburst   ),
    .S00_AXI_awlock    (S00_AXI_awlock    ),
    .S00_AXI_awcache   (S00_AXI_awcache   ),
    .S00_AXI_awprot    (S00_AXI_awprot    ),
    //.S00_AXI_awqos     (S00_AXI_awqos     ),
    .S00_AXI_awvalid   (S00_AXI_awvalid   ),
    
    .S01_AXI_awaddr    (S01_AXI_awaddr    ),
    .S01_AXI_awlen     (S01_AXI_awlen     ),
    .S01_AXI_awsize    (S01_AXI_awsize    ),
    .S01_AXI_awburst   (S01_AXI_awburst   ),
    .S01_AXI_awlock    (S01_AXI_awlock    ),
    .S01_AXI_awcache   (S01_AXI_awcache   ),
    .S01_AXI_awprot    (S01_AXI_awprot    ),
    //.S01_AXI_awqos     (S01_AXI_awqos     ),
    .S01_AXI_awvalid   (S01_AXI_awvalid   ),
    
    .Sel_S_AXI_awaddr  (AXI4_Sel_S_AXI_awaddr  ),
    .Sel_S_AXI_awlen   (AXI4_Sel_S_AXI_awlen   ),
    .Sel_S_AXI_awsize  (AXI4_Sel_S_AXI_awsize  ),
    .Sel_S_AXI_awburst (AXI4_Sel_S_AXI_awburst ),
    .Sel_S_AXI_awlock  ( AXI4_Sel_S_AXI_awlock ),
    .Sel_S_AXI_awcache ( AXI4_Sel_S_AXI_awcache),
    .Sel_S_AXI_awprot  ( AXI4_Sel_S_AXI_awprot ),
    //.Sel_S_AXI_awqos   (M00_AXI_awqos   ),
    .Sel_S_AXI_awvalid (AXI4_Sel_S_AXI_awvalid )
    
);

// Mahmoud work --------------------------------------------

Write_Addr_Channel_Dec #(
    .Num_OF_Masters   (Masters_Num   ),
    .Address_width    (Address_width    ),
    .AXI3_Aw_len      (M00_Aw_len      ),
    .Num_Of_Slaves    (Num_Of_Slaves    )
)
u_Write_Addr_Channel_Dec(
    .Master_AXI_awaddr_ID (AW_Selected_Slave ),
    .Master_AXI_awaddr    (M00_AXI_awaddr_Signal    ),
    .Master_AXI_awlen     (M00_AXI_awlen_Signal     ),
    .Master_AXI_awsize    (M00_AXI_awsize_Signal    ),
    .Master_AXI_awburst   (M00_AXI_awburst_Signal   ),
    .Master_AXI_awlock    (M00_AXI_awlock_Signal    ),
    .Master_AXI_awcache   (M00_AXI_awcache_Signal   ),
    .Master_AXI_awprot    (M00_AXI_awport_Signal    ),
    .Master_AXI_awvalid   (Sel_S_AXI_awvalid_Signal   ),

    .M00_AXI_awaddr_ID    (M00_AXI_awaddr_ID    ),
    .M00_AXI_awaddr       (M00_AXI_awaddr       ),
    .M00_AXI_awlen        (M00_AXI_awlen        ),
    .M00_AXI_awsize       (M00_AXI_awsize       ),
    .M00_AXI_awburst      (M00_AXI_awburst      ),
    .M00_AXI_awlock       (M00_AXI_awlock       ),
    .M00_AXI_awcache      (M00_AXI_awcache      ),
    .M00_AXI_awport       (M00_AXI_awport       ),
    .M00_AXI_awvalid      (M00_AXI_awvalid      ),
    .M00_AXI_awready      (M00_AXI_awready      ),
    .M01_AXI_awaddr_ID    (M01_AXI_awaddr_ID    ),
    .M01_AXI_awaddr       (M01_AXI_awaddr       ),
    .M01_AXI_awlen        (M01_AXI_awlen        ),
    .M01_AXI_awsize       (M01_AXI_awsize       ),
    .M01_AXI_awburst      (M01_AXI_awburst      ),
    .M01_AXI_awlock       (M01_AXI_awlock       ),
    .M01_AXI_awcache      (M01_AXI_awcache      ),
    .M01_AXI_awport       (M01_AXI_awport       ),
    .M01_AXI_awvalid      (M01_AXI_awvalid      ),
    .M01_AXI_awready      (M01_AXI_awready      ),
    .Sel_Slave_Ready      (Sel_Slave_Ready_Signal      ),
    .Q_Enables            (Q_Enable_W_Data            )
);



//----------------------------------------------------------
    

       AXI4_2_AXI3_Convertor #(
        .Address_width (Address_width ),
        .AXI4_Aw_len   (AXI4_Aw_len   ),
        .AXI3_Aw_len   (M00_Aw_len   )
       )
       u_AXI4_2_AXI3_Convertor(
       	.Queue_Is_Full          (Queue_Is_Full          ), //! Queue Full Flag
        .HandShake_Is_High      (AW_IS_Done    ), 
        .HandShake_Done         (AW_IS_Done          ),
        .Burst_Out              (AW_Access_Grant),
        .Rem                    (Rem            ),
        .Num_Of_Compl_Bursts    (Num_Of_Compl_Bursts),
        .Disconnect_Master      (Disconnect_Master ),
        .Load_The_Original_Signals(Load_The_Original_Signals),
        . Enable_Burst          (Token                  ),
        .Channel_Req_burst      (Channel_Req_burst      ),
        .ACLK                   (ACLK                   ),
        .ARESETN                (ARESETN                ),
        .AXI4_Sel_S_AXI_awaddr  (AXI4_Sel_S_AXI_awaddr  ),
        .AXI4_Sel_S_AXI_awlen   (AXI4_Sel_S_AXI_awlen   ),
        .AXI4_Sel_S_AXI_awsize  (AXI4_Sel_S_AXI_awsize  ),
        .AXI4_Sel_S_AXI_awburst (AXI4_Sel_S_AXI_awburst ),
        .AXI4_Sel_S_AXI_awlock  (AXI4_Sel_S_AXI_awlock  ),
        .AXI4_Sel_S_AXI_awcache (AXI4_Sel_S_AXI_awcache ),
        .AXI4_Sel_S_AXI_awprot  (AXI4_Sel_S_AXI_awprot  ),
        .AXI4_Sel_S_AXI_awvalid (AXI4_Sel_S_AXI_awvalid ),
        .AXI3_Sel_S_AXI_awaddr  (M00_AXI_awaddr_Signal  ),
        .AXI3_Sel_S_AXI_awlen   (M00_AXI_awlen_Signal   ),
        .AXI3_Sel_S_AXI_awsize  (M00_AXI_awsize_Signal  ),
        .AXI3_Sel_S_AXI_awburst (M00_AXI_awburst_Signal ),
        .AXI3_Sel_S_AXI_awlock  (M00_AXI_awlock_Signal  ),
        .AXI3_Sel_S_AXI_awcache (M00_AXI_awcache_Signal ),
        .AXI3_Sel_S_AXI_awprot  (M00_AXI_awport_Signal  ),
        .AXI3_Sel_S_AXI_awvalid (Sel_S_AXI_awvalid_Signal )
       );
       


    
endmodule