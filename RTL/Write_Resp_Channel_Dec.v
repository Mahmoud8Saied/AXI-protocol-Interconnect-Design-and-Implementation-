module Write_Resp_Channel_Dec #(
    parameter Num_Of_Masters = 2, Master_ID_Width=$clog2(Num_Of_Masters),
    parameter M1_ID ='d0 ,M2_ID='d1

) (
    input wire [Master_ID_Width - 1 : 0]  Sel_Resp_ID,
    input wire [1:0]                     Sel_Write_Resp,
    input wire                           Sel_Valid,
    //Ouputs to masters
//*Write Response Channel
    output wire  [1:0]                  S01_AXI_bresp,//Write response
    output reg                          S01_AXI_bvalid, //Write response valid signal
    
/*                /****** Slave S00 Ports *******/
                    /******************************/
 //*Write Response Channel
    output wire  [1:0]                  S00_AXI_bresp,//Write response
    output reg                          S00_AXI_bvalid //Write response valid signal
   
);

assign  S00_AXI_bresp=   Sel_Write_Resp;
assign  S01_AXI_bresp=   Sel_Write_Resp;
    always @(*) begin
        
        case (Sel_Resp_ID)
            M1_ID : begin
                S00_AXI_bvalid= Sel_Valid;
                S01_AXI_bvalid= 'b0;
            end

            M2_ID : begin
                S00_AXI_bvalid= 'b0;
                S01_AXI_bvalid= Sel_Valid;
            end
            default: begin

                S00_AXI_bvalid= 'b0;
                S01_AXI_bvalid= 'b0;
            end

        endcase

    end
endmodule