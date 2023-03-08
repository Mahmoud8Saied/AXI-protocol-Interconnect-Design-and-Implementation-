module Data_Virtual_Master
(
    input  wire  ACLK,
    input  wire  ARESETN,
    input  wire  Master_Valid,
    input  wire  Slave_Ready,
    input  wire  Enable,
    input  wire  Master_Last_Signal,
    output reg   Sel_S_AXI_wlast
);
reg [3:0] Last_Counter;
reg Counter_RST; 
reg Small_Data_HandShake;
reg Virtual_Master_Last_Signal;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Last_Counter<='b0;
        end else if (Counter_RST && Enable )begin
            Last_Counter<='b0;
        end else if( Small_Data_HandShake && Enable) begin
            Last_Counter<=Last_Counter+1;
        end
    end

    always @(*) begin
        if ((Last_Counter=='d15) && Small_Data_HandShake && Enable ) begin
            Counter_RST='b1;
        end else begin
            Counter_RST='b0;
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Virtual_Master_Last_Signal<='b0;
        end else if((Last_Counter=='d14) && Small_Data_HandShake && Enable) begin
            Virtual_Master_Last_Signal<='b1;
        end else if (Counter_RST && Enable) begin
            Virtual_Master_Last_Signal<='b0;
        end
    end
    
    always @(*) begin
        Sel_S_AXI_wlast = Master_Last_Signal | Virtual_Master_Last_Signal ;
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Small_Data_HandShake<='b0;
        end else if(Small_Data_HandShake && Enable)begin
            Small_Data_HandShake<='b0;
        end else if(Master_Valid && Slave_Ready && Enable) begin
            Small_Data_HandShake<='b1;
        end else begin
            Small_Data_HandShake<='b0;
        end
    end


    

endmodule