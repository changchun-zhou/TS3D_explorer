`include "../source/include/dw_params_presim.vh"
module FLGOFFSET # (
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 5  )
	(
	input 												clk,
	input  												rst_n,
	input 												PECMAC_Sta,
	input [ DATA_WIDTH	- 1 : 0 ] PECMAC_FlgAct,
	input [ DATA_WIDTH  - 1 : 0 ] PECMAC_FlgWei,
	output  [ ADDR_WIDTH    : 0 ] OffsetAct,
	output[ ADDR_WIDTH      : 0 ] OffsetWei
	);

// change to ch31 ch30 ... ch0 to compute 
//           ACT: ...ch0 ch1...ch31
reg [`BLOCK_DEPTH                - 1 :0] FlgAct_r; // exchange MSB AND LSB
reg [ `BLOCK_DEPTH                - 1:0] FlgWei_r;
wire [ DATA_WIDTH  - 1 : 0 ] PECMAC_FlgWei_r;
wire [ DATA_WIDTH  - 1 : 0 ] PECMAC_FlgAct_r;
generate
	genvar y;
	for(y=0;y<`BLOCK_DEPTH;y=y+1)begin:Flgbit
		assign PECMAC_FlgAct_r[y] = PECMAC_FlgAct[`BLOCK_DEPTH-1-y];
		assign PECMAC_FlgWei_r[y] = PECMAC_FlgWei[`BLOCK_DEPTH-1-y];
	end
endgenerate


wire [ DATA_WIDTH 	- 1 : 0 ] Up;
wire [ DATA_WIDTH 	- 1 : 0 ] Down;
wire [ DATA_WIDTH   - 1 : 0 ] Set;

reg [DATA_WIDTH - 1 : 0 ] FlgCutAct;
reg [DATA_WIDTH - 1 : 0 ] FlgCutWei;

always @ ( posedge clk or negedge rst_n ) begin
		if ( ~rst_n ) begin
				FlgAct_r <= 0;
				FlgWei_r <= 0;
		end else if ( PECMAC_Sta ) begin
				FlgAct_r <= PECMAC_FlgAct_r; //
				FlgWei_r <= PECMAC_FlgWei_r;
		end else begin
				FlgAct_r <= FlgAct_r & ~Set; // drop out after 1; not need cache 1 clk which halves speed
				FlgWei_r <= FlgWei_r & ~Set;
		end
end
always @ ( posedge clk or negedge rst_n ) begin
		if ( ~rst_n ) begin
				FlgCutAct <= 0;
				FlgCutWei <= 0;
		end else  begin
				FlgCutAct <= FlgAct_r & Set;
				FlgCutWei <= FlgWei_r & Set;
		end
end

assign  OffsetAct =
		FlgCutAct[0] +
		FlgCutAct[1] +
		FlgCutAct[2] +
		FlgCutAct[3] +
		FlgCutAct[4] +
		FlgCutAct[5] +
		FlgCutAct[6] +
		FlgCutAct[7] +
		FlgCutAct[8] +
		FlgCutAct[9] +
		FlgCutAct[10] +
		FlgCutAct[11] +
		FlgCutAct[12] +
		FlgCutAct[13] +
		FlgCutAct[14] +
		FlgCutAct[15] +
		FlgCutAct[16] +
		FlgCutAct[17] +
		FlgCutAct[18] +
		FlgCutAct[19] +
		FlgCutAct[20] +
		FlgCutAct[21] +
		FlgCutAct[22] +
		FlgCutAct[23] +
		FlgCutAct[24] +
		FlgCutAct[25] +
		FlgCutAct[26] +
		FlgCutAct[27] +
		FlgCutAct[28] +
		FlgCutAct[29] +
		FlgCutAct[30] +
		FlgCutAct[31] ;

assign  OffsetWei =
		FlgCutWei[0] +
		FlgCutWei[1] +
		FlgCutWei[2] +
		FlgCutWei[3] +
		FlgCutWei[4] +
		FlgCutWei[5] +
		FlgCutWei[6] +
		FlgCutWei[7] +
		FlgCutWei[8] +
		FlgCutWei[9] +
		FlgCutWei[10] +
		FlgCutWei[11] +
		FlgCutWei[12] +
		FlgCutWei[13] +
		FlgCutWei[14] +
		FlgCutWei[15] +
		FlgCutWei[16] +
		FlgCutWei[17] +
		FlgCutWei[18] +
		FlgCutWei[19] +
		FlgCutWei[20] +
		FlgCutWei[21] +
		FlgCutWei[22] +
		FlgCutWei[23] +
		FlgCutWei[24] +
		FlgCutWei[25] +
		FlgCutWei[26] +
		FlgCutWei[27] +
		FlgCutWei[28] +
		FlgCutWei[29] +
		FlgCutWei[30] +
		FlgCutWei[31] ;

generate
	genvar i;
		for ( i=1; i < DATA_WIDTH -1; i=i+1) begin:Cell
		Cell_FlgAddr Cell_FlgAddr(
			.FlgAct_r ( FlgAct_r[i]),
			.FlgWei_r ( FlgWei_r[i]),
			.UpIn( Up [i-1]),
			.DownIn( Down[i+1]),
			.UpOut( Up[i]),
			.DownOut ( Down[i]),
			.Set ( Set[i])
			);
		end
endgenerate


Cell_FlgAddr Cell_FlgAddr0(
	.FlgAct_r ( FlgAct_r[0]),
	.FlgWei_r ( FlgWei_r[0]),
	.UpIn( 1'b0),
	.DownIn( Down[1]),
	.UpOut( Up[0]),
	.DownOut ( Down[0]),
	.Set ( Set[0])
	);
Cell_FlgAddr Cell_FlgAddr_1(
	.FlgAct_r ( FlgAct_r[DATA_WIDTH - 1]),
	.FlgWei_r ( FlgWei_r[DATA_WIDTH - 1]),
	.UpIn( Up [DATA_WIDTH - 1-1]),
	.DownIn( 1'b1),
	.UpOut( Up[DATA_WIDTH - 1]),
	.DownOut ( Down[DATA_WIDTH - 1]),
	.Set ( Set[DATA_WIDTH - 1])
	);




endmodule

module Cell_FlgAddr(
	input FlgAct_r,
	input FlgWei_r,
	input UpIn,
	input DownIn,
	output UpOut,
	output DownOut,
	output Set
);
	assign UpOut 		= UpIn | ( FlgAct_r & FlgWei_r)		;
	assign Set		= UpOut & DownIn				;
	assign DownOut   	= ~(FlgAct_r & FlgWei_r) & DownIn		;

endmodule

