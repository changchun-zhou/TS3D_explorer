`include "def_params.vh"
module pool2(
    clk, rst_n, 
    GB_OUT_ready, 
    //write data to pooller
    data_in, write_en, fl,
    //read data to pooller
    data_out_ReLU, flag_out, state_RF_OUT,
    ready, read_out_flag);

input clk, rst_n;
input GB_OUT_ready;
input[28 * 14 - 1 : 0] data_in;
input[4  : 0] fl;
input write_en;
input [2 : 0]state_RF_OUT;

output [31 : 0] data_out_ReLU;
output [0 : 6]flag_out;
output ready;
output read_out_flag;

wire clk, rst_n, write_en;
wire[28 * 14 - 1 : 0] data_in;
wire[4  : 0] fl;

reg [7 : 0]RF1[13 : 0];
reg[8 * 7 - 1 : 0] data_out;
reg[0 : 6]flag_out;

reg write_flag;
reg ready;

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// ReLU ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

wire[28:0] ReLU1,ReLU2,ReLU3,ReLU4,ReLU5,ReLU6,ReLU7,ReLU8,ReLU9,ReLU10,ReLU11,ReLU12,ReLU13,ReLU14;

assign ReLU1  =  (data_in[28 * 1  - 1] == 1) ? 28'b0 : data_in[28 *  1 - 1 : 28 *  0];
assign ReLU2  =  (data_in[28 * 2  - 1] == 1) ? 28'b0 : data_in[28 *  2 - 1 : 28 *  1];
assign ReLU3  =  (data_in[28 * 3  - 1] == 1) ? 28'b0 : data_in[28 *  3 - 1 : 28 *  2];
assign ReLU4  =  (data_in[28 * 4  - 1] == 1) ? 28'b0 : data_in[28 *  4 - 1 : 28 *  3];
assign ReLU5  =  (data_in[28 * 5  - 1] == 1) ? 28'b0 : data_in[28 *  5 - 1 : 28 *  4];
assign ReLU6  =  (data_in[28 * 6  - 1] == 1) ? 28'b0 : data_in[28 *  6 - 1 : 28 *  5];
assign ReLU7  =  (data_in[28 * 7  - 1] == 1) ? 28'b0 : data_in[28 *  7 - 1 : 28 *  6];
assign ReLU8  =  (data_in[28 * 8  - 1] == 1) ? 28'b0 : data_in[28 *  8 - 1 : 28 *  7];
assign ReLU9  =  (data_in[28 * 9  - 1] == 1) ? 28'b0 : data_in[28 *  9 - 1 : 28 *  8];
assign ReLU10 =  (data_in[28 * 10 - 1] == 1) ? 28'b0 : data_in[28 * 10 - 1 : 28 *  9];
assign ReLU11 =  (data_in[28 * 11 - 1] == 1) ? 28'b0 : data_in[28 * 11 - 1 : 28 * 10];
assign ReLU12 =  (data_in[28 * 12 - 1] == 1) ? 28'b0 : data_in[28 * 12 - 1 : 28 * 11];
assign ReLU13 =  (data_in[28 * 13 - 1] == 1) ? 28'b0 : data_in[28 * 13 - 1 : 28 * 12];
assign ReLU14 =  (data_in[28 * 14 - 1] == 1) ? 28'b0 : data_in[28 * 14 - 1 : 28 * 13];

///////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// cut ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

wire[7:0] Cut1,Cut2,Cut3,Cut4,Cut5,Cut6,Cut7,Cut8,Cut9,Cut10,Cut11,Cut12,Cut13,Cut14;
wire[4:0] FL;

assign FL = (fl > 5'd21)? 5'd21 : fl;

assign Cut1  =  { 1'b0 , ReLU1[FL + 6 -: 7] };
assign Cut2  =  { 1'b0 , ReLU2[FL + 6 -: 7] };
assign Cut3  =  { 1'b0 , ReLU3[FL + 6 -: 7] };
assign Cut4  =  { 1'b0 , ReLU4[FL + 6 -: 7] };
assign Cut5  =  { 1'b0 , ReLU5[FL + 6 -: 7] };
assign Cut6  =  { 1'b0 , ReLU6[FL + 6 -: 7] };
assign Cut7  =  { 1'b0 , ReLU7[FL + 6 -: 7] };
assign Cut8  =  { 1'b0 , ReLU8[FL + 6 -: 7] };
assign Cut9  =  { 1'b0 , ReLU9[FL + 6 -: 7] };
assign Cut10 =  { 1'b0 , ReLU10[FL + 6 -: 7]};
assign Cut11 =  { 1'b0 , ReLU11[FL + 6 -: 7]};
assign Cut12 =  { 1'b0 , ReLU12[FL + 6 -: 7]};
assign Cut13 =  { 1'b0 , ReLU13[FL + 6 -: 7]};
assign Cut14 =  { 1'b0 , ReLU14[FL + 6 -: 7]};

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        RF1[0]  <= 8'b0;
        RF1[1]  <= 8'b0;
        RF1[2]  <= 8'b0;
        RF1[3]  <= 8'b0;
        RF1[4]  <= 8'b0;
        RF1[5]  <= 8'b0;
        RF1[6]  <= 8'b0;
        RF1[7]  <= 8'b0;
        RF1[8]  <= 8'b0;
        RF1[9]  <= 8'b0;
        RF1[10] <= 8'b0;
        RF1[11] <= 8'b0;
        RF1[12] <= 8'b0;
        RF1[13] <= 8'b0;   
        write_flag <= 1'b1;  
    end
    else if (write_en) begin 
        if (write_flag) begin
            RF1[0]  <= Cut1 ;
            RF1[1]  <= Cut2 ;
            RF1[2]  <= Cut3 ;
            RF1[3]  <= Cut4 ;
            RF1[4]  <= Cut5 ;
            RF1[5]  <= Cut6 ;
            RF1[6]  <= Cut7 ;
            RF1[7]  <= Cut8 ;
            RF1[8]  <= Cut9 ;
            RF1[9]  <= Cut10;
            RF1[10] <= Cut11;
            RF1[11] <= Cut12;
            RF1[12] <= Cut13;
            RF1[13] <= Cut14;
            write_flag <= 1'b0; 
        end
        else begin
            RF1[0]  <= RF1[0] ;
            RF1[1]  <= RF1[1] ;
            RF1[2]  <= RF1[2] ;
            RF1[3]  <= RF1[3] ;
            RF1[4]  <= RF1[4] ;
            RF1[5]  <= RF1[5] ;
            RF1[6]  <= RF1[6] ;
            RF1[7]  <= RF1[7] ;
            RF1[8]  <= RF1[8] ;
            RF1[9]  <= RF1[9] ;
            RF1[10] <= RF1[10];
            RF1[11] <= RF1[11];
            RF1[12] <= RF1[12];
            RF1[13] <= RF1[13];   
            write_flag <= 1'b1;
        end
    end
    else begin
        RF1[0]  <= RF1[0] ;
        RF1[1]  <= RF1[1] ;
        RF1[2]  <= RF1[2] ;
        RF1[3]  <= RF1[3] ;
        RF1[4]  <= RF1[4] ;
        RF1[5]  <= RF1[5] ;
        RF1[6]  <= RF1[6] ;
        RF1[7]  <= RF1[7] ;
        RF1[8]  <= RF1[8] ;
        RF1[9]  <= RF1[9] ;
        RF1[10] <= RF1[10];
        RF1[11] <= RF1[11];
        RF1[12] <= RF1[12];
        RF1[13] <= RF1[13];   
        write_flag <= write_flag;    
    end
end


///////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// compera  ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

wire [7 : 0]compera1[13 : 0];
wire [7 : 0]compera2[6  : 0];

assign compera1[0] =  (RF1[0]  >= Cut14)? RF1[0]  : Cut14;
assign compera1[1] =  (RF1[1]  >= Cut13)? RF1[1]  : Cut13;
assign compera1[2] =  (RF1[2]  >= Cut12)? RF1[2]  : Cut12;
assign compera1[3] =  (RF1[3]  >= Cut11)? RF1[3]  : Cut11;
assign compera1[4] =  (RF1[4]  >= Cut10)? RF1[4]  : Cut10;
assign compera1[5] =  (RF1[5]  >= Cut9 )? RF1[5]  : Cut9 ;
assign compera1[6] =  (RF1[6]  >= Cut8 )? RF1[6]  : Cut8 ;
assign compera1[7] =  (RF1[7]  >= Cut7 )? RF1[7]  : Cut7 ;
assign compera1[8] =  (RF1[8]  >= Cut6 )? RF1[8]  : Cut6 ;
assign compera1[9] =  (RF1[9]  >= Cut5 )? RF1[9]  : Cut5 ;
assign compera1[10] = (RF1[10] >= Cut4 )? RF1[10] : Cut4 ;
assign compera1[11] = (RF1[11] >= Cut3 )? RF1[11] : Cut3 ;
assign compera1[12] = (RF1[12] >= Cut2 )? RF1[12] : Cut2 ;
assign compera1[13] = (RF1[13] >= Cut1 )? RF1[13] : Cut1 ;

assign compera2[0] =  (compera1[0]  >= compera1[1] )? compera1[0] : compera1[1] ;
assign compera2[1] =  (compera1[2]  >= compera1[3] )? compera1[2] : compera1[3] ;
assign compera2[2] =  (compera1[4]  >= compera1[5] )? compera1[4] : compera1[5] ;
assign compera2[3] =  (compera1[6]  >= compera1[7] )? compera1[6] : compera1[7] ;
assign compera2[4] =  (compera1[8]  >= compera1[9] )? compera1[8] : compera1[9] ;
assign compera2[5] =  (compera1[10] >= compera1[11])? compera1[10]: compera1[11];
assign compera2[6] =  (compera1[12] >= compera1[13])? compera1[12]: compera1[13];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out <= 0;
        flag_out <= 0;
        ready    <= 0;
    end
    else begin 
        if ( ~write_flag & write_en) begin
            data_out[8 * 1 - 1 :     0] <= compera2[0];
            data_out[8 * 2 - 1 : 8 * 1] <= compera2[1];
            data_out[8 * 3 - 1 : 8 * 2] <= compera2[2];
            data_out[8 * 4 - 1 : 8 * 3] <= compera2[3];
            data_out[8 * 5 - 1 : 8 * 4] <= compera2[4];
            data_out[8 * 6 - 1 : 8 * 5] <= compera2[5];
            data_out[8 * 7 - 1 : 8 * 6] <= compera2[6];
            flag_out[0] <= (compera2[0] == 0) ? 0 : 1;
            flag_out[1] <= (compera2[1] == 0) ? 0 : 1;
            flag_out[2] <= (compera2[2] == 0) ? 0 : 1;
            flag_out[3] <= (compera2[3] == 0) ? 0 : 1;
            flag_out[4] <= (compera2[4] == 0) ? 0 : 1;
            flag_out[5] <= (compera2[5] == 0) ? 0 : 1;
            flag_out[6] <= (compera2[6] == 0) ? 0 : 1;
            ready <= 1;
        end
        else begin
            data_out <= data_out;    
            ready    <= 0;
        end
    end
end

reg [2 : 0]state_RF_OUT_d;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state_RF_OUT_d <= `IDLE;        
    end
    else begin
        state_RF_OUT_d <= state_RF_OUT;        
    end
end

reg [2 : 0]state_change_dw;
parameter IDLE = 3'b000;
parameter STATE_1 = 3'b001;
parameter STATE_2 = 3'b011;
parameter STATE_3 = 3'b010;
parameter STATE_4 = 3'b110;
parameter STATE_5 = 3'b100;
parameter STATE_6 = 3'b101;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state_change_dw <= IDLE;        
    end
    else if (state_RF_OUT == `OUT_TO_ReLU && state_RF_OUT_d != `OUT_TO_ReLU) begin
        state_change_dw <= IDLE;
    end
    else begin
        case(state_change_dw)
            IDLE   : state_change_dw <= (ready) ? STATE_1 : IDLE;
            STATE_1: state_change_dw <= STATE_2;
            STATE_2: state_change_dw <= STATE_3;
            STATE_3: state_change_dw <= STATE_4;
            STATE_4: 
                if (state_RF_OUT != `OUT_TO_ReLU) begin
                    state_change_dw <= STATE_5;
                end
                else begin
                    state_change_dw <= IDLE;
                end
            STATE_5: state_change_dw <= STATE_6;
            STATE_6: state_change_dw <= IDLE;
        endcase
    end
end

reg [7 : 0]data_out_32[0 : 7];
reg [2 : 0]point_addr;
reg [3 : 0]num_data;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        point_addr <= 0;        
    end
    else if (state_RF_OUT == `OUT_TO_ReLU && state_RF_OUT_d != `OUT_TO_ReLU) begin
        point_addr <= 0;
    end
    else begin
        case(state_change_dw)
            IDLE   : point_addr <= point_addr;
            STATE_1: point_addr <= point_addr + flag_out[0];
            STATE_2: point_addr <= point_addr + flag_out[1] + flag_out[2];
            STATE_3: point_addr <= point_addr + flag_out[3] + flag_out[4];
            STATE_4: point_addr <= point_addr + flag_out[5] + flag_out[6];
            STATE_5: point_addr <= point_addr + 2;
            STATE_6: point_addr <= point_addr + 2;
        endcase
    end
end

reg [31 : 0]data_out_ReLU;
wire read_out_flag;
reg read_out_t;
assign read_out_flag = (read_out_t ^ point_addr[2]);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out_ReLU <= 0;        
    end
    else if (read_out_flag) begin
        if (point_addr[2] == 0) begin
            data_out_ReLU <= {data_out_32[4], data_out_32[5], data_out_32[6], data_out_32[7]};
        end
        else begin
            data_out_ReLU <= {data_out_32[0], data_out_32[1], data_out_32[2], data_out_32[3]}; 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_out_t <= 0;        
    end
    else begin
        read_out_t <= point_addr[2]; 
    end
end





always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out_32[0] <= 0; data_out_32[1] <= 0; data_out_32[2] <= 0; data_out_32[3] <= 0; data_out_32[4] <= 0; data_out_32[5] <= 0; data_out_32[6] <= 0; data_out_32[7] <= 0;        
    end
    else if (state_RF_OUT == `OUT_TO_ReLU && state_RF_OUT_d != `OUT_TO_ReLU) begin
        data_out_32[0] <= 0; data_out_32[1] <= 0; data_out_32[2] <= 0; data_out_32[3] <= 0; data_out_32[4] <= 0; data_out_32[5] <= 0; data_out_32[6] <= 0; data_out_32[7] <= 0;
    end
    else begin
        case(state_change_dw)
            STATE_1: begin
                if (flag_out[0]) begin
                    data_out_32[point_addr] <= data_out[6 * 8 +: 8];
                end
            end
            STATE_2: 
            case({flag_out[1], flag_out[2]})
                2'b01: begin 
                    data_out_32[point_addr] <= data_out[4 * 8 +: 8];
                end
                2'b10: begin 
                    data_out_32[point_addr] <= data_out[5 * 8 +: 8];
                end
                2'b11: begin 
                    data_out_32[point_addr] <= data_out[5 * 8 +: 8];
                    data_out_32[point_addr + 1] <= data_out[4 * 8 +: 8];
                end
            endcase
            STATE_3: 
            case({flag_out[3], flag_out[4]})
                2'b01: begin 
                    data_out_32[point_addr] <= data_out[2 * 8 +: 8];
                end
                2'b10: begin 
                    data_out_32[point_addr] <= data_out[3 * 8 +: 8];
                end
                2'b11: begin 
                    data_out_32[point_addr] <= data_out[3 * 8 +: 8];
                    data_out_32[point_addr + 1] <= data_out[2 * 8 +: 8];
                end
            endcase
            STATE_4:
            case({flag_out[5], flag_out[6]})
                2'b01: begin 
                    data_out_32[point_addr] <= data_out[0 * 8 +: 8];
                end
                2'b10: begin 
                    data_out_32[point_addr] <= data_out[1 * 8 +: 8];
                end
                2'b11: begin 
                    data_out_32[point_addr + 0] <= data_out[1 * 8 +: 8];
                    data_out_32[point_addr + 1] <= data_out[0 * 8 +: 8];
                end
            endcase
            STATE_5:begin
                data_out_32[point_addr + 0] <= 0;
                data_out_32[point_addr + 1] <= 0;
            end 
            STATE_6:begin
                data_out_32[point_addr + 0] <= 0;
                data_out_32[point_addr + 1] <= 0;
            end 
        endcase
    end
end



endmodule

