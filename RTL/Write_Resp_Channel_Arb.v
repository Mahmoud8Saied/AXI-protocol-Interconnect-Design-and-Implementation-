module Write_Resp_Channel_Arb #(
    parameter  Num_Of_Masters ='d2, Masters_Id_Size=$clog2(Num_Of_Masters),
    parameter Num_Of_Slaves = 2 ,Slaves_Id_Size=$clog2(Num_Of_Slaves)
) (
    input  wire                          clk, rst,
   
    input  wire                          Channel_Granted,


    // Slaves Ports -----------------------------------------------
    // Slave 1

    input  wire [Masters_Id_Size-1:0]    M00_AXI_BID  ,
    input  wire [1:0]                    M00_AXI_bresp,//Write response
    input  wire                          M00_AXI_bvalid, //Write response valid signal
    // Slave 2
    input  wire [Masters_Id_Size-1:0]    M01_AXI_BID  ,
    input  wire [1:0]                    M01_AXI_bresp,//Write response
    input  wire                          M01_AXI_bvalid, //Write response valid signal
    // ------------------------------------------------------------
                                            
    output reg                           Channel_Request,
    output reg  [Slaves_Id_Size - 1 : 0]  Selected_Slave, 
    
    output reg  [Masters_Id_Size - 1 : 0]  Sel_Resp_ID,
    output reg  [1:0]                    Sel_Write_Resp,
    output reg                           Sel_Valid
);


reg [Slaves_Id_Size-1:0]  Slave_Sel;
reg [Masters_Id_Size-1:0]  Sel_Resp_ID_Comb;
reg [1:0] Sel_Write_Resp_Comb;
reg       Sel_Valid_Comb;

reg Channel_Request_Com;
wire [Num_Of_Slaves - 1 : 0]  Slaves_Valid;
assign Slaves_Valid ={M01_AXI_bvalid,M00_AXI_bvalid};

always @(*) begin
    if ((|Slaves_Valid)) begin
        if (Channel_Granted ) 
            begin
                Channel_Request='b1;
                
            end else begin
                Channel_Request = 'b0;
            end
    end else begin
        Channel_Request='b0;
    end
end
/*
    always @(posedge clk or negedge rst) begin
        if (!rst) 
            begin
                Channel_Request<='b0;
            end 
        else if (!Channel_Granted ) 
            begin
                Channel_Request <= 'b0;
            end 
        else 
            begin
                Channel_Request <= Channel_Request_Com;
            end
    end
*/
    always @(*) 
    begin
          if ((Slaves_Valid == {{(Num_Of_Slaves-2){1'b0}}, 2'b01}) || (Slaves_Valid == {{(Num_Of_Slaves-2){1'b0}}, 2'b11}))
            begin
                
                Slave_Sel           =  'b0;
                Sel_Write_Resp_Comb = M00_AXI_bresp;
                Sel_Valid_Comb      = Slaves_Valid[0];
                Sel_Resp_ID_Comb       = M00_AXI_BID;
            end 
          else if (Slaves_Valid == {{(Num_Of_Slaves-2){1'b0}}, 2'b10}) 
            begin
                Slave_Sel ='b1;
                Sel_Write_Resp_Comb = M01_AXI_bresp;
                Sel_Valid_Comb      = Slaves_Valid[1];
                Sel_Resp_ID_Comb       = M01_AXI_BID;
            end 
          else 
            begin
                Slave_Sel = 'b0;
                Sel_Write_Resp_Comb      = 'b0;
                Sel_Valid_Comb           = 'b0;
                Sel_Resp_ID_Comb         = 'b0;
            end 
    end

    always @(posedge clk or negedge rst ) begin
        if (!rst) 
         begin
            Selected_Slave <= 'b0;
            //Sel_Resp_ID    <= 'b0;
            //Sel_Write_Resp <= 1'b0; 
            //Sel_Valid      <= 1'b0;        
         end 
        else if (Channel_Granted) 
         begin
            Selected_Slave <= Slave_Sel;
            //Sel_Resp_ID    <= Sel_Resp_ID_Comb;    
            //Sel_Write_Resp <= Sel_Write_Resp_Comb; 
            //Sel_Valid      <= Sel_Valid_Comb;
         end

    end

    always @(*) begin
        if (Selected_Slave=='b0) begin
            Sel_Resp_ID=M00_AXI_BID;
            Sel_Write_Resp=M00_AXI_bresp;
            Sel_Valid=M00_AXI_bvalid;
        end else begin
            Sel_Resp_ID=M01_AXI_BID;
            Sel_Write_Resp=M01_AXI_bresp;
            Sel_Valid=M01_AXI_bvalid;
        end

    end

endmodule