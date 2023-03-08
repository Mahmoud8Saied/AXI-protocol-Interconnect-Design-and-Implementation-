module Virtual_Master #(
    parameter Address_width='d32,AXI4_Aw_len='d8,AXI3_Aw_len='d4
) (
    input  wire                           ACLK,
    input  wire                           ARESETN,

    input  wire                           Load_The_Original_Signals,
    input  wire                           Burst_Out, //! Burst_Out is an indecatiin that we can out a new burst
    input  wire                           Token,
    output reg                            Last_Trans,
    output reg [(AXI4_Aw_len/'d2)-1:0]    Rem, //Reminder of the divsion
    output reg [(AXI4_Aw_len/'d2)-1:0]    Num_Of_Compl_Bursts, // Number of Complete Bursts
    output reg                            Disconnect_Master,

    input  wire  [Address_width-1:0]      AXI4_Sel_S_AXI_awaddr,// the write address
    input  wire  [AXI4_Aw_len-1:0]        AXI4_Sel_S_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    input  wire  [2:0]                    AXI4_Sel_S_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                    AXI4_Sel_S_AXI_awburst, // burst type
    input  wire  [1:0]                    AXI4_Sel_S_AXI_awlock , // lock type
    input  wire  [3:0]                    AXI4_Sel_S_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                    AXI4_Sel_S_AXI_awprot ,// identifies the level of protection
    input  wire                           AXI4_Sel_S_AXI_awvalid, // Address write valid signal  
    
    output  reg  [Address_width-1:0]      Virtual_Master_AXI_awaddr,// the write address
    output  reg  [AXI3_Aw_len-1:0]        Virtual_Master_AXI_awlen, // number of transfer per burst //! For AXI3 limt is 16 and AXI4 is 256 for inc bursts only 
    output  reg  [2:0]                    Virtual_Master_AXI_awsize,//number of bytes within the transfer
    output  reg  [1:0]                    Virtual_Master_AXI_awburst, // burst type
    output  reg  [1:0]                    Virtual_Master_AXI_awlock , // lock type
    output  reg  [3:0]                    Virtual_Master_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    output  reg  [2:0]                    Virtual_Master_AXI_awprot ,// identifies the level of protection
    output  reg                          Virtual_Master_AXI_awvalid // Address write valid signal     

);

wire Last_Compl_Burst; 
//reg [9:0] Lower_Address_Bits;
//reg [32:10] Higher_Address_Bits;
reg [15:0] Num_Of_Bytes; //!

always @(*) begin
    if (Token) begin
        Virtual_Master_AXI_awvalid='b1;
    end else begin
        Virtual_Master_AXI_awvalid='b0;
    end
end

/*****************************************************************************/
// Lock Signal Decoding 
always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
       Virtual_Master_AXI_awlock<='b0; 
    end else if (Load_The_Original_Signals) begin
        case (AXI4_Sel_S_AXI_awlock)
            'b00,'b01:begin
               Virtual_Master_AXI_awlock<=AXI4_Sel_S_AXI_awlock;
           end
           'b10,'b11:begin
               Virtual_Master_AXI_awlock<='b00;
           end  
        endcase
    end
end

/*****************************************************************************/
// Burst Signal 
always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        
        Num_Of_Compl_Bursts<='b0;
    end else if(Load_The_Original_Signals) begin
        Num_Of_Compl_Bursts<=AXI4_Sel_S_AXI_awlen >>'d4;
        
    end else if (Burst_Out && !Last_Compl_Burst && Token) begin //! Burst_Out is an indecatiin that we can out a new burst
        Num_Of_Compl_Bursts<=Num_Of_Compl_Bursts-'d1;
        
    end
end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Disconnect_Master<='b0;
    end else if(Load_The_Original_Signals) begin
        Disconnect_Master<='b0;
    end else if (Burst_Out && !Last_Compl_Burst && Token) begin //! Burst_Out is an indecatiin that we can out a new burst
        Disconnect_Master<='b1;
    end else if (!Token)begin
        Disconnect_Master<='b0;
    end
    
end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Rem<='b0;
    end else if(Load_The_Original_Signals) begin
        Rem<=AXI4_Sel_S_AXI_awlen[(AXI4_Aw_len/'d2)-1:0];       
    end 
end

always @(*) begin
    if (!Last_Compl_Burst) begin
        Virtual_Master_AXI_awlen='d15;
        Last_Trans='b0;
    end else begin
        Virtual_Master_AXI_awlen=Rem;
        Last_Trans='b1;
    end
end

assign Last_Compl_Burst = ~|Num_Of_Compl_Bursts;


/*****************************************************************************/
// Address Signal Channel

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Virtual_Master_AXI_awaddr<='b0;
    end else if (Load_The_Original_Signals) begin
        Virtual_Master_AXI_awaddr<=AXI4_Sel_S_AXI_awaddr;
    end else if (Burst_Out && Token) begin 
        Virtual_Master_AXI_awaddr<=Virtual_Master_AXI_awaddr+Num_Of_Bytes;
    end
end
/*
always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
        Higher_Address_Bits<='b0;
    end else if (Load_The_Original_Signals) begin
        Higher_Address_Bits<=AXI4_Sel_S_AXI_awaddr[31:10];
    end
end*/

//assign Virtual_Master_AXI_awaddr= {Higher_Address_Bits,Lower_Address_Bits};


always @(*) begin
    case (Virtual_Master_AXI_awsize )
        'b000:begin
            Num_Of_Bytes='d16;
        end 
        'b001:begin
            Num_Of_Bytes='d32;
        end
        'b010:begin
            Num_Of_Bytes='d64;
        end
        'b011:begin
            Num_Of_Bytes='d128;
        end
        'b100:begin
            Num_Of_Bytes='d256;
        end
        'b101:begin
            Num_Of_Bytes='d512;
        end
        'b110:begin
            Num_Of_Bytes='d1024;
        end
        'b111:begin
            Num_Of_Bytes='d2048;
        end
    endcase
   
end

/*****************************************************************************/
always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
       Virtual_Master_AXI_awsize<='b0; 
    end else if (Load_The_Original_Signals) begin
       Virtual_Master_AXI_awsize<= AXI4_Sel_S_AXI_awsize;
    end
end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
       Virtual_Master_AXI_awburst<='b0; 
    end else if (Load_The_Original_Signals) begin
       Virtual_Master_AXI_awburst<= AXI4_Sel_S_AXI_awburst;
    end
end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
       Virtual_Master_AXI_awcache<='b0; 
    end else if (Load_The_Original_Signals) begin
       Virtual_Master_AXI_awcache<= AXI4_Sel_S_AXI_awcache;
    end
end

always @(posedge ACLK or negedge ARESETN ) begin
    if (!ARESETN) begin
       Virtual_Master_AXI_awprot<='b0; 
    end else if (Load_The_Original_Signals) begin
       Virtual_Master_AXI_awprot<= AXI4_Sel_S_AXI_awprot;
    end
end
endmodule