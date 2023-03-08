`timescale 1ns/1ps
module test_case1 ();

    //----------------------------------------------------------------
    reg clk, reset;  //global clock and reset
    
    //inputss from master 0:
    reg          M0_RREADY;
    reg [31:0]   M0_ARADDR; 
    reg [3:0]    M0_ARLEN; 
    reg [2:0]    M0_ARSIZE; 
    reg [1:0]    M0_ARBURST; 
    reg          M0_ARVALID;

    //inputs from master 1:
    reg          M1_RREADY;
    reg [31:0]   M1_ARADDR; 
    reg [3:0]    M1_ARLEN; 
    reg [2:0]    M1_ARSIZE; 
    reg [1:0]    M1_ARBURST; 
    reg          M1_ARVALID;

    //inputs from the slave 0:
    reg          S0_ARREADY; 
    reg          S0_RVALID; 
    reg          S0_RLAST; 
    reg [1:0]    S0_RRESP; 
    reg [31:0]   S0_RDATA; 
    
    //inputs from the slave 1:
    reg          S1_ARREADY; 
    reg          S1_RVALID; 
    reg          S1_RLAST; 
    reg [1:0]    S1_RRESP; 
    reg [31:0]   S1_RDATA; 

    //addresses ranges for each slave:
    reg [31:0] slave0_addr1 = 32'd1;
    reg [31:0] slave0_addr2 = 32'd5;
    reg [31:0] slave1_addr1 = 32'd10;
    reg [31:0] slave1_addr2 = 32'd15;

    //--------------------------------------------------------------

    //outputs to master 0:
    wire           ARREADY_M0; 
    wire           RVALID_M0; 
    wire           RLAST_M0; 
    wire  [1:0]    RRESP_M0; 
    wire  [31:0]   RDATA_M0; 

    //outputs to master 1:
    wire           ARREADY_M1; 
    wire           RVALID_M1; 
    wire           RLAST_M1; 
    wire  [1:0]    RRESP_M1; 
    wire  [31:0]   RDATA_M1; 

    //outputs to the slave 0:
    wire  [31:0]    ARADDR_S0;
    wire  [3:0]     ARLEN_S0;
    wire  [2:0]     ARSIZE_S0;
    wire  [1:0]     ARBURST_S0; 
    wire            ARVALID_S0;
    wire            RREADY_S0;

    //outputs to the slave 1:
    wire  [31:0]    ARADDR_S1;
    wire  [3:0]     ARLEN_S1;
    wire  [2:0]     ARSIZE_S1;
    wire  [1:0]     ARBURST_S1; 
    wire            ARVALID_S1;
    wire            RREADY_S1;

    

//----------------------------------------------------------

AXI_Interconnect DUT (
    .G_clk                (clk),
    .G_reset              (reset),

    .M0_RREADY            (M0_RREADY),
    .M0_ARADDR            (M0_ARADDR),
    .M0_ARLEN             (M0_ARLEN),
    .M0_ARSIZE            (M0_ARSIZE),
    .M0_ARBURST           (M0_ARBURST),
    .M0_ARVALID           (M0_ARVALID),

    .M1_RREADY            (M1_RREADY),
    .M1_ARADDR            (M1_ARADDR),
    .M1_ARLEN             (M1_ARLEN),
    .M1_ARSIZE            (M1_ARSIZE),
    .M1_ARBURST           (M1_ARBURST),
    .M1_ARVALID           (M1_ARVALID),

    .S0_ARREADY            (S0_ARREADY),
    .S0_RVALID             (S0_RVALID),
    .S0_RLAST              (S0_RLAST),
    .S0_RRESP              (S0_RRESP),
    .S0_RDATA              (S0_RDATA),

    .S1_ARREADY            (S1_ARREADY),
    .S1_RVALID             (S1_RVALID),
    .S1_RLAST              (S1_RLAST),
    .S1_RRESP              (S1_RRESP),
    .S1_RDATA              (S1_RDATA),

    .slave0_addr1          (slave0_addr1),
    .slave0_addr2          (slave0_addr2),
    .slave1_addr1          (slave1_addr1),
    .slave1_addr2          (slave1_addr2),

    .ARREADY_M0           (ARREADY_M0),
    .RVALID_M0            (RVALID_M0),
    .RLAST_M0             (RLAST_M0),
    .RRESP_M0             (RRESP_M0),
    .RDATA_M0             (RDATA_M0),

    .ARREADY_M1           (ARREADY_M1),
    .RVALID_M1            (RVALID_M1),
    .RLAST_M1             (RLAST_M1),
    .RRESP_M1             (RRESP_M1),
    .RDATA_M1             (RDATA_M1),

    .ARADDR_S0            (ARADDR_S0),
    .ARLEN_S0             (ARLEN_S0),
    .ARSIZE_S0            (ARSIZE_S0),
    .ARBURST_S0           (ARBURST_S0),
    .ARVALID_S0           (ARVALID_S0),
    .RREADY_S0            (RREADY_S0),

    .ARADDR_S1            (ARADDR_S1),
    .ARLEN_S1             (ARLEN_S1),
    .ARSIZE_S1            (ARSIZE_S1),
    .ARBURST_S1           (ARBURST_S1),
    .ARVALID_S1           (ARVALID_S1),
    .RREADY_S1            (RREADY_S1)

);

initial begin 
    clk = 1;

    forever #5 clk = ~clk;
end

initial begin
    reset = 0;
    #100
    reset = 1;
end

initial begin
    
    #100                //reset before starting
    M0_RREADY = 0;
    M0_ARADDR = 32'd0;
    M0_ARLEN = 4'b0000;
    M0_ARSIZE = 3'b000;
    M0_ARBURST = 2'b00;
    M0_ARVALID = 0;

    M1_RREADY = 0;
    M1_ARADDR = 32'd0;
    M1_ARLEN = 4'b0000;
    M1_ARSIZE = 3'b000;
    M1_ARBURST = 2'b00;
    M1_ARVALID = 0;

    S0_ARREADY = 0; 
    S0_RVALID = 0; 
    S0_RLAST = 0; 
    S0_RRESP = 0; 
    S0_RDATA = 0; 

    S1_ARREADY = 0; 
    S1_RVALID = 0; 
    S1_RLAST = 0; 
    S1_RRESP = 0; 
    S1_RDATA = 0; 
    
    
    //-----------------------------------------------------------------
    #5            //M0 asserts valid and sends address
    
    M0_ARADDR = 32'd2;
    M0_ARLEN = 4'b0001;
    M0_ARSIZE = 3'b001;
    M0_ARBURST = 2'b01;
    M0_ARVALID = 1;

    
    
    //-----------------------------------------------------------------
    #12
    S0_ARREADY = 1; 

//completed at 120ns
    //-----------------------------------------------------------------
    #3
    S0_ARREADY = 0;
    M0_ARADDR = 32'd0;
    M0_ARLEN = 4'b0000;
    M0_ARSIZE = 3'b000;
    M0_ARBURST = 2'b00;
    M0_ARVALID = 0;
    
    //-----------------------------------------------------------------
    #15 //135ns
    S0_RVALID = 1; 
    S0_RLAST = 1; 
    S0_RRESP = 1; 
    S0_RDATA = 32'd1;


    //-----------------------------------------------------------------
    #10 //145ns
    M0_RREADY = 1;
//completed at 150ns
    //-----------------------------------------------------------------
    #5 //150ns
    M0_RREADY = 0;
    S0_RVALID = 0; 
    S0_RLAST = 0; 
    S0_RRESP = 0; 
    S0_RDATA = 32'd0;
    //-----------------------------------------------------------------
    //-----------------------------------------------------------------
    
    #15 //165ns            //M0 asserts valid and sends address
    
    M0_ARADDR = 32'd11;
    M0_ARLEN = 4'b1111;
    M0_ARSIZE = 3'b111;
    M0_ARBURST = 2'b11;
    M0_ARVALID = 1;

    
    
    //-----------------------------------------------------------------
    #12 //177ns
    S1_ARREADY = 1; 

//completed at 177ns
    //-----------------------------------------------------------------
    #3 //180
    S1_ARREADY = 0;
    M0_ARADDR = 32'd0;
    M0_ARLEN = 4'b0000;
    M0_ARSIZE = 3'b000;
    M0_ARBURST = 2'b00;
    M0_ARVALID = 0;
    
    //-----------------------------------------------------------------
    #15 //195ns
    S1_RVALID = 1; 
    S1_RLAST = 1; 
    S1_RRESP = 1; 
    S1_RDATA = 32'd2;


    //-----------------------------------------------------------------
    #10 //205ns
    M0_RREADY = 1;
//completed at 210ns
    //-----------------------------------------------------------------
    #5 //210ns
    M0_RREADY = 0;
    S1_RVALID = 0; 
    S1_RLAST = 0; 
    S1_RRESP = 0; 
    S1_RDATA = 32'd0;
    //-----------------------------------------------------------------
    

end


endmodule


