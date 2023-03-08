module AXI4_2_AXI3_Convertor #(
    parameter Address_width='d32,AXI4_Aw_len='d8,AXI3_Aw_len='d4
) (
    input  wire                          Queue_Is_Full,
    input  wire                          HandShake_Is_High,
    input  wire                          HandShake_Done,
    input  wire                          Burst_Out, // failing edge
    output reg                           Enable_Burst,
    output reg                           Channel_Req_burst,
    output wire                          Load_The_Original_Signals,
    output wire [(AXI4_Aw_len/'d2)-1:0]  Rem, //Reminder of the divsion
    output wire [(AXI4_Aw_len/'d2)-1:0]  Num_Of_Compl_Bursts, // Number of Complete Bursts
    output wire                          Disconnect_Master,

    input  wire                          ACLK,
    input  wire                          ARESETN,
    
    //* Address Write Channel
    input  wire  [Address_width-1:0]      AXI4_Sel_S_AXI_awaddr,// the write address
    input  wire  [AXI4_Aw_len-1:0]        AXI4_Sel_S_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                    AXI4_Sel_S_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                    AXI4_Sel_S_AXI_awburst, // burst type
    input  wire  [1:0]                    AXI4_Sel_S_AXI_awlock , // lock type
    input  wire  [3:0]                    AXI4_Sel_S_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                    AXI4_Sel_S_AXI_awprot ,// identifies the level of protection
    input  wire                           AXI4_Sel_S_AXI_awvalid, // Address write valid signal  

    output  reg  [Address_width-1:0]     AXI3_Sel_S_AXI_awaddr,// the write address
    output  reg  [AXI3_Aw_len-1:0]       AXI3_Sel_S_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    output  reg  [2:0]                   AXI3_Sel_S_AXI_awsize,//number of bytes within the transfer
    output  reg  [1:0]                   AXI3_Sel_S_AXI_awburst, // burst type
    output  reg  [1:0]                   AXI3_Sel_S_AXI_awlock , // lock type
    output  reg  [3:0]                   AXI3_Sel_S_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    output  reg  [2:0]                   AXI3_Sel_S_AXI_awprot ,// identifies the level of protection
    output  reg                          AXI3_Sel_S_AXI_awvalid // Address write valid signal  
);

//reg Enable_Burst;

reg EPulse;
wire Enable_Pulse;
reg Token;
reg Pulse;

reg [1:0] Lock_Conv;
wire [Address_width-1:0]      Virtual_Master_AXI_awaddr;
wire [AXI3_Aw_len-1:0]        Virtual_Master_AXI_awlen;
wire [2:0]                    Virtual_Master_AXI_awsize;
wire [1:0]                    Virtual_Master_AXI_awburst;
wire [1:0]                    Virtual_Master_AXI_awlock ;
wire [3:0]                    Virtual_Master_AXI_awcache;
wire [2:0]                    Virtual_Master_AXI_awprot ;
wire                          Virtual_Master_AXI_awvalid;
wire Last_Trans;

always @(*) begin
    if ((~|AXI4_Sel_S_AXI_awlen[AXI4_Aw_len-1:4]) ) begin
        Enable_Burst='b0;
    end else begin
        Enable_Burst='b1;
    end

end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        EPulse<='b0;
    end else begin 
        EPulse<=Enable_Burst;
end
end
assign Enable_Pulse = (~EPulse) & Enable_Burst ;


always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Token<='b0;
    end else if(Last_Trans && HandShake_Done) begin //!
        Token<='b0;
    end else if (Enable_Pulse) begin
        Token<='b1;
    end
end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Pulse<='b0;
    end else  begin
        Pulse<=Token;
    end
end
assign Load_The_Original_Signals = (~Pulse) & Token;

always @(posedge ACLK or negedge ARESETN) begin
     if (!ARESETN) begin
        Channel_Req_burst='b0; 
    end else if (HandShake_Is_High && Token && (~Queue_Is_Full)) begin
        Channel_Req_burst='b1; 
    end else begin
        Channel_Req_burst='b0;
    end

end
//assign Next_Burst =(AW_Channel_Is_Grant) & (~Queue_Is_Full) & Token ;

always @(*) begin
    if (!Token) begin
        AXI3_Sel_S_AXI_awaddr =AXI4_Sel_S_AXI_awaddr;
        AXI3_Sel_S_AXI_awlen=AXI4_Sel_S_AXI_awlen;
        AXI3_Sel_S_AXI_awsize=AXI4_Sel_S_AXI_awsize;
        AXI3_Sel_S_AXI_awburst=AXI4_Sel_S_AXI_awburst;
        AXI3_Sel_S_AXI_awlock=Lock_Conv;
        AXI3_Sel_S_AXI_awcache=AXI4_Sel_S_AXI_awcache;
        AXI3_Sel_S_AXI_awprot=AXI4_Sel_S_AXI_awprot;
        AXI3_Sel_S_AXI_awvalid=AXI4_Sel_S_AXI_awvalid;
    end else begin
        AXI3_Sel_S_AXI_awaddr =Virtual_Master_AXI_awaddr;
        AXI3_Sel_S_AXI_awlen=  Virtual_Master_AXI_awlen;
        AXI3_Sel_S_AXI_awsize= Virtual_Master_AXI_awsize;
        AXI3_Sel_S_AXI_awburst=Virtual_Master_AXI_awburst;
        AXI3_Sel_S_AXI_awlock= Virtual_Master_AXI_awlock;
        AXI3_Sel_S_AXI_awcache=Virtual_Master_AXI_awcache;
        AXI3_Sel_S_AXI_awprot= Virtual_Master_AXI_awprot;
        AXI3_Sel_S_AXI_awvalid=Virtual_Master_AXI_awvalid;
    end

end

// Lock Matching Table
always @(*) begin
    case (AXI4_Sel_S_AXI_awlock)
           'b00,'b01:begin
               Lock_Conv=AXI4_Sel_S_AXI_awlock;
           end
           'b10,'b11:begin
               Lock_Conv='b00;
           end  
       endcase  
end

Virtual_Master #(
    .Address_width (Address_width ),
    .AXI4_Aw_len   (AXI4_Aw_len   ),
    .AXI3_Aw_len   (AXI3_Aw_len   )
)
u_Virtual_Master(
    .ACLK                       (ACLK                       ),
    .ARESETN                    (ARESETN                    ),
    .Burst_Out                  (Burst_Out                 ),//! Burst_Out is an indecatiin that we can out a new burst
    .Load_The_Original_Signals  (Load_The_Original_Signals  ),
    .Token                      (Token                      ),
    .Num_Of_Compl_Bursts        (Num_Of_Compl_Bursts        ),
    .Rem                        (Rem                        ),
    .Disconnect_Master          (Disconnect_Master),
    .Last_Trans                 (Last_Trans                 ), //!
    .AXI4_Sel_S_AXI_awaddr      (AXI4_Sel_S_AXI_awaddr      ),
    .AXI4_Sel_S_AXI_awlen       (AXI4_Sel_S_AXI_awlen       ),
    .AXI4_Sel_S_AXI_awsize      (AXI4_Sel_S_AXI_awsize      ),
    .AXI4_Sel_S_AXI_awburst     (AXI4_Sel_S_AXI_awburst     ),
    .AXI4_Sel_S_AXI_awlock      (AXI4_Sel_S_AXI_awlock      ),
    .AXI4_Sel_S_AXI_awcache     (AXI4_Sel_S_AXI_awcache     ),
    .AXI4_Sel_S_AXI_awprot      (AXI4_Sel_S_AXI_awprot      ),
    .AXI4_Sel_S_AXI_awvalid     (AXI4_Sel_S_AXI_awvalid     ),
    .Virtual_Master_AXI_awaddr  (Virtual_Master_AXI_awaddr  ),
    .Virtual_Master_AXI_awlen   (Virtual_Master_AXI_awlen   ),
    .Virtual_Master_AXI_awsize  (Virtual_Master_AXI_awsize  ),
    .Virtual_Master_AXI_awburst (Virtual_Master_AXI_awburst ),
    .Virtual_Master_AXI_awlock  (Virtual_Master_AXI_awlock  ),
    .Virtual_Master_AXI_awcache (Virtual_Master_AXI_awcache ),
    .Virtual_Master_AXI_awprot  (Virtual_Master_AXI_awprot  ),
    .Virtual_Master_AXI_awvalid (Virtual_Master_AXI_awvalid )
);



    
endmodule