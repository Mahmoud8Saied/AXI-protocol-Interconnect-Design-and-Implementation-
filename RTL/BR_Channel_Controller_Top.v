module BR_Channel_Controller_Top #(
    parameter Slaves_Num='d2,Slaves_ID_Size=$clog2(Slaves_Num),AXI4_Aw_len='d8,AXI3_Aw_len='d4,
              Resp_ID_width = 2,
              Num_Of_Masters = 2, Num_Of_Slaves='d2,
              Master_ID_Width = $clog2(Num_Of_Masters),M1_ID='d0,M2_ID='d1
) (
    input wire [Slaves_ID_Size-1:0] Write_Data_Master,
    input wire                      Write_Data_Finsh,
    input wire [(AXI4_Aw_len/'d2)-1:0] Rem, //Reminder of the divsion
    input wire [(AXI4_Aw_len/'d2)-1:0] Num_Of_Compl_Bursts, // Number of Complete Bursts
    input wire                         Is_Master_Part_Of_Split,
    input wire                         Load_The_Original_Signals,
/*                /***** Interconnect Ports *****/
                /******************************/
    input  wire                          ACLK,
    input  wire                          ARESETN,

/*                /****** Slave S01 Ports *******/
                    /******************************/
    //*Write Response Channel
    output wire  [1:0]                   S01_AXI_bresp,//Write response
    output wire                          S01_AXI_bvalid, //Write response valid signal
    input  wire                          S01_AXI_bready, //Write response ready signal
/*                /****** Slave S00 Ports *******/
                    /******************************/
 //*Write Response Channel
    output wire  [1:0]                   S00_AXI_bresp,//Write response
    output wire                          S00_AXI_bvalid, //Write response valid signal
    input  wire                          S00_AXI_bready, //Write response ready signal
/*                /****** Master M00 Ports *****/   
                  /*****************************/
 //*Write Response Channel
    input  wire [Master_ID_Width-1:0]     M00_AXI_BID  ,
    input  wire [1:0]                    M00_AXI_bresp,//Write response
    input  wire                          M00_AXI_bvalid, //Write response valid signal
    output wire                          M00_AXI_bready, //Write response ready signal
    /*                /****** Master M01 Ports *****/  // added by mahmoud 
                  /*****************************/
 //*Write Response Channel
    input  wire [Master_ID_Width-1:0]     M01_AXI_BID  ,
    input  wire [1:0]                    M01_AXI_bresp,//Write response
    input  wire                          M01_AXI_bvalid, //Write response valid signal
    output wire                          M01_AXI_bready //Write response ready signal

);
    
wire Write_Res_HandShake_Done;
wire Write_Res_HandShake_En_Pulse;
wire [Slaves_ID_Size-1:0] Write_Res_Master;
wire Sele_S_AXI_bready;
wire Trans_Split;
wire Virtual_Sele_S_AXI_bready;
wire [1:0] Virtual_M00_AXI_bresp;
wire Virtual_M00_AXI_bvalid;
wire Disconnect_Master;
// Added by Mahmoud

//wire [Resp_ID_width - 1 : 0]   Sel_Resp_ID_Signal;
wire [Master_ID_Width - 1 : 0] Sel_M_ID_Signal;

wire                           Sel_M_Ready_Signal;
wire [1:0]                     Sel_Write_Resp_Signal;
wire                           Sel_Valid_Signal;
wire                           Channel_Granted_SIgnal;
wire [Slaves_ID_Size - 1 : 0]  Selected_Slave_Signal;
wire                           Channel_Request_Signal;
wire                           HandShake_Raising;
// ------------------------------------------------------------




WR_HandShake u_WR_HandShake(
    .ACLK           (ACLK           ),
    .ARESETN        (ARESETN        ),
    .Valid_Signal   (Sel_Valid_Signal   ),
    .Ready_Signal   (Virtual_Sele_S_AXI_bready   ),
    .HandShake_En   (Write_Res_HandShake_En_Pulse   ),
    .HandShake_Done (Write_Res_HandShake_Done )
);


Raising_Edge_Det u_Raising_Edge_Det(
    .ACLK        (ACLK        ),
    .ARESETN     (ARESETN     ),
    .Test_Singal (Write_Res_HandShake_Done ),
    .Raisung     (HandShake_Raising     )
);


// Mahmoud Modules Instantiations

// Arbiter Module


Write_Resp_Channel_Arb #(
    .Num_Of_Masters (Num_Of_Masters ),
    .Num_Of_Slaves  (Num_Of_Slaves  )
)
u_Write_Resp_Channel_Arb(
    .clk             (ACLK             ),
    .rst             (ARESETN             ),
    .Channel_Granted (Write_Res_HandShake_Done ), //!
    .M00_AXI_BID     (M00_AXI_BID     ),
    .M00_AXI_bresp   (M00_AXI_bresp   ),
    .M00_AXI_bvalid  (M00_AXI_bvalid  ),
    .M01_AXI_BID     (M01_AXI_BID     ),
    .M01_AXI_bresp   (M01_AXI_bresp   ),
    .M01_AXI_bvalid  (M01_AXI_bvalid  ),
    .Channel_Request (Write_Res_HandShake_En_Pulse ), //!
    .Selected_Slave  (Selected_Slave  ), //!
    
    .Sel_Resp_ID     (Sel_M_ID_Signal     ),
    .Sel_Write_Resp  (Sel_Write_Resp_Signal  ),
    .Sel_Valid       (Sel_Valid_Signal       )
);

Res_Virtual_Master #(
    .AXI4_Aw_len (AXI4_Aw_len ),
    .AXI3_Aw_len (AXI3_Aw_len )
)
u_Res_Virtual_Master(
    .ACLK                      (ACLK                      ),
    .ARESETN                   (ARESETN                   ),
    .Load_The_Original_Signals (Load_The_Original_Signals ),//!
    .Num_Of_Compl_Bursts       (Num_Of_Compl_Bursts       ),
    .Rem                       (Rem                       ),
    .Slave_bresp               (Sel_Write_Resp_Signal     ),
    .Slave_bvalid              (Sel_Valid_Signal          ),
    .Sele_S_AXI_bready         (Sele_S_AXI_bready         ), //!
    .Res_HandShake             (HandShake_Raising         ), 
    .Trans_Split               (Trans_Split               ),
    .Disconnect_Master           (Disconnect_Master           ),
    .Virtual_Sele_S_AXI_bready (Virtual_Sele_S_AXI_bready ),
    .Virtual_M00_AXI_bresp     (Virtual_M00_AXI_bresp     ),
    .Virtual_M00_AXI_bvalid    (Virtual_M00_AXI_bvalid    )
);

BReady_MUX_2_1 u_BReady_MUX_2_1(
    .Selected_Slave    (Sel_M_ID_Signal   ),
    .S00_AXI_bready    (S00_AXI_bready    ),
    .S01_AXI_bready    (S01_AXI_bready    ),
    .Sele_S_AXI_bready (Sele_S_AXI_bready ) 
);

Demux_1_2 #(
    .Data_Width (1'b1 )
)
u_Demux_1_2(
    .Selection_Line (Selected_Slave             ),
    .Input_1        (Virtual_Sele_S_AXI_bready  ),
    .Output_1       (M00_AXI_bready             ),
    .Output_2       (M01_AXI_bready             )
);



// Decoder Module

Write_Resp_Channel_Dec #(
    .Num_Of_Masters (Num_Of_Masters ),
    .M1_ID          (M1_ID          ),
    .M2_ID          (M2_ID          )
)
u_Write_Resp_Channel_Dec(

    .Sel_Resp_ID    (Sel_M_ID_Signal        ),
    .Sel_Write_Resp (Virtual_M00_AXI_bresp  ),
    .Sel_Valid      (Virtual_M00_AXI_bvalid & (~Disconnect_Master) ), //!
    .S01_AXI_bresp  (S01_AXI_bresp  ),
    .S01_AXI_bvalid (S01_AXI_bvalid ),
    .S00_AXI_bresp  (S00_AXI_bresp  ),
    .S00_AXI_bvalid (S00_AXI_bvalid )
);



/*
Write_Resp_Channel_Dec #(
    .Num_Of_Masters     (Num_Of_Masters),
    .Resp_ID_width      (Resp_ID_width),
    .Resp_Channel_Width (Resp_ID_width + 1),
    .M_ID_Width         (Master_ID_Width)

) 
BR_Decoder (
    .Sel_Resp_ID    (Sel_Resp_ID_Signal   ),
    .Sel_Write_Resp (Sel_Write_Resp_Signal),
    .Sel_Valid      (Sel_Valid_Signal     ),
    .Sel_M_ID       (Sel_M_ID_Signal      ),

    .M1_ID          (M1_ID), 
    .M2_ID          (M2_ID),
    .Masters_Ready  ({S01_AXI_bready, S00_AXI_bready}),         

    //Outputs to the Slave 
    .Sel_M_Ready    (Sel_M_Ready_Signal),

    //Ouputs to masters
    .Slave_valid_M1           (S00_AXI_bvalid), 
    .Slave_valid_M2           (S01_AXI_bvalid),
    .Write_Resp_Channel_To_M1 ({2'b00, S00_AXI_bresp}), 
    .Write_Resp_Channel_To_M2 ({2'b00, S01_AXI_bresp})
);*/

//--------------------------------------------------------------------------
/*
Resp_Queue #(
    .Slaves_Num (Slaves_Num )
)
u_Resp_Queue(
    .ACLK                          (ACLK                          ),
    .ARESETN                       (ARESETN                       ),
    .Slave_ID                      (Write_Data_Master                      ),
    .AW_Access_Grant               (Write_Data_Finsh               ),
    .Write_Data_Finsh              (Write_Res_HandShake_Done              ),
    .Queue_Is_Full                 (Queue_Is_Full                 ),
    .Write_Data_HandShake_En_Pulse (Write_Res_HandShake_En_Pulse ),
    .Write_Data_Master             (Write_Res_Master             )
);











Demux_1_2  #(.Data_Width('d2))
u_Demux_master_responese(
    .Selection_Line (Write_Res_Master ),
    .Input_1        (  Virtual_M00_AXI_bresp      ), //!
    .Output_1       (S00_AXI_bresp       ),
    .Output_2       (S01_AXI_bresp       )
);

Demux_1_2 u_Demux_master_response_valid(
    .Selection_Line (Write_Res_Master ),
    .Input_1        (Virtual_M00_AXI_bvalid        ), //!
    .Output_1       (S00_AXI_bvalid       ),
    .Output_2       (S01_AXI_bvalid       ) 
);



*/



endmodule