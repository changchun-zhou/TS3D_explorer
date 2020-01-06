module FLGOFFSET # (
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 5  )
	(
	input [ DATA_WIDTH	- 1 : 0 ] Act,
	input [ DATA_WIDTH  - 1 : 0 ] Wei,
	input 						  ValFlg,
	output  [ DATA_WIDTH  - 1 : 0 ] OffsetAct,
	output[ DATA_WIDTH  - 1 : 0 ] OffsetWei,
	output reg [ DATA_WIDTH   - 1 : 0 ] SetOut,
	output reg 					  ValOffset

	);
	// reg [ ADDR_WIDTH 	- 1 : 0 ] i;
	wire [ DATA_WIDTH 	- 1 : 0 ] Up;
	wire [ DATA_WIDTH 	- 1 : 0 ] Down;
	wire [ DATA_WIDTH   - 1 : 0 ] Set;

generate
	genvar i;
		for ( i=1; i < DATA_WIDTH -1; i=i+1) begin:Cell
		Cell_FlgAddr Cell_FlgAddr(
			.Act ( Act[i]),
			.Wei ( Wei[i]),
			.UpIn( Up [i-1]),
			.DownIn( Down[i+1]),
			.UpOut( Up[i]),
			.DownOut ( Down[i]),
			.Set ( Set[i])
			);
		end
endgenerate


Cell_FlgAddr Cell_FlgAddr0(
	.Act ( Act[0]),
	.Wei ( Wei[0]),
	.UpIn( 1'b0),
	.DownIn( Down[1]),
	.UpOut( Up[0]),
	.DownOut ( Down[0]),
	.Set ( Set[0])
	);
Cell_FlgAddr Cell_FlgAddr_1(
	.Act ( Act[DATA_WIDTH - 1]),
	.Wei ( Wei[DATA_WIDTH - 1]),
	.UpIn( Up [DATA_WIDTH - 1-1]),
	.DownIn( 1'b1),
	.UpOut( Up[DATA_WIDTH - 1]),
	.DownOut ( Down[DATA_WIDTH - 1]),
	.Set ( Set[DATA_WIDTH - 1])
	);

reg [DATA_WIDTH - 1 : 0 ] ActCut_F;
reg [DATA_WIDTH - 1 : 0 ] WeiCut_F;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        ActCut_F <= 0;
        WeiCut_F <= 0;
        ValOffset <= 0;
        SetOut <= 'b0;
    end else if ( ValFlg ) begin
        ActCut_F <= Act & Set;
        WeiCut_F <= Wei & Set;
        ValOffset<= 1;
        SetOut   <= Set;
    end else begin
    	ValOffset <= 0;
    end
end

// assign ActCut_F = Act & Set;
// assign WeiCut = Wei & Set;
assign  OffsetAct = 
		ActCut_F[0] +
		ActCut_F[1] +
		ActCut_F[2] +
		ActCut_F[3] +
		ActCut_F[4] +
		ActCut_F[5] +
		ActCut_F[6] +
		ActCut_F[7] +
		ActCut_F[8] +
		ActCut_F[9] +
		ActCut_F[10] +
		ActCut_F[11] +
		ActCut_F[12] +
		ActCut_F[13] +
		ActCut_F[14] +
		ActCut_F[15] +
		ActCut_F[16] +
		ActCut_F[17] +
		ActCut_F[18] +
		ActCut_F[19] +
		ActCut_F[20] +
		ActCut_F[21] +
		ActCut_F[22] +
		ActCut_F[23] +
		ActCut_F[24] +
		ActCut_F[25] +
		ActCut_F[26] +
		ActCut_F[27] +
		ActCut_F[28] +
		ActCut_F[29] +
		ActCut_F[30] +
		ActCut_F[31] ;

assign  OffsetWei = 
		WeiCut_F[0] +
		WeiCut_F[1] +
		WeiCut_F[2] +
		WeiCut_F[3] +
		WeiCut_F[4] +
		WeiCut_F[5] +
		WeiCut_F[6] +
		WeiCut_F[7] +
		WeiCut_F[8] +
		WeiCut_F[9] +
		WeiCut_F[10] +
		WeiCut_F[11] +
		WeiCut_F[12] +
		WeiCut_F[13] +
		WeiCut_F[14] +
		WeiCut_F[15] +
		WeiCut_F[16] +
		WeiCut_F[17] +
		WeiCut_F[18] +
		WeiCut_F[19] +
		WeiCut_F[20] +
		WeiCut_F[21] +
		WeiCut_F[22] +
		WeiCut_F[23] +
		WeiCut_F[24] +
		WeiCut_F[25] +
		WeiCut_F[26] +
		WeiCut_F[27] +
		WeiCut_F[28] +
		WeiCut_F[29] +
		WeiCut_F[30] +
		WeiCut_F[31] ;


endmodule

module Cell_FlgAddr(
	input Act,
	input Wei,
	input UpIn,
	input DownIn,
	output UpOut,
	output DownOut,
	output Set
);
	assign UpOut 		= UpIn | ( Act & Wei)		;
	assign Set		= UpIn & DownIn				;
	assign DownOut   	= ~(Act & Wei) & DownIn		;

endmodule

