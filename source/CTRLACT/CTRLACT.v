//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : CTRLACT
// Author : CC zhou
// Contact : 
// Date :   6 . 1 .2019
//=======================================================
// Description :
//========================================================
module  CTRLACT #(
    parameter  = 
) (
    input                                       clk     ,
    input                                       rst_n   ,
    input                                       TOP_Sta,
    
    input [ `C_LOG_2(`LENROW)           - 1 : 0 ] CFG_LenRow, // +1 is real value
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_DepBlk,
    input [ `BLK_WIDTH                  - 1 : 0 ] CFG_NumBlk,
    input [ `FRAME_WIDTH                - 1 : 0 ] CFG_NumFrm,
    input [ `PATCH_WIDTH                - 1 : 0 ] CFG_NumPat,
    input [ `LAYER_WIDTH                - 1 : 0 ] CFG_NumLay,
    output                                       CTRLACT_PlsFetch,
    input                                        CTRLACT_GetAct,

    output                                       CTRLACT_FrtActRow,
    output                                       CTRLACT_LstActRow,
    output                                       CTRLACT_LstActBlk,

    // output                                       CTRLACT_FnhPat,
    // output                                       CTRLACT_FnhIfm,
    // output                                       CTRLACT_FnhFrm,


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
localparam IDLE = 3'b000;
localparam CHECKDATA = 3'b001;
localparam CFGACT = 3'b011;
localparam WAITGET = 3'b010;

reg [ 3 - 1 : 0          ] state;
reg [ 3 - 1 : 0          ] next_state;

always @(*) begin
    case (state)
      IDLE    : if ( CTRLACT_PlsFetch )
                    next_state <= CHECKDATA;
                else 
                    next_state <= IDLE;

      CHECKDATA:if( GBFACT_Val && GBFFLGACT_Val && GBFVNACT_Val)
                    next_state <= CFGACT;
                else 
                    next_state <= CHECKDATA;
      CFGACT  : if( NearFnhPacker) //config finish
                    next_state <= WAITGET;
                else 
                    next_state <= CFGACT;
      WAITGET : if( DISACT_GetAct )
                    next_state <= IDLE;
                else 
                    next_state <= WAITGET;

      default: next_state <= IDLE;
    endcase
end


// For loop

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntAct <= 0;
    end else if ( CTRLACT_LstActRow ) begin
        CntAct <= 0;
    end else if( CTRLACT_PlsFetch) begin
        CntAct <= CntAct + 1;
    end
end

// always @ ( posedge clk or negedge rst_n ) begin
//     if ( ~rst_n ) begin
//         CTRLACT_PlsFetch <= 0;
//     end else if ( TOP_Sta || CTRLACT_GetAct ) begin
//          <= ;
//     end
// end

assign CTRLACT_PlsFetch = TOP_Sta || ( CTRLACT_GetAct && );

assign CTRLACT_LstActRow = CntAct == CFG_LenRow;
assign CTRLACT_FrtActRow = CntAct == 0;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntRow <= 0;
    end else if ( CTRLACT_FrtActBlk ) begin
        CntRow <= 0;
    end else if ( CTRLACT_FrtActRow ) begin
        CntRow <= CntRow + 1;
    end
end

assign CTRLACT_FrtActBlk = CntRow == 0 && CTRLACT_FrtActRow;
assign CTRLACT_LstActBlk = CntRow == CFG_LenRow && CTRLACT_FrtActRow;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntBlk <= 0;
    end else if ( CTRLACT_FrtActFrm  ) begin
        CntBlk <= 0;
    end else if ( CTRLACT_FrtActBlk ) begin
        CntBlk <= CntBlk + 1;
    end
end

assign CTRLACT_FrtActFrm = CntBlk == 0 && CTRLACT_FrtActBlk;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntFrm <= 0;
    end else if ( FrtActPat ) begin
        CntFrm <= 0;
    end else if ( FrtActFrm ) begin
        CntFrm <= CntFrm + 1;
    end
end

assign FrtActPat = CntFrm == 0 && CTRLACT_FrtActFrm;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntPat <= 0;
    end else if ( FrtActLay ) begin
        CntPat <= 0; 
    end else if( FrtActPat ) begin
        CntPat <= CntPat + 1;
    end
end

assign FrtActLay = CntPat == 0 && FrtActPat;

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        CntLay <= 0;
    end else if ( Restart ) begin
        CntLay <= 0;
    end else if ( FrtActLay ) begin
        CntLay <= CntLay + 1;
    end
end
// assign FrtActEx =



//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================


endmodule