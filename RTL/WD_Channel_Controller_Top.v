module WD_Channel_Controller_Top #(
    parameter Slaves_Num='d2,Slaves_ID_Size=$clog2(Slaves_Num),Address_width='d32,
              S00_Write_data_bus_width='d32,S00_Write_data_bytes_num=S00_Write_data_bus_width/8,
              S01_Write_data_bus_width='d32,S01_Write_data_bytes_num=S01_Write_data_bus_width/8,
              M00_Write_data_bus_width='d32,M00_Write_data_bytes_num=M00_Write_data_bus_width/8,
              // Added by Mahmoud
              Num_Of_Slaves = 2
) (
    input  wire [Slaves_ID_Size-1:0] AW_Selected_Slave,
    input  wire                      AW_Access_Grant  ,
    input  wire                      Token,
    output wire                      Queue_Is_Full,
 /*GOES TO THE BR CHANNEL*/
    output wire [Slaves_ID_Size-1:0] Write_Data_Master,
    output wire [Slaves_ID_Size-1:0] Write_Data_Master2, // Mahmoud added it
    output wire                      Write_Data_Finsh,
    output wire                      Write_Data_Finsh2, // Mahmoud added it
    output wire                      Is_Master_Part_Of_Split,
    output wire                      Is_Master_Part_Of_Split2, // Mahmoud added it

/*                /***** Interconnect Ports *****/
                /******************************/
    input  wire                          ACLK,
    input  wire                          ARESETN,

/*                /****** Slave S00 Ports *******/
                    /******************************/
    //* Write Data Channel
    
    input  wire  [S00_Write_data_bus_width-1:0]   S00_AXI_wdata,//Write data bus
    input  wire  [S00_Write_data_bytes_num-1:0]   S00_AXI_wstrb, // strops identifes the active data lines
    input  wire                                   S00_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                   S00_AXI_wvalid, // write valid signal
    output wire                                   S00_AXI_wready, // write ready signal
/*                /****** Slave S01 Ports *******/
                    /******************************/
    //* Write Data Channel
    
    input  wire  [S01_Write_data_bus_width-1:0]   S01_AXI_wdata,//Write data bus
    input  wire  [S01_Write_data_bytes_num-1:0]   S01_AXI_wstrb, // strops identifes the active data lines
    input  wire                                   S01_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                   S01_AXI_wvalid, // write valid signal
    output wire                                   S01_AXI_wready, // write ready signal
/*                /****** Master M00 Ports *****/   
                  /*****************************/
   //* Write Data Channel
    output wire  [M00_Write_data_bus_width-1:0]   M00_AXI_wdata,//Write data bus
    output wire  [M00_Write_data_bytes_num-1:0]   M00_AXI_wstrb, // strops identifes the active data lines
    output wire                                   M00_AXI_wlast, // last signal to identify the last transfer in a burst
    output wire                                   M00_AXI_wvalid, // write valid signal
    input  wire                                   M00_AXI_wready, // write ready signal

    /*                /****** Master M01 Ports *****/ // Added by Mahmoud
                  /*****************************/
   //* Write Data Channel
    output wire  [M00_Write_data_bus_width-1:0]   M01_AXI_wdata,//Write data bus
    output wire  [M00_Write_data_bytes_num-1:0]   M01_AXI_wstrb, // strops identifes the active data lines
    output wire                                   M01_AXI_wlast, // last signal to identify the last transfer in a burst
    output wire                                   M01_AXI_wvalid, // write valid signal
    input  wire                                   M01_AXI_wready, // write ready signal

    input  wire  [Num_Of_Slaves - 1 : 0]          Q_Enable_W_Data_In
);
    
wire Write_Data_HandShake_En_Pulse, Write_Data_HandShake_En_Pulse2;
wire Master_Valid_1,Master_Valid_2;
wire Sel_S_AXI_wvalid, Sel_S_AXI_wvalid2;
wire Sel_S_AXI_wlast ,Sel_S_AXI_wlast2;

assign M00_AXI_wvalid=Sel_S_AXI_wvalid & Master_Valid_1;
assign M01_AXI_wvalid=Sel_S_AXI_wvalid2 & Master_Valid_2;

assign M00_AXI_wlast=Sel_S_AXI_wlast;
assign M01_AXI_wlast=Sel_S_AXI_wlast2;

wire Selected_Master_Last, Selected_Master_Last2;

wire S01_wready_1,S01_wready_2;
wire S00_wready_1,S00_wready_2;

wire Queue_Is_Full_1,Queue_Is_Full_2;



assign Queue_Is_Full = (Queue_Is_Full_1 & Q_Enable_W_Data_In[0] ) | (Queue_Is_Full_2 & Q_Enable_W_Data_In[1] );

Queue #(
    .Slaves_Num (Slaves_Num )
)
u_Queue(
    .ACLK                          (ACLK),
    .ARESETN                       (ARESETN),
    .Slave_ID                      (AW_Selected_Slave             ),
    .AW_Access_Grant               (Q_Enable_W_Data_In[0] & AW_Access_Grant        ),
    .Write_Data_Finsh              (Write_Data_Finsh               ),
    .Queue_Is_Full                 (Queue_Is_Full_1                 ),
    .Is_Transaction_Part_of_Split  (Token   ),
    .Master_Valid                  (Master_Valid_1),
    .Write_Data_HandShake_En_Pulse (Write_Data_HandShake_En_Pulse ),
    .Is_Master_Part_Of_Split       (Is_Master_Part_Of_Split       ),
    .Write_Data_Master             (Write_Data_Master             )
);

// Add Another Q for the added Slave "Added by Mahmoud"

Queue #(
    .Slaves_Num (Slaves_Num )
)
u_Queue2(
    .ACLK                          (ACLK),
    .ARESETN                       (ARESETN),
    .Slave_ID                      (AW_Selected_Slave             ),
    .AW_Access_Grant               (Q_Enable_W_Data_In[1] & AW_Access_Grant         ),
    .Write_Data_Finsh              (Write_Data_Finsh2             ),
    .Queue_Is_Full                 (Queue_Is_Full_2                ),
    .Is_Transaction_Part_of_Split  (Token  ),
    .Master_Valid                  (Master_Valid_2),
    .Write_Data_HandShake_En_Pulse (Write_Data_HandShake_En_Pulse2),
    .Is_Master_Part_Of_Split       (Is_Master_Part_Of_Split2      ),
    .Write_Data_Master             (Write_Data_Master2            )
);

// -----------------------------------------------------------------

WD_HandShake u_WD_HandShake(
    .ACLK           (ACLK),
    .ARESETN        (ARESETN),
    .Valid_Signal   (Sel_S_AXI_wvalid             ),
    .Ready_Signal   (M00_AXI_wready               ),
    .Last_Data      (Sel_S_AXI_wlast              ),
    .HandShake_En   (Write_Data_HandShake_En_Pulse),
    .HandShake_Done (Write_Data_Finsh             )
);

// Add Another Handshake unit for the added Slave as we use the crossbar "Added by Mahmoud"

WD_HandShake u_WD_HandShake2(
    .ACLK           (ACLK),
    .ARESETN        (ARESETN),
    .Valid_Signal   (Sel_S_AXI_wvalid2             ), // Ask for it 
    .Ready_Signal   (M01_AXI_wready                ),
    .Last_Data      (Sel_S_AXI_wlast2              ),   //To modify
    .HandShake_En   (Write_Data_HandShake_En_Pulse2),
    .HandShake_Done (Write_Data_Finsh2             )
);

// -------------------------------------------------------------------

Demux_1_2 u_Demux_Write_Data_Ready(
    .Selection_Line (Write_Data_Master),
    .Input_1        (M00_AXI_wready    ),
    .Output_1       (S00_wready_1   ),
    .Output_2       (S01_wready_1   )
);


// Add Another Dmux unit for the added Slave as we use the crossbar "Added by Mahmoud"

Demux_1_2 u_Demux_Write_Data_Ready2(
    .Selection_Line (Write_Data_Master2),
    .Input_1        (M01_AXI_wready    ),
    .Output_1       (S00_wready_2    ),
    .Output_2       (S01_wready_2    )
);

assign S00_AXI_wready= S00_wready_1 | S00_wready_2 ;
assign S01_AXI_wready= S01_wready_1 | S01_wready_2 ;
// -------------------------------------------------------------------

WD_MUX_2_1 u_WD_MUX_2_1(
    .Selected_Slave   (Write_Data_Master  ),
    .S00_AXI_wdata    (S00_AXI_wdata    ),
    .S00_AXI_wstrb    (S00_AXI_wstrb    ),
    .S00_AXI_wlast    (S00_AXI_wlast    ),
    .S00_AXI_wvalid   (S00_AXI_wvalid   ),
    .S01_AXI_wdata    (S01_AXI_wdata    ),
    .S01_AXI_wstrb    (S01_AXI_wstrb    ),
    .S01_AXI_wlast    (S01_AXI_wlast    ),
    .S01_AXI_wvalid   (S01_AXI_wvalid   ),
    .Sel_S_AXI_wdata  (M00_AXI_wdata  ),
    .Sel_S_AXI_wstrb  (M00_AXI_wstrb  ),
    .Sel_S_AXI_wlast  (Selected_Master_Last  ),
    .Sel_S_AXI_wvalid (Sel_S_AXI_wvalid )
);

// Add Another MUX unit for the added Slave as we use the crossbar "Added by Mahmoud"

WD_MUX_2_1 u_WD_MUX_2_1_2(
    .Selected_Slave   (Write_Data_Master2  ),
    .S00_AXI_wdata    (S00_AXI_wdata    ),
    .S00_AXI_wstrb    (S00_AXI_wstrb    ),
    .S00_AXI_wlast    (S00_AXI_wlast    ),
    .S00_AXI_wvalid   (S00_AXI_wvalid   ),
    .S01_AXI_wdata    (S01_AXI_wdata    ),
    .S01_AXI_wstrb    (S01_AXI_wstrb    ),
    .S01_AXI_wlast    (S01_AXI_wlast    ),
    .S01_AXI_wvalid   (S01_AXI_wvalid   ),
    .Sel_S_AXI_wdata  (M01_AXI_wdata  ),
    .Sel_S_AXI_wstrb  (M01_AXI_wstrb  ),
    .Sel_S_AXI_wlast  (Selected_Master_Last2  ),
    .Sel_S_AXI_wvalid (Sel_S_AXI_wvalid2 )
);

// -------------------------------------------------------------------

Data_Virtual_Master u_Data_Virtual_Master(
    .ACLK                 (ACLK                 ),
    .ARESETN              (ARESETN              ),
    .Master_Valid         (Sel_S_AXI_wvalid         ),
    .Enable               (Is_Master_Part_Of_Split),
    .Slave_Ready          (M00_AXI_wready          ),
    .Master_Last_Signal   (Selected_Master_Last   ),
    .Sel_S_AXI_wlast      (Sel_S_AXI_wlast      )
);

// Add Another MUX unit for the added Slave as we use the crossbar "Added by Mahmoud"

Data_Virtual_Master u_Data_Virtual_Master2(
    .ACLK                 (ACLK),
    .ARESETN              (ARESETN),
    .Master_Valid         (Sel_S_AXI_wvalid2       ),
    .Enable               (Is_Master_Part_Of_Split2),
    .Slave_Ready          (M01_AXI_wready          ),
    .Master_Last_Signal   (Selected_Master_Last2   ),
    .Sel_S_AXI_wlast      (Sel_S_AXI_wlast2        )
);

// -------------------------------------------------------------------

endmodule