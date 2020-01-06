//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PEB
// Author : CC zhou
// Contact : 
// Date : 4 .1 .2019
//=======================================================
// Description : Exchange SRAM For 3 PEC
//========================================================
module PEB (
    input                   clk     ,
    input                   rst_n   ,
    input                   CTRPEB_FrtBlk      ,

    input                   POOLPEB_EnRd,
    input                   POOLPEB_AddrRd,
    output                  PEBPOOL_Dat,

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================

wire  FlgRAM2              

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        FlgRAM2 <= 1;
    end else if ( PEBPEC_FnhFrm ) begin
        FlgRAM2 <= ~FlgRAM2;
    end
end


//=====================================================================================================================
// Logic Design :
//=====================================================================================================================




// Fetch LAST SRAM when new frame comes
assign EnWr0         = CTRPEB_FrtBlk ? 0 : PECRAM_EnWr0     ;
assign AddrWr0       = CTRPEB_FrtBlk ? 0 : PECRAM_AddrWr0   ;
assign DatWr0        = CTRPEB_FrtBlk ? 0 : PECRAM_DatWr0    ;
assign EnRd0         = CTRPEB_FrtBlk ? 0 : PECRAM_EnRd0     ;
assign AddrRd0       = CTRPEB_FrtBlk ? 0 : PECRAM_AddrRd0   ;
assign RAMPEC_DatRd0 = CTRPEB_FrtBlk ? 0 : RAMPEC_DatRd0    ;

assign EnWr1         = CTRPEB_FrtBlk ? PECRAM_EnWr0      : PECRAM_EnWr1     ;
assign AddrWr1       = CTRPEB_FrtBlk ? PECRAM_AddrWr0    : PECRAM_AddrWr1   ;
assign DatWr1        = CTRPEB_FrtBlk ? PECRAM_DatWr0     : PECRAM_DatWr1    ;
assign EnRd1         = CTRPEB_FrtBlk ? PECRAM_EnRd0      : PECRAM_EnRd1     ;
assign AddrRd1       = CTRPEB_FrtBlk ? PECRAM_AddrRd0    : PECRAM_AddrRd1   ;
assign RAMPEC_DatRd1 = CTRPEB_FrtBlk ? RAMPEC_DatRd0     : DatRd1           ;

// PingPong   
assign EnWr2         = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_EnWr1      : PECRAM_EnWr2     ) : 0               ;
assign AddrWr2       = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_AddrWr1    : PECRAM_AddrWr2   ) : 0               ;
assign DatWr2        = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_DatWr1     : PECRAM_DatWr2    ) : 0               ;
assign EnRd2         = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_EnRd1      : PECRAM_EnRd2     ) : POOLPEB_EnRd    ;
assign AddrRd2       = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_AddrRd1    : PECRAM_AddrRd2   ) : POOLPEB_AddrRd  ;
assign RAMPEC_DatRd2 = FlgRAM2 ? ( CTRPEB_FrtBlk ? DatRd1            : DatRd2           ) : PEBPOOL_Dat     ;

assign EnWr3         =~FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_EnWr1      : PECRAM_EnWr2     ) : 0               ;
assign AddrWr3       =~FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_AddrWr1    : PECRAM_AddrWr2   ) : 0               ;
assign DatWr3        =~FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_DatWr1     : PECRAM_DatWr2    ) : 0               ;
assign EnRd3         =~FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_EnRd1      : PECRAM_EnRd2     ) : POOLPEB_EnRd    ;
assign AddrRd3       =~FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_AddrRd1    : PECRAM_AddrRd2   ) : POOLPEB_AddrRd  ;
assign RAMPEC_DatRd3 =~FlgRAM2 ? ( CTRPEB_FrtBlk ? DatRd1            : DatRd2           ) : PEBPOOL_Dat     ;


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

PEC PEC0
    (
        .clk               (clk),
        .rst_n             (rst_n),
        .PEBPEC_FnhRow     (PEBPEC_FnhRow),
        .PEBPEC_StaRow     (PEBPEC_StaRow),
        .PEBPEC_FnhBlk     (PEBPEC_FnhBlk),
        .PEBPEC_FnhFrm     (PEBPEC_FnhFrm),
        .LSTPEC_RdyAct     (LSTPEC_RdyAct),
        .LSTPEC_GetAct     (LSTPEC_GetAct),
        .PEBPEC_FlgAct     (PEBPEC_FlgAct),
        .PEBPEC_Act        (PEBPEC_Act),
        .NXTPEC_RdyAct     (NXTPEC_RdyAct),
        .NXTPEC_GetAct     (NXTPEC_GetAct),
        .DISWEIPEC_RdyWei  (DISWEIPEC_RdyWei),
        .DISWEIMAC_FlgWei0 (DISWEIMAC_FlgWei0),
        .DISWEIMAC_FlgWei1 (DISWEIMAC_FlgWei1),
        .DISWEIMAC_FlgWei2 (DISWEIMAC_FlgWei2),
        .DISWEIMAC_FlgWei3 (DISWEIMAC_FlgWei3),
        .DISWEIMAC_FlgWei4 (DISWEIMAC_FlgWei4),
        .DISWEIMAC_FlgWei5 (DISWEIMAC_FlgWei5),
        .DISWEIMAC_FlgWei6 (DISWEIMAC_FlgWei6),
        .DISWEIMAC_FlgWei7 (DISWEIMAC_FlgWei7),
        .DISWEIMAC_FlgWei8 (DISWEIMAC_FlgWei8),
        .DISWEIMAC_Wei0    (DISWEIMAC_Wei0),
        .DISWEIMAC_Wei1    (DISWEIMAC_Wei1),
        .DISWEIMAC_Wei2    (DISWEIMAC_Wei2),
        .DISWEIMAC_Wei3    (DISWEIMAC_Wei3),
        .DISWEIMAC_Wei4    (DISWEIMAC_Wei4),
        .DISWEIMAC_Wei5    (DISWEIMAC_Wei5),
        .DISWEIMAC_Wei6    (DISWEIMAC_Wei6),
        .DISWEIMAC_Wei7    (DISWEIMAC_Wei7),
        .DISWEIMAC_Wei8    (DISWEIMAC_Wei8),
        .PECRAM_EnWr       (PECRAM_EnWr0),
        .PECRAM_AddrWr     (PECRAM_AddrWr0),
        .PECRAM_DatWr      (PECRAM_DatWr0),
        .PECRAM_EnRd       (PECRAM_EnRd0),
        .PECRAM_AddrRd     (PECRAM_AddrRd0),
        .RAMPEC_DatRd      (RAMPEC_DatRd0)
    );









SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH)
    ) RAM_PEC0 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd0     ),
        .addr_w   ( AddrWr0     ),
        .read_en  ( EnRd0       ),
        .write_en ( EnWr0       ),
        .data_in  ( DatWr0      ),
        .data_out ( DatRd0      )
    );
SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH)
    ) RAM_PEC1 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd1     ),
        .addr_w   ( AddrWr1     ),
        .read_en  ( EnRd1       ),
        .write_en ( EnWr1       ),
        .data_in  ( DatWr1      ),
        .data_out ( DatRd1      )
    );
SRAM_DUAL #(
         .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH) 
    ) RAM_PEC2 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd2     ),
        .addr_w   ( AddrWr2     ),
        .read_en  ( EnRd2       ),
        .write_en ( EnWr2       ),
        .data_in  ( DatWr2      ),
        .data_out ( DatRd2      )
    );

SRAM_DUAL #(
        .SRAM_DEPTH_BIT(`C_LOG_2(`LENPSUM)),   
        .SRAM_WIDTH(PSUM_WIDTH)
    ) RAM_PEC3 (
        .clk      ( clk         ),
        .addr_r   ( AddrRd3     ),
        .addr_w   ( AddrWr3     ),
        .read_en  ( EnRd3       ),
        .write_en ( EnWr3       ),
        .data_in  ( DatWr3      ),
        .data_out ( DatRd3      )
    );

endmodule