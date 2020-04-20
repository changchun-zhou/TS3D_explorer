import numpy as np
import random
import os

def PEC( actBlk, PECMAC_Wei, 
         Psum0, PECRAM_DatWr_PEL, RAMPEC_DatRd_PEL, 
         CNVOUT_Psum1File, CNVOUT_Psum2File,
         Len, NumBlk, NumWei, NumChn, NumPEB, NumPEC, cntfrm,cntBlk, cntPEB,cntPEC ):
    # ***************** PEC **********************************************************
    # Input: actBlk PECMAC_Wei Psum0(accum) PECRAM_DatWr_PEL RAMPEC_DatRd_PEL ; File, Len, NumWei,cntBlk, frm, PEB,PEC,

    Psum2 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ] for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
    Psum1 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
    CNVOUT_Psum2_PEL =[['' for x in range ( 0, Len)] for y in range(0,Len)]
    CNVOUT_Psum1_PEL =[['' for x in range ( 0, Len)] for y in range(0,Len)]
    # MACAW
    acc = [ [ [0 for x in range (0,NumWei)] for y in range(0, Len)] for z in range(0, Len)]
    for actrow in range(0, Len) :
        for actcol in range(0, Len):
            for j in range(0, NumWei):
                for m in range (0, NumChn):
                    acc[actrow][actcol][j] = acc[actrow][actcol][j] + actBlk[actrow][actcol][m] * PECMAC_Wei[j][m]
    
    # CONVROW
    CNVOUT_Psum2 = [['' for x in range ( 0, Len)] for y in range(0,Len)]
    CNVOUT_Psum1 = [['' for x in range ( 0, Len)] for y in range(0,Len)]
    CNVOUT_Psum0 = [['' for x in range ( 0, Len)] for y in range(0,Len)]
    #PECRAM_DatWr = [['' for x in range ( 0, Len-2)] for y in range(0,Len-2)]
    for psumrow in range(0, Len):
        for psumcol in range(0, Len-2):

            if cntBlk == 0:
                if cntfrm == 0 or cntPEC == 0:# first frame or PEC0
                    temp_RAMPEC_DatRd = 0;
                elif cntPEC == 2: #PEC2 RAMPEC_DatRd2 = DatRd1 + DatRd2/3
                    temp_RAMPEC_DatRd = Psum0[NumBlk-1][cntPEB][cntPEC-1][psumrow][psumcol] +Psum0[NumBlk-1][cntPEB][cntPEC][psumrow][psumcol] ;
                else:
                    temp_RAMPEC_DatRd = Psum0[NumBlk-1][cntPEB][cntPEC-1][psumrow][psumcol];
            else:# add previous Psum of previous blk# first frame or PEC0
                temp_RAMPEC_DatRd = Psum0[cntBlk-1][cntPEB][cntPEC][psumrow][psumcol];

            if psumrow < Len-2:
                Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] = temp_RAMPEC_DatRd + acc[psumrow][psumcol][0] + acc[psumrow][psumcol+1][1] + acc[psumrow][psumcol+2][2];
            if psumrow >= 1 and psumrow < Len-1: # 1-14
                Psum1[cntBlk][cntPEB][cntPEC][psumrow-1][psumcol]  = 0 + acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5] + Psum2[cntBlk][cntPEB][cntPEC][psumrow -1][psumcol];
            if psumrow >= 2:
                Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol] =  0  + acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8] + Psum1[cntBlk][cntPEB][cntPEC][psumrow -2][psumcol];

                if Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol] < 0:
                     # PSUM_WIDTH = 30b
                     temp_PECRAM_DatWr = hex(Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol] & 0x3fffffff)
                     PECRAM_DatWr_PEL[psumrow-2][psumcol] = PECRAM_DatWr_PEL[psumrow-2][psumcol] + ((str(temp_PECRAM_DatWr).lstrip('0x')).rstrip('L'));
                else:
                    temp_PECRAM_DatWr = hex(Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol]&0x3fffffff )
                    PECRAM_DatWr_PEL[psumrow-2][psumcol] = PECRAM_DatWr_PEL[psumrow-2][psumcol] + ((str(temp_PECRAM_DatWr).lstrip('0x')).rstrip('L')).zfill(8);
            if psumrow < Len-2:
                if temp_RAMPEC_DatRd < 0:
                    temp_RAMPEC_DatRd = hex(temp_RAMPEC_DatRd & 0x3fffffff )
                    RAMPEC_DatRd_PEL[psumrow][psumcol] = RAMPEC_DatRd_PEL[psumrow][psumcol] +((str(temp_RAMPEC_DatRd).lstrip('0x')).rstrip('L'));
                else:
                    temp_RAMPEC_DatRd = hex(temp_RAMPEC_DatRd & 0x3fffffff )
                    RAMPEC_DatRd_PEL[psumrow][psumcol] = RAMPEC_DatRd_PEL[psumrow][psumcol] + ((str(temp_RAMPEC_DatRd).lstrip('0x')).rstrip('L')).zfill(8);
            if Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] < 0:
                temp_CNVOUT_Psum2 = hex(Psum2[cntBlk][cntPEB][cntPEC][psumrow] [psumcol]& 0x3fffffff)
                CNVOUT_Psum2_PEL[psumrow][psumcol] = CNVOUT_Psum2_PEL[psumrow][psumcol] + ((str(temp_CNVOUT_Psum2).lstrip('0x')).rstrip('L'));
            else:
                temp_CNVOUT_Psum2 = hex(Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] & 0x3fffffff)
                CNVOUT_Psum2_PEL[psumrow][psumcol] = CNVOUT_Psum2_PEL[psumrow][psumcol] + ((str(temp_CNVOUT_Psum2).lstrip('0x')).rstrip('L')).zfill(8);
            #if psumrow >=2:
            CNVOUT_Psum2File.write(CNVOUT_Psum2_PEL[psumrow][psumcol]+'\n')
            CNVOUT_Psum2_PEL = [['' for x in range ( 0, Len)] for y in range(0,Len)]
            if psumrow >= 1 and psumrow < Len-1:
                if Psum1[cntBlk][cntPEB][cntPEC][psumrow-1][psumcol] < 0:
                    temp_CNVOUT_Psum1 = hex(Psum1[cntBlk][cntPEB][cntPEC][psumrow-1] [psumcol]& 0x3fffffff)
                    CNVOUT_Psum1_PEL[psumrow][psumcol] = CNVOUT_Psum1_PEL[psumrow][psumcol] + ((str(temp_CNVOUT_Psum2).lstrip('0x')).rstrip('L'));
                else:
                    temp_CNVOUT_Psum1 = hex(Psum1[cntBlk][cntPEB][cntPEC][psumrow-1][psumcol] & 0x3fffffff)
                    CNVOUT_Psum1_PEL[psumrow][psumcol] = CNVOUT_Psum1_PEL[psumrow][psumcol] + ((str(temp_CNVOUT_Psum2).lstrip('0x')).rstrip('L')).zfill(8);
                #if psumrow >=2:
                CNVOUT_Psum1File.write(CNVOUT_Psum1_PEL[psumrow][psumcol]+'\n')
                CNVOUT_Psum1_PEL = [['' for x in range ( 0, Len)] for y in range(0,Len)]
        CNVOUT_Psum1File.write('\n')
    # Output: RAMPEC_DatRd_PEL PECRAM_DatWr_PEL Psum0
    # ****** End PEC ***************************
    return RAMPEC_DatRd_PEL, PECRAM_DatWr_PEL, Psum0