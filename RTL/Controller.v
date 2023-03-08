module Controller (

    //---------------------- Input Ports ----------------------
    input clkk, resett,

    //input from reg file to indicate range of addresses of slave 0:
    input wire [31:0] slave0_addr1, 
    input wire [31:0] slave0_addr2,

    //input from reg file to indicate range of addresses of slave 1:
    input wire [31:0] slave1_addr1,
    input wire [31:0] slave1_addr2,

    //valid signal from the master on read address channel:
//    input wire ARVALID_M, 

    //Address from the master on read address channel:
    input wire [31:0] M_ADDR,

    //signal from the first FSM to indicate which master is sending data:
    //input wire data_M,

    //**********************************
    //input wire [3:0] ARID_M,

    //ready signal form each slave:
    input wire S0_ARREADY,
    input wire S1_ARREADY,

    //two valid signals from masters on read address channel:
    input wire M0_ARVALID, 
    input wire M1_ARVALID, 

    //two ready signals from masters on read data channel:
    input wire M0_RREADY,
    input wire M1_RREADY,

    //valid signal form each slave:
    input wire S0_RVALID,
    input wire S1_RVALID,

    //valid signal form each slave:
    input wire S0_RLAST,
    input wire S1_RLAST,
    

    //input wire [3:0] RID_S,
    //**********************************



//--------------------------------------------------------------------

    
    //ready signal form slave going to each master on read address channel:
    //input wire S_ARREADY_M0,
    //input wire S_ARREADY_M1,

    //last signal form slave going to each master on read data channel:
    //input wire S_RLAST_M0, 
    //input wire S_RLAST_M1, 

    //valid signal form slave going to each master on read data channel:
    //input wire S_RVALID_M0,
    //input wire S_RVALID_M1, 

    
    //---------------------- Output Ports ----------------------
    
    // select lines for muxs to choose which master control each channel:
    output reg select_slave_address, select_data_M0, select_data_M1,

    //enable signal based on the ID from slave to choose the right master:
    output reg en_S0, en_S1,
    output reg enable_S0, enable_S1,

    output reg select_master_address
);

//---------------------- Code Start ----------------------
reg [1:0] curr_state_slave, next_state_slave, curr_state_slave2;

reg [1:0] curr_state_address, next_state_address, next_state_slave2;

//reg Ch0_busy, Ch1_busy;
reg S0_busy = 0, S1_busy = 0;
reg M1_wait;

localparam Idle_address = 2'b00;
localparam M0_Address = 2'b01;
localparam M1_Address = 2'b10;

localparam Idle_slave = 2'b00;
localparam Slave0 = 2'b01;
localparam Slave1 = 2'b10;

localparam Idle_slave_2 = 2'b00;
localparam Slave0_2 = 2'b01;
localparam Slave1_2 = 2'b10;


always @(posedge clkk or negedge resett) begin
    if(!resett)begin
        curr_state_slave <= Idle_slave;
        curr_state_slave2 <= Idle_slave_2;
        curr_state_address <= Idle_address;

    end
    else begin
        curr_state_slave <= next_state_slave;
        curr_state_slave2 <= next_state_slave2;
        curr_state_address <= next_state_address;

    end
end


always @(*) begin
    case (curr_state_address)
        Idle_address:begin
            if(M0_ARVALID && M1_ARVALID)begin
                next_state_address = M0_Address; 
                select_master_address = 1'b0;
                M1_wait = 1'b1;
            end
            else begin
                if((M0_ARVALID && S0_ARREADY) || (M0_ARVALID && S1_ARREADY) || (M1_ARVALID && S0_ARREADY) || (M1_ARVALID && S1_ARREADY))begin
                    next_state_address = Idle_address;
                    //select_slave_address = 1'bx;
                end
                else if(M0_ARVALID)begin
                    next_state_address = M0_Address; 
                    select_master_address = 1'b0;
                    if(M_ADDR <= slave0_addr2 && M_ADDR >= slave0_addr1)begin
                        select_slave_address = 1'b0;    
                    end
                    else if(M_ADDR <= slave1_addr2 && M_ADDR >= slave1_addr1)begin
                        select_slave_address = 1'b1;
                    end
                    else next_state_address = Idle_address;
                end
                else if(M1_ARVALID)begin
                    next_state_address = M1_Address; 
                    select_master_address = 1'b1;
                    if(M_ADDR <= slave0_addr2 && M_ADDR >= slave0_addr1)begin
                        select_slave_address = 1'b0;    
                    end
                    else if(M_ADDR <= slave1_addr2 && M_ADDR >= slave1_addr1)begin
                        select_slave_address = 1'b1;
                    end
                end
                else next_state_address = Idle_address;
            end
        end
        M0_Address:begin
            //if(!S0_busy)begin  //not sure
                //if(M_ADDR <= slave0_addr2 && M_ADDR >= slave0_addr1)begin //not sure (maybe check id)
                    //select_slave_address = 1'b0;
                    if(M0_ARVALID && S0_ARREADY) begin
                        next_state_slave = Slave0; 
                        //select_slave_address = 1'bx;
                        //select_data_M0 = 1'b0; //not sure this is the right place
                        next_state_address =Idle_address;
                    end
                    //else next_state_address = M0_Address;//not idle
                //end
                //else if(M_ADDR <= slave1_addr2 && M_ADDR >= slave1_addr1)begin
                    //select_slave_address = 1'b1;
                    else if(M0_ARVALID && S1_ARREADY) begin
                        next_state_slave = Slave1;
                        //select_slave_address = 1'bx;
                        //select_data_M1 = 1'b1;//not sure this is the right place
                        next_state_address =Idle_address;
                    end
                    //else next_state_address = M0_Address;//not idle
                //end
                else next_state_address = Idle_address;//wrong address
            //end

            /*else: begin
                next_state_address = M0_Address; //may be idle
            end*/
        end
        M1_Address:begin
            //if(M_ADDR <= slave0_addr2 && M_ADDR >= slave0_addr1)begin
                //select_slave_address = 1'b0;
                if(M1_ARVALID && S0_ARREADY) begin

                    next_state_slave2 = Slave0_2;
                    //select_data_M1 = 1'b0; //not sure this is the right place
                    next_state_address = Idle_address;

                end
                //else next_state_address = M1_Address;//not idle
            //end
            //else if(M_ADDR <= slave1_addr2 && M_ADDR >= slave1_addr1)begin
                //select_slave_address = 1'b1;
                else if(M1_ARVALID && S1_ARREADY) begin

                    next_state_slave2 = Slave1_2; 
                    //select_data_M1 = 1'b1; //not sure this is the right place
                    next_state_address = Idle_address; 
                end
                //else next_state_address = M1_Address; //not idle
            //end
            else next_state_address = Idle_address; //wrong address
        end
        default: next_state_address = Idle_address;
    endcase
    //--------------------------------------------------------------------------
    case(curr_state_slave)
        Idle_slave:begin
            //nothing
        end
            
        Slave0:begin
            //check for flag if raised
            //flag for slave 0 is busy
            //if(!S0_busy)begin
              //  S0_busy = 1'b1;
                //select_slave_address = 1'bx; //***************************
                select_data_M0 = 1'b0; //not sure this is the right place
                en_S0 = 1'b0;
                //enable_S0 = 1'b1;

            
            //end
            //else next_state_slave=Slave0;
            if(M0_RREADY || S0_RVALID || S0_RLAST) begin
                next_state_slave = Slave0;
            end
            else if(M0_RREADY && S0_RVALID && S0_RLAST) begin
                next_state_slave = Slave0; 
                //S0_busy = 1'b0;
            end

            else begin 
                next_state_slave = Idle_slave; //problem solved
                //en_S0 = 1'bx;
                //enable_S0 = 1'b0;
            end
        end
        Slave1:begin
            //check for flag if raised
            //flag for slave 1 is busy
            //if(!S1_busy)begin
              //  S1_busy = 1'b1;
                //select_slave_address = 1'bx; //***************************
                select_data_M0 = 1'b1; //not sure this is the right place
                en_S1 = 1'b0;
                //enable_S1 = 1'b1;
                //else next_state_slave = Slave1;
            //end
                
            
            if(M0_RREADY || S1_RVALID || S1_RLAST) begin
                next_state_slave = Slave1;
            end
            else if(M0_RREADY && S1_RVALID && S1_RLAST) begin
                next_state_slave = Slave1; 
                //S0_busy = 1'b0;
            end

            else begin 
                next_state_slave = Idle_slave; //problem solved
                //en_S1 = 1'bx;
                //enable_S1 = 1'b0;
            end
        end
        default: next_state_slave = Idle_slave;

    endcase
    //--------------------------------------------------------------------------
    case (curr_state_slave2)
        Idle_slave_2:begin
            //nothing
        end
        Slave0_2:begin
            //check for flag if raised
            //flag for slave 0 is busy
            //if(!S0_busy)begin
              //  S0_busy = 1'b1;
                //select_slave_address = 1'bx; //***************************
                select_data_M1 = 1'b0; //not sure this is the right place
                en_S0 = 1'b1;
                //enable_S0 = 1'b1;
                //else next_state_slave2 = Slave0_2;
            //end
            if(M1_RREADY || S0_RVALID || S0_RLAST) begin
                next_state_slave2 = Slave0_2; 
            end
            else if(M1_RREADY && S0_RVALID && S0_RLAST) begin
                next_state_slave2 = Slave0_2; 
              //  S0_busy = 1'b0;
                //Ch0_busy = 0;
            end
            else begin 
                next_state_slave2 = Idle_slave_2;
                //enable_S0 = 1'b0;
            end
        end
        Slave1_2:begin
            //check for flag if raised
            //flag for slave 1 is busy
            //if(!S1_busy)begin
              //  S1_busy = 1'b1;
                //select_slave_address = 1'bx; //***************************
                select_data_M1 = 1'b1; //not sure this is the right place
                en_S1 = 1'b1;
                //enable_S1 = 1'b1;
            //    else next_state_slave2 = Slave1_2;
            //end
            if(M1_RREADY || S1_RVALID || S1_RLAST) begin
                next_state_slave2 = Slave1_2; 
            end
            if(M1_RREADY && S1_RVALID && S1_RLAST) begin
                next_state_slave2 = Slave1_2; 
                //S1_busy = 1'b0;
            end
            else begin 
                next_state_slave2 = Idle_slave_2;
                //enable_S1 = 1'b0;
            end
        end
        default: next_state_slave2 = Idle_slave_2;
    endcase
end



/*     //---------------------- Input Ports ----------------------
    input clk, reset,

    //two valid signals from masters on read address channel:
    input wire M0_ARVALID, 
    input wire M1_ARVALID, 
 

    //two read signals from masters on read data channel:
    input wire M0_RREADY,
    input wire M1_RREADY,

    //---------------------- Output Ports ----------------------
    
    // select lines for muxs to choose which master control each channel:
    output reg select_master_address */



/*reg [2:0] curr_state_address, next_state_address;


localparam Idle_address = 2'b00;
localparam M0_Address = 2'b01;
localparam M1_Address = 2'b10;



always @(posedge clk or negedge reset) begin
    if(!reset)begin
        curr_state_address <= Idle_address;

    end
    else begin
    curr_state_address <= next_state_address;

    end
end

always @(*) begin
    case (curr_state_address)
        Idle_address: begin
            if(M0_ARVALID)begin
                next_state_address = M0_Address;
                
                select_master_address = 1'b0;
            end
            else if(M1_ARVALID) begin
                next_state_address = M1_Address;
                
                select_master_address = 1'b1;
            end
            else next_state_address = Idle_address;
        end
        M0_Address:begin
            if(M0_ARVALID && S_ARREADY_M0)begin
                next_state_address = Idle_address;
                
            end

            else begin 
                next_state_address = M0_Address;
                end
        end
        M1_Address: begin
            if(M1_ARVALID && S_ARREADY_M1)begin

                next_state_address = Idle_address;
                
            end

            else begin 
                next_state_address = M1_Address;
       
                end
        end
        
    endcase
  
end*/


endmodule


