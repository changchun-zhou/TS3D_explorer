
`define SYNTH_MINI // 2 PEB function
// `define SYNTH_FREQ 
// `define SYNTH_AC

`ifdef SYNTH_AC 
  `define NUMPEB 16 //?
  `define GBFWEI_ADDRWIDTH 10  //?< `BLOCK_DEPTH * `NUMPEC = 32 * 48 = 1536
  `define GBFACT_ADDRWIDTH 2 //?
`elsif SYNTH_FREQ
  `define NUMPEB 16
  `define GBFWEI_ADDRWIDTH 1  //?64 > 16*3
  `define GBFACT_ADDRWIDTH 2 //?
`elsif SYNTH_MINI
  `define NUMPEB 2
  `define GBFWEI_ADDRWIDTH 6  //?64 > 16*3
  `define GBFACT_ADDRWIDTH 10 //?
`endif

`define BLOCK_DEPTH 32
`define CHANNEL_DEPTH 32
`define DATA_WIDTH 8

`define NUMPEC 3*`NUMPEB 

`define KERNEL_SIZE 9
`define GBFWEI_DATAWIDTH `DATA_WIDTH * `KERNEL_SIZE // avoid * 9
`define GBFFLGWEI_DATAWIDTH `BLOCK_DEPTH * `KERNEL_SIZE

// `define GBFFLGACT_ADDRWIDTH 8


`define LENROW 16
`define LENPSUM 14
`define PSUM 

// Config parameters
`define FRAME_WIDTH 5
`define PATCH_WIDTH 8
`define BLK_WIDTH   1024/`BLOCK_DEPTH   //ONLY FOR CONV, FC?
`define LAYER_WIDTH 8 //256 layers


//-----------------------------------------------------------
//Simple Log2 calculation function
//-----------------------------------------------------------
//up compute <=16 =>4
`define C_LOG_2(n) (\
(n) <= (1<<0) ? 0 : (n) <= (1<<1) ? 1 :\
(n) <= (1<<2) ? 2 : (n) <= (1<<3) ? 3 :\
(n) <= (1<<4) ? 4 : (n) <= (1<<5) ? 5 :\
(n) <= (1<<6) ? 6 : (n) <= (1<<7) ? 7 :\
(n) <= (1<<8) ? 8 : (n) <= (1<<9) ? 9 :\
(n) <= (1<<10) ? 10 : (n) <= (1<<11) ? 11 :\
(n) <= (1<<12) ? 12 : (n) <= (1<<13) ? 13 :\
(n) <= (1<<14) ? 14 : (n) <= (1<<15) ? 15 :\
(n) <= (1<<16) ? 16 : (n) <= (1<<17) ? 17 :\
(n) <= (1<<18) ? 18 : (n) <= (1<<19) ? 19 :\
(n) <= (1<<20) ? 20 : (n) <= (1<<21) ? 21 :\
(n) <= (1<<22) ? 22 : (n) <= (1<<23) ? 23 :\
(n) <= (1<<24) ? 24 : (n) <= (1<<25) ? 25 :\
(n) <= (1<<26) ? 26 : (n) <= (1<<27) ? 27 :\
(n) <= (1<<28) ? 28 : (n) <= (1<<29) ? 29 :\
(n) <= (1<<30) ? 30 : (n) <= (1<<31) ? 31 : 32)
//-----------------------------------------------------------