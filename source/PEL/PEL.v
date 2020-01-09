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
module PEL #(
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + `C_LOG_2(`CHANNEL_DEPTH) + 2 )
)(
	input                   										clk     ,
	input                   										rst_n   ,
	input [ `NUMPEB 										-1 : 0] POOLPEB_EnRd,
    input  [ `C_LOG_2(`LENPSUM)                     		-1 : 0] POOLPEB_AddrRd,
    output [ PSUM_WIDTH * `LENPSUM                  		-1 : 0] PEBPOOL_Dat,

    input 															CTRLACT_FrtBlk,
    input 															CTRLACT_FrtActRow,
    input 															CTRLACT_LstActRow,
    input 															CTRLACT_LstActBlk,
    input 															CTRLACT_RdyAct,
    input 															CTRLACT_GetAct,
    input[ `CHANNEL_DEPTH              						-1 : 0] CTRLACT_FlgAct,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH						-1 : 0] CTRLACT_Act,    

    input [ `NUMPEC 										-1 : 0] CTRLWEIPEC_RdyWei,
    output[ `NUMPEC 										-1 : 0] PECCTRLWEI_GetWei,
    input [ `DATA_WIDTH * `BLOCK_DEPTH * `KERNEL_SIZE		-1 : 0] DISWEIPEC_Wei,
    input [ 1 * `BLOCK_DEPTH * `KERNEL_SIZE          		-1 : 0] DISWEIPEC_FlgWei,
    input [ `C_LOG_2( `BLOCK_DEPTH) * `KERNEL_SIZE   		-1 : 0] DISWEIPEC_ValNumWei,

		input [ `C_LOG_2( `BLOCK_DEPTH * `KERNEL_SIZE)   - 1 : 0 ] DISWEI_AddrBase
		);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================





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
		wire 										POOLPEB_EnRd;
		wire 										CTRLWEIPEC_RdyWei0;
		wire 										CTRLWEIPEC_RdyWei1;
		wire 										CTRLWEIPEC_RdyWei2;
		wire 										PECCTRLWEI_GetWei0;
		wire 										PECCTRLWEI_GetWei1;
		wire 										PECCTRLWEI_GetWei2;


		wire 										LSTPEB_FrtActRow;
		wire 										LSTPEB_LstActRow;
		wire 										LSTPEB_LstActBlk;
		wire 										NXTPEB_FrtActRow;
		wire 										NXTPEB_LstActRow;
		wire 										NXTPEB_LstActBlk;	
		wire                                        LSTPEB_RdyAct;
		wire                                        LSTPEB_GetAct;
		wire [ `CHANNEL_DEPTH              - 1 : 0 ]LSTPEB_FlgAct;
		wire [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]LSTPEB_Act;
		wire                                        NXTPEB_RdyAct;
		wire                                        NXTPEB_GetAct;
		wire [ `CHANNEL_DEPTH              - 1 : 0 ]NXTPEB_FlgAct;
		wire [ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]NXTPEB_Act;
		PEB #(
			.PSUM_WIDTH((`DATA_WIDTH *2 + `C_LOG_2(`CHANNEL_DEPTH) + 2 ))
		) inst_PEB (
			.clk                 (clk),
			.rst_n               (rst_n),
			.CTRLPEB_FrtBlk      (LSTPEB_FrtBlk),
			.NXTPEB_FrtBlk 		 (NXTPEB_FrtBlk),
			.POOLPEB_EnRd        (POOLPEB_EnRd),
			.POOLPEB_AddrRd      (POOLPEB_AddrRd),
			.PEBPOOL_Dat         (PEBPOOL_Dat),
			.CTRLWEIPEC_RdyWei0  (CTRLWEIPEC_RdyWei0),
			.CTRLWEIPEC_RdyWei1  (CTRLWEIPEC_RdyWei1),
			.CTRLWEIPEC_RdyWei2  (CTRLWEIPEC_RdyWei2),
			.PECCTRLWEI_GetWei0  (PECCTRLWEI_GetWei0),
			.PECCTRLWEI_GetWei1  (PECCTRLWEI_GetWei1),
			.PECCTRLWEI_GetWei2  (PECCTRLWEI_GetWei2),
			.DISWEIPEC_Wei       (DISWEIPEC_Wei      ),
			.DISWEIPEC_FlgWei    (DISWEIPEC_FlgWei   ),
			.DISWEIPEC_ValNumWei (DISWEIPEC_ValNumWei),
			.DISWEI_AddrBase0    (DISWEI_AddrBase),
			.LSTPEC_FrtActRow0   (LSTPEB_FrtActRow),
			.LSTPEC_LstActRow0   (LSTPEB_LstActRow),
			.LSTPEC_LstActBlk0   (LSTPEB_LstActBlk),
			.NXTPEC_FrtActRow2   (NXTPEB_FrtActRow),
			.NXTPEC_LstActRow2   (NXTPEB_LstActRow),
			.NXTPEC_LstActBlk2   (NXTPEB_LstActBlk),
			.LSTPEB_RdyAct       (LSTPEB_RdyAct),
			.LSTPEB_GetAct       (LSTPEB_GetAct),
			.LSTPEB_FlgAct       (LSTPEB_FlgAct),
			.LSTPEB_Act          (LSTPEB_Act),
			.NXTPEB_RdyAct       (NXTPEB_RdyAct),
			.NXTPEB_GetAct       (NXTPEB_GetAct),
			.NXTPEB_FlgAct       (NXTPEB_FlgAct),
			.NXTPEB_Act          (NXTPEB_Act)
		);
	end
endgenerate

// Attention MSB and LSB related to hardware location 
// Easy to Debug
assign { GENPEB[ 0].POOLPEB_EnRd,GENPEB[ 1].POOLPEB_EnRd,GENPEB[ 2].POOLPEB_EnRd,GENPEB[ 3].POOLPEB_EnRd,
		 GENPEB[ 4].POOLPEB_EnRd,GENPEB[ 5].POOLPEB_EnRd,GENPEB[ 6].POOLPEB_EnRd,GENPEB[ 7].POOLPEB_EnRd,
		 GENPEB[ 8].POOLPEB_EnRd,GENPEB[ 9].POOLPEB_EnRd,GENPEB[10].POOLPEB_EnRd,GENPEB[11].POOLPEB_EnRd,
		 GENPEB[12].POOLPEB_EnRd,GENPEB[13].POOLPEB_EnRd,GENPEB[14].POOLPEB_EnRd,GENPEB[15].POOLPEB_EnRd}
		= POOLPEB_EnRd;
assign { GENPEB[0 ].CTRLWEIPEC_RdyWei0, GENPEB[0 ].CTRLWEIPEC_RdyWei1, GENPEB[0 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[1 ].CTRLWEIPEC_RdyWei0, GENPEB[1 ].CTRLWEIPEC_RdyWei1, GENPEB[1 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[2 ].CTRLWEIPEC_RdyWei0, GENPEB[2 ].CTRLWEIPEC_RdyWei1, GENPEB[2 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[3 ].CTRLWEIPEC_RdyWei0, GENPEB[3 ].CTRLWEIPEC_RdyWei1, GENPEB[3 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[4 ].CTRLWEIPEC_RdyWei0, GENPEB[4 ].CTRLWEIPEC_RdyWei1, GENPEB[4 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[5 ].CTRLWEIPEC_RdyWei0, GENPEB[5 ].CTRLWEIPEC_RdyWei1, GENPEB[5 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[6 ].CTRLWEIPEC_RdyWei0, GENPEB[6 ].CTRLWEIPEC_RdyWei1, GENPEB[6 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[7 ].CTRLWEIPEC_RdyWei0, GENPEB[7 ].CTRLWEIPEC_RdyWei1, GENPEB[7 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[8 ].CTRLWEIPEC_RdyWei0, GENPEB[8 ].CTRLWEIPEC_RdyWei1, GENPEB[8 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[9 ].CTRLWEIPEC_RdyWei0, GENPEB[9 ].CTRLWEIPEC_RdyWei1, GENPEB[9 ].CTRLWEIPEC_RdyWei2, 
		 GENPEB[10].CTRLWEIPEC_RdyWei0, GENPEB[10].CTRLWEIPEC_RdyWei1, GENPEB[10].CTRLWEIPEC_RdyWei2, 
		 GENPEB[11].CTRLWEIPEC_RdyWei0, GENPEB[11].CTRLWEIPEC_RdyWei1, GENPEB[11].CTRLWEIPEC_RdyWei2, 
		 GENPEB[12].CTRLWEIPEC_RdyWei0, GENPEB[12].CTRLWEIPEC_RdyWei1, GENPEB[12].CTRLWEIPEC_RdyWei2, 
		 GENPEB[13].CTRLWEIPEC_RdyWei0, GENPEB[13].CTRLWEIPEC_RdyWei1, GENPEB[13].CTRLWEIPEC_RdyWei2, 
		 GENPEB[14].CTRLWEIPEC_RdyWei0, GENPEB[14].CTRLWEIPEC_RdyWei1, GENPEB[14].CTRLWEIPEC_RdyWei2, 
		 GENPEB[15].CTRLWEIPEC_RdyWei0, GENPEB[15].CTRLWEIPEC_RdyWei1, GENPEB[15].CTRLWEIPEC_RdyWei2 }
		=  CTRLWEIPEC_RdyWei;
assign { GENPEB[0 ].PECCTRLWEI_GetWei0, GENPEB[0 ].PECCTRLWEI_GetWei1, GENPEB[0 ].PECCTRLWEI_GetWei2, 
		 GENPEB[1 ].PECCTRLWEI_GetWei0, GENPEB[1 ].PECCTRLWEI_GetWei1, GENPEB[1 ].PECCTRLWEI_GetWei2, 
		 GENPEB[2 ].PECCTRLWEI_GetWei0, GENPEB[2 ].PECCTRLWEI_GetWei1, GENPEB[2 ].PECCTRLWEI_GetWei2, 
		 GENPEB[3 ].PECCTRLWEI_GetWei0, GENPEB[3 ].PECCTRLWEI_GetWei1, GENPEB[3 ].PECCTRLWEI_GetWei2, 
		 GENPEB[4 ].PECCTRLWEI_GetWei0, GENPEB[4 ].PECCTRLWEI_GetWei1, GENPEB[4 ].PECCTRLWEI_GetWei2, 
		 GENPEB[5 ].PECCTRLWEI_GetWei0, GENPEB[5 ].PECCTRLWEI_GetWei1, GENPEB[5 ].PECCTRLWEI_GetWei2, 
		 GENPEB[6 ].PECCTRLWEI_GetWei0, GENPEB[6 ].PECCTRLWEI_GetWei1, GENPEB[6 ].PECCTRLWEI_GetWei2, 
		 GENPEB[7 ].PECCTRLWEI_GetWei0, GENPEB[7 ].PECCTRLWEI_GetWei1, GENPEB[7 ].PECCTRLWEI_GetWei2, 
		 GENPEB[8 ].PECCTRLWEI_GetWei0, GENPEB[8 ].PECCTRLWEI_GetWei1, GENPEB[8 ].PECCTRLWEI_GetWei2, 
		 GENPEB[9 ].PECCTRLWEI_GetWei0, GENPEB[9 ].PECCTRLWEI_GetWei1, GENPEB[9 ].PECCTRLWEI_GetWei2, 
		 GENPEB[10].PECCTRLWEI_GetWei0, GENPEB[10].PECCTRLWEI_GetWei1, GENPEB[10].PECCTRLWEI_GetWei2, 
		 GENPEB[11].PECCTRLWEI_GetWei0, GENPEB[11].PECCTRLWEI_GetWei1, GENPEB[11].PECCTRLWEI_GetWei2, 
		 GENPEB[12].PECCTRLWEI_GetWei0, GENPEB[12].PECCTRLWEI_GetWei1, GENPEB[12].PECCTRLWEI_GetWei2, 
		 GENPEB[13].PECCTRLWEI_GetWei0, GENPEB[13].PECCTRLWEI_GetWei1, GENPEB[13].PECCTRLWEI_GetWei2, 
		 GENPEB[14].PECCTRLWEI_GetWei0, GENPEB[14].PECCTRLWEI_GetWei1, GENPEB[14].PECCTRLWEI_GetWei2, 
		 GENPEB[15].PECCTRLWEI_GetWei0, GENPEB[15].PECCTRLWEI_GetWei1, GENPEB[15].PECCTRLWEI_GetWei2 }
		=  PECCTRLWEI_GetWei;

assign { GENPEB[ 0].LSTPEB_FrtBlk, GENPEB[ 0].LSTPEB_FrtActRow, GENPEB[ 0].LSTPEB_LstActRow, GENPEB[ 0].LSTPEB_LstActBlk, GENPEB[ 0].LSTPEB_RdyAct, GENPEB[ 0].LSTPEB_GetAct, GENPEB[ 0].LSTPEB_FlgAct, GENPEB[ 0].LSTPEB_Act} = {           CTRLACT_FrtBlk,CTRLACT_FrtActRow,CTRLACT_LstActRow,CTRLACT_LstActBlk,CTRLACT_RdyAct,CTRLACT_GetAct,CTRLACT_FlgAct,CTRLACT_Act};
assign { GENPEB[ 1].LSTPEB_FrtBlk, GENPEB[ 1].LSTPEB_FrtActRow, GENPEB[ 1].LSTPEB_LstActRow, GENPEB[ 1].LSTPEB_LstActBlk, GENPEB[ 1].LSTPEB_RdyAct, GENPEB[ 1].LSTPEB_GetAct, GENPEB[ 1].LSTPEB_FlgAct, GENPEB[ 1].LSTPEB_Act} = {GENPEB[ 0].NXTPEB_FrtBlk, GENPEB[ 0].NXTPEB_FrtActRow, GENPEB[ 0].NXTPEB_LstActRow, GENPEB[ 0].NXTPEB_LstActBlk, GENPEB[ 0].NXTPEB_RdyAct, GENPEB[ 0].NXTPEB_GetAct, GENPEB[ 0].NXTPEB_FlgAct, GENPEB[ 0].NXTPEB_Act };
assign { GENPEB[ 2].LSTPEB_FrtBlk, GENPEB[ 2].LSTPEB_FrtActRow, GENPEB[ 2].LSTPEB_LstActRow, GENPEB[ 2].LSTPEB_LstActBlk, GENPEB[ 2].LSTPEB_RdyAct, GENPEB[ 2].LSTPEB_GetAct, GENPEB[ 2].LSTPEB_FlgAct, GENPEB[ 2].LSTPEB_Act} = {GENPEB[ 1].NXTPEB_FrtBlk, GENPEB[ 1].NXTPEB_FrtActRow, GENPEB[ 1].NXTPEB_LstActRow, GENPEB[ 1].NXTPEB_LstActBlk, GENPEB[ 1].NXTPEB_RdyAct, GENPEB[ 1].NXTPEB_GetAct, GENPEB[ 1].NXTPEB_FlgAct, GENPEB[ 1].NXTPEB_Act };
assign { GENPEB[ 3].LSTPEB_FrtBlk, GENPEB[ 3].LSTPEB_FrtActRow, GENPEB[ 3].LSTPEB_LstActRow, GENPEB[ 3].LSTPEB_LstActBlk, GENPEB[ 3].LSTPEB_RdyAct, GENPEB[ 3].LSTPEB_GetAct, GENPEB[ 3].LSTPEB_FlgAct, GENPEB[ 3].LSTPEB_Act} = {GENPEB[ 2].NXTPEB_FrtBlk, GENPEB[ 2].NXTPEB_FrtActRow, GENPEB[ 2].NXTPEB_LstActRow, GENPEB[ 2].NXTPEB_LstActBlk, GENPEB[ 2].NXTPEB_RdyAct, GENPEB[ 2].NXTPEB_GetAct, GENPEB[ 2].NXTPEB_FlgAct, GENPEB[ 2].NXTPEB_Act };
assign { GENPEB[ 4].LSTPEB_FrtBlk, GENPEB[ 4].LSTPEB_FrtActRow, GENPEB[ 4].LSTPEB_LstActRow, GENPEB[ 4].LSTPEB_LstActBlk, GENPEB[ 4].LSTPEB_RdyAct, GENPEB[ 4].LSTPEB_GetAct, GENPEB[ 4].LSTPEB_FlgAct, GENPEB[ 4].LSTPEB_Act} = {GENPEB[ 3].NXTPEB_FrtBlk, GENPEB[ 3].NXTPEB_FrtActRow, GENPEB[ 3].NXTPEB_LstActRow, GENPEB[ 3].NXTPEB_LstActBlk, GENPEB[ 3].NXTPEB_RdyAct, GENPEB[ 3].NXTPEB_GetAct, GENPEB[ 3].NXTPEB_FlgAct, GENPEB[ 3].NXTPEB_Act };
assign { GENPEB[ 5].LSTPEB_FrtBlk, GENPEB[ 5].LSTPEB_FrtActRow, GENPEB[ 5].LSTPEB_LstActRow, GENPEB[ 5].LSTPEB_LstActBlk, GENPEB[ 5].LSTPEB_RdyAct, GENPEB[ 5].LSTPEB_GetAct, GENPEB[ 5].LSTPEB_FlgAct, GENPEB[ 5].LSTPEB_Act} = {GENPEB[ 4].NXTPEB_FrtBlk, GENPEB[ 4].NXTPEB_FrtActRow, GENPEB[ 4].NXTPEB_LstActRow, GENPEB[ 4].NXTPEB_LstActBlk, GENPEB[ 4].NXTPEB_RdyAct, GENPEB[ 4].NXTPEB_GetAct, GENPEB[ 4].NXTPEB_FlgAct, GENPEB[ 4].NXTPEB_Act };
assign { GENPEB[ 6].LSTPEB_FrtBlk, GENPEB[ 6].LSTPEB_FrtActRow, GENPEB[ 6].LSTPEB_LstActRow, GENPEB[ 6].LSTPEB_LstActBlk, GENPEB[ 6].LSTPEB_RdyAct, GENPEB[ 6].LSTPEB_GetAct, GENPEB[ 6].LSTPEB_FlgAct, GENPEB[ 6].LSTPEB_Act} = {GENPEB[ 5].NXTPEB_FrtBlk, GENPEB[ 5].NXTPEB_FrtActRow, GENPEB[ 5].NXTPEB_LstActRow, GENPEB[ 5].NXTPEB_LstActBlk, GENPEB[ 5].NXTPEB_RdyAct, GENPEB[ 5].NXTPEB_GetAct, GENPEB[ 5].NXTPEB_FlgAct, GENPEB[ 5].NXTPEB_Act };
assign { GENPEB[ 7].LSTPEB_FrtBlk, GENPEB[ 7].LSTPEB_FrtActRow, GENPEB[ 7].LSTPEB_LstActRow, GENPEB[ 7].LSTPEB_LstActBlk, GENPEB[ 7].LSTPEB_RdyAct, GENPEB[ 7].LSTPEB_GetAct, GENPEB[ 7].LSTPEB_FlgAct, GENPEB[ 7].LSTPEB_Act} = {GENPEB[ 6].NXTPEB_FrtBlk, GENPEB[ 6].NXTPEB_FrtActRow, GENPEB[ 6].NXTPEB_LstActRow, GENPEB[ 6].NXTPEB_LstActBlk, GENPEB[ 6].NXTPEB_RdyAct, GENPEB[ 6].NXTPEB_GetAct, GENPEB[ 6].NXTPEB_FlgAct, GENPEB[ 6].NXTPEB_Act };
assign { GENPEB[ 8].LSTPEB_FrtBlk, GENPEB[ 8].LSTPEB_FrtActRow, GENPEB[ 8].LSTPEB_LstActRow, GENPEB[ 8].LSTPEB_LstActBlk, GENPEB[ 8].LSTPEB_RdyAct, GENPEB[ 8].LSTPEB_GetAct, GENPEB[ 8].LSTPEB_FlgAct, GENPEB[ 8].LSTPEB_Act} = {GENPEB[ 7].NXTPEB_FrtBlk, GENPEB[ 7].NXTPEB_FrtActRow, GENPEB[ 7].NXTPEB_LstActRow, GENPEB[ 7].NXTPEB_LstActBlk, GENPEB[ 7].NXTPEB_RdyAct, GENPEB[ 7].NXTPEB_GetAct, GENPEB[ 7].NXTPEB_FlgAct, GENPEB[ 7].NXTPEB_Act };
assign { GENPEB[ 9].LSTPEB_FrtBlk, GENPEB[ 9].LSTPEB_FrtActRow, GENPEB[ 9].LSTPEB_LstActRow, GENPEB[ 9].LSTPEB_LstActBlk, GENPEB[ 9].LSTPEB_RdyAct, GENPEB[ 9].LSTPEB_GetAct, GENPEB[ 9].LSTPEB_FlgAct, GENPEB[ 9].LSTPEB_Act} = {GENPEB[ 8].NXTPEB_FrtBlk, GENPEB[ 8].NXTPEB_FrtActRow, GENPEB[ 8].NXTPEB_LstActRow, GENPEB[ 8].NXTPEB_LstActBlk, GENPEB[ 8].NXTPEB_RdyAct, GENPEB[ 8].NXTPEB_GetAct, GENPEB[ 8].NXTPEB_FlgAct, GENPEB[ 8].NXTPEB_Act };
assign { GENPEB[10].LSTPEB_FrtBlk, GENPEB[10].LSTPEB_FrtActRow, GENPEB[10].LSTPEB_LstActRow, GENPEB[10].LSTPEB_LstActBlk, GENPEB[10].LSTPEB_RdyAct, GENPEB[10].LSTPEB_GetAct, GENPEB[10].LSTPEB_FlgAct, GENPEB[10].LSTPEB_Act} = {GENPEB[ 9].NXTPEB_FrtBlk, GENPEB[ 9].NXTPEB_FrtActRow, GENPEB[ 9].NXTPEB_LstActRow, GENPEB[ 9].NXTPEB_LstActBlk, GENPEB[ 9].NXTPEB_RdyAct, GENPEB[ 9].NXTPEB_GetAct, GENPEB[ 9].NXTPEB_FlgAct, GENPEB[ 9].NXTPEB_Act };
assign { GENPEB[11].LSTPEB_FrtBlk, GENPEB[11].LSTPEB_FrtActRow, GENPEB[11].LSTPEB_LstActRow, GENPEB[11].LSTPEB_LstActBlk, GENPEB[11].LSTPEB_RdyAct, GENPEB[11].LSTPEB_GetAct, GENPEB[11].LSTPEB_FlgAct, GENPEB[11].LSTPEB_Act} = {GENPEB[10].NXTPEB_FrtBlk, GENPEB[10].NXTPEB_FrtActRow, GENPEB[10].NXTPEB_LstActRow, GENPEB[10].NXTPEB_LstActBlk, GENPEB[10].NXTPEB_RdyAct, GENPEB[10].NXTPEB_GetAct, GENPEB[10].NXTPEB_FlgAct, GENPEB[10].NXTPEB_Act };
assign { GENPEB[12].LSTPEB_FrtBlk, GENPEB[12].LSTPEB_FrtActRow, GENPEB[12].LSTPEB_LstActRow, GENPEB[12].LSTPEB_LstActBlk, GENPEB[12].LSTPEB_RdyAct, GENPEB[12].LSTPEB_GetAct, GENPEB[12].LSTPEB_FlgAct, GENPEB[12].LSTPEB_Act} = {GENPEB[11].NXTPEB_FrtBlk, GENPEB[11].NXTPEB_FrtActRow, GENPEB[11].NXTPEB_LstActRow, GENPEB[11].NXTPEB_LstActBlk, GENPEB[11].NXTPEB_RdyAct, GENPEB[11].NXTPEB_GetAct, GENPEB[11].NXTPEB_FlgAct, GENPEB[11].NXTPEB_Act };
assign { GENPEB[13].LSTPEB_FrtBlk, GENPEB[13].LSTPEB_FrtActRow, GENPEB[13].LSTPEB_LstActRow, GENPEB[13].LSTPEB_LstActBlk, GENPEB[13].LSTPEB_RdyAct, GENPEB[13].LSTPEB_GetAct, GENPEB[13].LSTPEB_FlgAct, GENPEB[13].LSTPEB_Act} = {GENPEB[12].NXTPEB_FrtBlk, GENPEB[12].NXTPEB_FrtActRow, GENPEB[12].NXTPEB_LstActRow, GENPEB[12].NXTPEB_LstActBlk, GENPEB[12].NXTPEB_RdyAct, GENPEB[12].NXTPEB_GetAct, GENPEB[12].NXTPEB_FlgAct, GENPEB[12].NXTPEB_Act };
assign { GENPEB[14].LSTPEB_FrtBlk, GENPEB[14].LSTPEB_FrtActRow, GENPEB[14].LSTPEB_LstActRow, GENPEB[14].LSTPEB_LstActBlk, GENPEB[14].LSTPEB_RdyAct, GENPEB[14].LSTPEB_GetAct, GENPEB[14].LSTPEB_FlgAct, GENPEB[14].LSTPEB_Act} = {GENPEB[13].NXTPEB_FrtBlk, GENPEB[13].NXTPEB_FrtActRow, GENPEB[13].NXTPEB_LstActRow, GENPEB[13].NXTPEB_LstActBlk, GENPEB[13].NXTPEB_RdyAct, GENPEB[13].NXTPEB_GetAct, GENPEB[13].NXTPEB_FlgAct, GENPEB[13].NXTPEB_Act };
assign { GENPEB[15].LSTPEB_FrtBlk, GENPEB[15].LSTPEB_FrtActRow, GENPEB[15].LSTPEB_LstActRow, GENPEB[15].LSTPEB_LstActBlk, GENPEB[15].LSTPEB_RdyAct, GENPEB[15].LSTPEB_GetAct, GENPEB[15].LSTPEB_FlgAct, GENPEB[15].LSTPEB_Act} = {GENPEB[14].NXTPEB_FrtBlk, GENPEB[14].NXTPEB_FrtActRow, GENPEB[14].NXTPEB_LstActRow, GENPEB[14].NXTPEB_LstActBlk, GENPEB[14].NXTPEB_RdyAct, GENPEB[14].NXTPEB_GetAct, GENPEB[14].NXTPEB_FlgAct, GENPEB[14].NXTPEB_Act };

				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				

endmodule