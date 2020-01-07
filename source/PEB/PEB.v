//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PEB
// Author : CC zhou
// Contact : 
// Date : 4 .1 .2019
//=======================================================
// Description : Distribute SRAM For 3 PEC
//========================================================
module PEB #(
    parameter PSUM_WIDTH = (`DATA_WIDTH *2 + C_LOG_2(`CHANNEL_DEPTH) + 2 )
    )(
    input                                       clk     ,
    input                                       rst_n   ,
    input                                       CTRPEB_FrtBlk      ,

    input                                       POOLPEB_EnRd,
    input                                       POOLPEB_AddrRd,
    output                                      PEBPOOL_Dat,

    input                                       LSTPEB_FnhRow,
    input                                       LSTPEB_StaRow,
    input                                       LSTPEB_FnhBlk,
    input                                       LSTPEB_FnhFrm,

    input                                       LSTPEB_RdyAct,
    output                                      LSTPEB_GetAct,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]LSTPEB_FlgAct,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]LSTPEB_Act,

    output                                      NXTPEB_RdyAct,
    input                                       NXTPEB_GetAct,
    output[ `CHANNEL_DEPTH             - 1 : 0 ]NXTPEB_FlgAct,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]NXTPEB_Act,    

    input                                       DISWEIPEC_RdyWei0,
    input                                       DISWEIPEC_RdyWei1,
    input                                       DISWEIPEC_RdyWei2,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei00,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei01,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei02,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei03,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei04,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei05,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei06,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei07,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei08,

    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei10,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei11,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei12,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei13,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei14,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei15,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei16,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei17,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei18,

    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei20,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei21,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei22,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei23,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei24,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei25,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei26,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei27,
    input[ `CHANNEL_DEPTH              - 1 : 0 ]DISWEIMAC_FlgWei28,

    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei00,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei01,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei02,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei03,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei04,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei05,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei06,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei07,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei08, 

    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei10,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei11,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei12,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei13,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei14,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei15,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei16,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei17,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei18,
   
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei20,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei21,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei22,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei23,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei24,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei25,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei26,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei27,
    input[ `DATA_WIDTH * `CHANNEL_DEPTH- 1 : 0 ]DISWEIMAC_Wei28

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
        
wire                                        FlgRAM2;              

wire                                        PECRAM_EnWr0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr0;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr0;
wire                                        PECRAM_EnRd0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd0;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd0; 

wire                                        PECRAM_EnWr1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr1;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr1;
wire                                        PECRAM_EnRd1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd1;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd1; 

wire                                        PECRAM_EnWr2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrWr2;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] PECRAM_DatWr2;
wire                                        PECRAM_EnRd2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] PECRAM_AddrRd2;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] RAMPEC_DatRd2; 

wire                                        EnWr0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr0;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr0;
wire                                        EnRd0;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd0;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd0; 

wire                                        EnWr1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr1;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr1;
wire                                        EnRd1;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd1;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd1;

wire                                        EnWr2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr2;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr2;
wire                                        EnRd2;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd2;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd2;

wire                                        EnWr3;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrWr3;
wire [  PSUM_WIDTH * `LENPSUM     - 1 : 0 ] DatWr3;
wire                                        EnRd3;
wire [ `C_LOG_2(`LENPSUM)         - 1 : 0 ] AddrRd3;
wire [ PSUM_WIDTH * `LENPSUM      - 1 : 0 ] DatRd3;

//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        FlgRAM2 <= 1;
    end else if ( PEBPEC_FnhFrm ) begin
        FlgRAM2 <= ~FlgRAM2;
    end
end



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

// Ping   
assign EnWr2         = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_EnWr1      : PECRAM_EnWr2     ) : 0               ;
assign AddrWr2       = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_AddrWr1    : PECRAM_AddrWr2   ) : 0               ;
assign DatWr2        = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_DatWr1     : PECRAM_DatWr2    ) : 0               ;
assign EnRd2         = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_EnRd1      : PECRAM_EnRd2     ) : POOLPEB_EnRd    ;
assign AddrRd2       = FlgRAM2 ? ( CTRPEB_FrtBlk ? PECRAM_AddrRd1    : PECRAM_AddrRd2   ) : POOLPEB_AddrRd  ;
assign RAMPEC_DatRd2 = FlgRAM2 ? ( CTRPEB_FrtBlk ? DatRd1            : DatRd2           ) : PEBPOOL_Dat     ;

// Pong
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
        .PEBPEC_FnhRow     (LSTPEB_FnhRow),
        .PEBPEC_StaRow     (LSTPEB_StaRow),
        .PEBPEC_FnhBlk     (LSTPEB_FnhBlk),
        .PEBPEC_FnhFrm     (LSTPEB_FnhFrm),
        .LSTPEC_RdyAct     (LSTPEB_RdyAct),
        .LSTPEC_GetAct     (LSTPEB_GetAct),
        .PEBPEC_FlgAct     (LSTPEB_FlgAct),
        .PEBPEC_Act        (LSTPEB_Act),
        .NXTPEC_RdyAct     (NXTPEC_RdyAct0),
        .NXTPEC_GetAct     (NXTPEC_GetAct0),
        .DISWEIPEC_RdyWei  (DISWEIPEC_RdyWei0),
        .DISWEIMAC_FlgWei0 (DISWEIMAC_FlgWei00),
        .DISWEIMAC_FlgWei1 (DISWEIMAC_FlgWei01),
        .DISWEIMAC_FlgWei2 (DISWEIMAC_FlgWei02),
        .DISWEIMAC_FlgWei3 (DISWEIMAC_FlgWei03),
        .DISWEIMAC_FlgWei4 (DISWEIMAC_FlgWei04),
        .DISWEIMAC_FlgWei5 (DISWEIMAC_FlgWei05),
        .DISWEIMAC_FlgWei6 (DISWEIMAC_FlgWei06),
        .DISWEIMAC_FlgWei7 (DISWEIMAC_FlgWei07),
        .DISWEIMAC_FlgWei8 (DISWEIMAC_FlgWei08),
        .DISWEIMAC_Wei0    (DISWEIMAC_Wei00),
        .DISWEIMAC_Wei1    (DISWEIMAC_Wei01),
        .DISWEIMAC_Wei2    (DISWEIMAC_Wei02),
        .DISWEIMAC_Wei3    (DISWEIMAC_Wei03),
        .DISWEIMAC_Wei4    (DISWEIMAC_Wei04),
        .DISWEIMAC_Wei5    (DISWEIMAC_Wei05),
        .DISWEIMAC_Wei6    (DISWEIMAC_Wei06),
        .DISWEIMAC_Wei7    (DISWEIMAC_Wei07),
        .DISWEIMAC_Wei8    (DISWEIMAC_Wei08),
        .PECRAM_EnWr       (PECRAM_EnWr0  ),
        .PECRAM_AddrWr     (PECRAM_AddrWr0),
        .PECRAM_DatWr      (PECRAM_DatWr0 ),
        .PECRAM_EnRd       (PECRAM_EnRd0  ),
        .PECRAM_AddrRd     (PECRAM_AddrRd0),
        .RAMPEC_DatRd      (RAMPEC_DatRd0 )
    );

PEC PEC1
    (
        .clk               (clk),
        .rst_n             (rst_n),
        .PEBPEC_FnhRow     (PEBPEC_FnhRow),
        .PEBPEC_StaRow     (PEBPEC_StaRow),
        .PEBPEC_FnhBlk     (PEBPEC_FnhBlk),
        .PEBPEC_FnhFrm     (PEBPEC_FnhFrm),
        .LSTPEC_RdyAct     (NXTPEC_RdyAct0),
        .LSTPEC_GetAct     (NXTPEC_GetAct0),
        .PEBPEC_FlgAct     (PEBPEC_FlgAct),
        .PEBPEC_Act        (PEBPEC_Act),
        .NXTPEC_RdyAct     (NXTPEC_RdyAct1),
        .NXTPEC_GetAct     (NXTPEC_GetAct1),
        .DISWEIPEC_RdyWei  (DISWEIPEC_RdyWei),
        .DISWEIMAC_FlgWei0 (DISWEIMAC_FlgWei10),
        .DISWEIMAC_FlgWei1 (DISWEIMAC_FlgWei11),
        .DISWEIMAC_FlgWei2 (DISWEIMAC_FlgWei12),
        .DISWEIMAC_FlgWei3 (DISWEIMAC_FlgWei13),
        .DISWEIMAC_FlgWei4 (DISWEIMAC_FlgWei14),
        .DISWEIMAC_FlgWei5 (DISWEIMAC_FlgWei15),
        .DISWEIMAC_FlgWei6 (DISWEIMAC_FlgWei16),
        .DISWEIMAC_FlgWei7 (DISWEIMAC_FlgWei17),
        .DISWEIMAC_FlgWei8 (DISWEIMAC_FlgWei18),
        .DISWEIMAC_Wei0    (DISWEIMAC_Wei10),
        .DISWEIMAC_Wei1    (DISWEIMAC_Wei11),
        .DISWEIMAC_Wei2    (DISWEIMAC_Wei12),
        .DISWEIMAC_Wei3    (DISWEIMAC_Wei13),
        .DISWEIMAC_Wei4    (DISWEIMAC_Wei14),
        .DISWEIMAC_Wei5    (DISWEIMAC_Wei15),
        .DISWEIMAC_Wei6    (DISWEIMAC_Wei16),
        .DISWEIMAC_Wei7    (DISWEIMAC_Wei17),
        .DISWEIMAC_Wei8    (DISWEIMAC_Wei18),
        .PECRAM_EnWr       (PECRAM_EnWr1),
        .PECRAM_AddrWr     (PECRAM_AddrWr1),
        .PECRAM_DatWr      (PECRAM_DatWr1),
        .PECRAM_EnRd       (PECRAM_EnRd1),
        .PECRAM_AddrRd     (PECRAM_AddrRd1),
        .RAMPEC_DatRd      (RAMPEC_DatRd1)
    );

PEC PEC2
    (
        .clk               (clk),
        .rst_n             (rst_n),
        .PEBPEC_FnhRow     (PEBPEC_FnhRow),
        .PEBPEC_StaRow     (PEBPEC_StaRow),
        .PEBPEC_FnhBlk     (PEBPEC_FnhBlk),
        .PEBPEC_FnhFrm     (PEBPEC_FnhFrm),
        .LSTPEC_RdyAct     (NXTPEC_RdyAct1),
        .LSTPEC_GetAct     (NXTPEC_GetAct1),
        .PEBPEC_FlgAct     (PEBPEC_FlgAct),
        .PEBPEC_Act        (PEBPEC_Act),
        .NXTPEC_RdyAct     (NXTPEB_RdyAct),
        .NXTPEC_GetAct     (NXTPEB_GetAct),
        .DISWEIPEC_RdyWei  (DISWEIPEC_RdyWei),
        .DISWEIMAC_FlgWei0 (DISWEIMAC_FlgWei20),
        .DISWEIMAC_FlgWei1 (DISWEIMAC_FlgWei21),
        .DISWEIMAC_FlgWei2 (DISWEIMAC_FlgWei22),
        .DISWEIMAC_FlgWei3 (DISWEIMAC_FlgWei23),
        .DISWEIMAC_FlgWei4 (DISWEIMAC_FlgWei24),
        .DISWEIMAC_FlgWei5 (DISWEIMAC_FlgWei25),
        .DISWEIMAC_FlgWei6 (DISWEIMAC_FlgWei26),
        .DISWEIMAC_FlgWei7 (DISWEIMAC_FlgWei27),
        .DISWEIMAC_FlgWei8 (DISWEIMAC_FlgWei28),
        .DISWEIMAC_Wei0    (DISWEIMAC_Wei20),
        .DISWEIMAC_Wei1    (DISWEIMAC_Wei21),
        .DISWEIMAC_Wei2    (DISWEIMAC_Wei22),
        .DISWEIMAC_Wei3    (DISWEIMAC_Wei23),
        .DISWEIMAC_Wei4    (DISWEIMAC_Wei24),
        .DISWEIMAC_Wei5    (DISWEIMAC_Wei25),
        .DISWEIMAC_Wei6    (DISWEIMAC_Wei26),
        .DISWEIMAC_Wei7    (DISWEIMAC_Wei27),
        .DISWEIMAC_Wei8    (DISWEIMAC_Wei28),
        .PECRAM_EnWr       (PECRAM_EnWr2),
        .PECRAM_AddrWr     (PECRAM_AddrWr2),
        .PECRAM_DatWr      (PECRAM_DatWr2),
        .PECRAM_EnRd       (PECRAM_EnRd2),
        .PECRAM_AddrRd     (PECRAM_AddrRd2),
        .RAMPEC_DatRd      (RAMPEC_DatRd2)
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