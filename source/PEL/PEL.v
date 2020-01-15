//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PEL
// Author : CC zhou
// Contact : 
// Date : 6 .1 .2019
//=======================================================
// Description :
//========================================================
`include "../include/dw_params_presim.vh"
module PEL #(
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`BLOCK_DEPTH) + 2 )
)(
	input                   										clk     ,
	input                   										rst_n   ,
	input [ `C_LOG_2( `NUMPEB ) 							-1 : 0] POOLPEB_EnRd,
    input  [ `C_LOG_2(`LENPSUM)                     		-1 : 0] POOLPEB_AddrRd,
    output [ PSUM_WIDTH * `LENPSUM                  		-1 : 0] PELPOOL_Dat,
    input 															CTRLACT_FrtBlk,
    input 															CTRLACT_FrtActRow,
    input 															CTRLACT_LstActRow,
    input 															CTRLACT_LstActBlk,
    input 														    CTRLACT_ValPsum,
    input 															CTRLPEB_FnhFrm,
    input 															CTRLACT_RdyAct,
    output 															CTRLACT_GetAct,
    input[ `BLOCK_DEPTH              						-1 : 0] CTRLACT_FlgAct,
    input[ `DATA_WIDTH * `BLOCK_DEPTH						-1 : 0] CTRLACT_Act,    
    input [ `NUMPEC 										-1 : 0] CTRLWEIPEC_RdyWei,
    output[ `NUMPEC 										-1 : 0] PECCTRLWEI_GetWei,
    input [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE		-1 : 0] DISWEIPEC_Wei,
    input [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE          		-1 : 0] DISWEIPEC_FlgWei
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire [ PSUM_WIDTH * `LENPSUM                  		-1 : 0] PEBPOOL_Dat[ 0 : `NUMPEB - 1];




//=====================================================================================================================
// Logic Design :
//=====================================================================================================================






//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
generate
	genvar i;
	for( i=0; i<`NUMPEB; i=i+1) begin:GENPEB
		wire 										LSTPEB_FrtBlk;
		wire 										NXTPEB_FrtBlk;
		// wire 										POOLPEB_EnRd;
		// wire [ PSUM_WIDTH * `LENPSUM         -1 : 0] PEBPOOL_Dat;
		wire 										CTRLWEIPEC_RdyWei0;
		wire 										CTRLWEIPEC_RdyWei1;
		wire 										CTRLWEIPEC_RdyWei2;
		wire 										PECCTRLWEI_GetWei0;
		wire 										PECCTRLWEI_GetWei1;
		wire 										PECCTRLWEI_GetWei2;
		wire 										LSTPEB_FrtActRow;
		wire 										LSTPEB_LstActRow;
		wire 										LSTPEB_LstActBlk;
		wire 										LSTPEB_ValPsum;
		wire 										NXTPEB_FrtActRow;
		wire 										NXTPEB_LstActRow;
		wire 										NXTPEB_LstActBlk;	
		wire 										NXTPEB_ValPsum;
		wire                                        LSTPEB_RdyAct;
		wire                                        LSTPEB_GetAct;
		wire [ `BLOCK_DEPTH              	-1 : 0] LSTPEB_FlgAct;
		wire [ `DATA_WIDTH * `BLOCK_DEPTH	-1 : 0] LSTPEB_Act;
		wire                                        NXTPEB_RdyAct;
		wire                                        NXTPEB_GetAct;
		wire [ `BLOCK_DEPTH              	-1 : 0] NXTPEB_FlgAct;
		wire [ `DATA_WIDTH * `BLOCK_DEPTH	-1 : 0] NXTPEB_Act;
		PEB #(
			.PSUM_WIDTH((`DATA_WIDTH *2 + `C_LOG_2(`BLOCK_DEPTH) + 2 ))
		) inst_PEB (
			.clk                 (clk),
			.rst_n               (rst_n),
			.CTRLPEB_FrtBlk      (LSTPEB_FrtBlk),
			.CTRLPEB_FnhFrm      (CTRLPEB_FnhFrm),
			.NXTPEB_FrtBlk 		 (NXTPEB_FrtBlk),
			.POOLPEB_EnRd        (POOLPEB_EnRd == i),
			.POOLPEB_AddrRd      (POOLPEB_AddrRd),
			.PEBPOOL_Dat         (PEBPOOL_Dat[i]),
			.CTRLWEIPEC_RdyWei0  (CTRLWEIPEC_RdyWei0),
			.CTRLWEIPEC_RdyWei1  (CTRLWEIPEC_RdyWei1),
			.CTRLWEIPEC_RdyWei2  (CTRLWEIPEC_RdyWei2),
			.PECCTRLWEI_GetWei0  (PECCTRLWEI_GetWei0),
			.PECCTRLWEI_GetWei1  (PECCTRLWEI_GetWei1),
			.PECCTRLWEI_GetWei2  (PECCTRLWEI_GetWei2),
			.DISWEIPEC_Wei       (DISWEIPEC_Wei      ),
			.DISWEIPEC_FlgWei    (DISWEIPEC_FlgWei   ),
			.LSTPEC_FrtActRow0   (LSTPEB_FrtActRow),
			.LSTPEC_LstActRow0   (LSTPEB_LstActRow),
			.LSTPEC_LstActBlk0   (LSTPEB_LstActBlk),
			.LSTPEC_ValPsum0      (LSTPEB_ValPsum ),
			.NXTPEC_FrtActRow2   (NXTPEB_FrtActRow),
			.NXTPEC_LstActRow2   (NXTPEB_LstActRow),
			.NXTPEC_LstActBlk2   (NXTPEB_LstActBlk),
			.NXTPEC_ValPsum2      (NXTPEB_ValPsum),
			.LSTPEB_RdyAct       (LSTPEB_RdyAct),
			.LSTPEB_GetAct       (LSTPEB_GetAct),
			.LSTPEB_FlgAct       (LSTPEB_FlgAct),
			.LSTPEB_Act          (LSTPEB_Act),
			.NXTPEB_RdyAct       (NXTPEB_RdyAct),
			.NXTPEB_GetAct       (NXTPEB_GetAct),
			.NXTPEB_FlgAct       (NXTPEB_FlgAct),
			.NXTPEB_Act          (NXTPEB_Act)
		);
		assign {CTRLWEIPEC_RdyWei0, CTRLWEIPEC_RdyWei1, CTRLWEIPEC_RdyWei2} = CTRLWEIPEC_RdyWei[3*(`NUMPEB - i -1) +: 3];
		assign PECCTRLWEI_GetWei[3*(`NUMPEB - i -1) +: 3] = {PECCTRLWEI_GetWei0, PECCTRLWEI_GetWei1, PECCTRLWEI_GetWei2};
	end
endgenerate

assign PELPOOL_Dat = PEBPOOL_Dat[POOLPEB_EnRd];

// Attention MSB and LSB related to hardware location 
// Easy to Debug
generate
	genvar j;
	for(j=1; j<`NUMPEB; j=j+1) begin: GENTRANS
	assign { GENPEB[ j].LSTPEB_FrtBlk, GENPEB[ j].LSTPEB_FrtActRow, GENPEB[ j].LSTPEB_LstActRow, GENPEB[ j].LSTPEB_LstActBlk, GENPEB[j].LSTPEB_ValPsum, GENPEB[ j].LSTPEB_RdyAct, GENPEB[j-1].NXTPEB_GetAct, GENPEB[ j].LSTPEB_FlgAct, GENPEB[ j].LSTPEB_Act} 
		 = {GENPEB[ j-1].NXTPEB_FrtBlk, GENPEB[ j-1].NXTPEB_FrtActRow, GENPEB[ j-1].NXTPEB_LstActRow, GENPEB[ j-1].NXTPEB_LstActBlk, GENPEB[j-1].NXTPEB_ValPsum, GENPEB[j-1].NXTPEB_RdyAct, GENPEB[ j].LSTPEB_GetAct, GENPEB[ j-1].NXTPEB_FlgAct, GENPEB[ j-1].NXTPEB_Act };
	end
endgenerate
assign GENPEB[`NUMPEB - 1].NXTPEB_GetAct = 1;//THE last PEB
assign { GENPEB[ 0].LSTPEB_FrtBlk, GENPEB[ 0].LSTPEB_FrtActRow, GENPEB[ 0].LSTPEB_LstActRow, GENPEB[ 0].LSTPEB_LstActBlk, GENPEB[0].LSTPEB_ValPsum,GENPEB[ 0].LSTPEB_RdyAct, CTRLACT_GetAct, GENPEB[ 0].LSTPEB_FlgAct, GENPEB[ 0].LSTPEB_Act} = {           CTRLACT_FrtBlk,CTRLACT_FrtActRow,CTRLACT_LstActRow,CTRLACT_LstActBlk, CTRLACT_ValPsum, CTRLACT_RdyAct,GENPEB[ 0].LSTPEB_GetAct,CTRLACT_FlgAct,CTRLACT_Act};

			
endmodule