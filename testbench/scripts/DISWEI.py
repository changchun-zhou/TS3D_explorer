import numpy as np
import random
import os

def DISWEI( cntPat,  
            cnt_Flagwei_hex, PECMAC_FlgWei_wr, ColWei, cnt_GBFWEI, cnt_GBFFLGWEI,cntPat_last_GBFWEI,cntPat_last_GBFFLGWEI,PECMAC_Wei_wr,DDR_ADDR,
            FlagWeiFile, WeiFile, GBFWEI_DatWrFile, GBFWEI_FrtGrpAddrFile, GBFFLGWEI_FrtGrpAddrFile,
            NumWei,NumChn ):
    PECMAC_Wei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
    PECMAC_FlgWei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
    for j in range (0, NumWei) :
        #PECMAC_FlgWei[NumWei - 1-j] = FlagWeiFile.read(NumChn)
        #FlagWeiFile.read(1)

        if cnt_Flagwei_hex == 0:
            FlgWei_hex = FlagWeiFile.readline().rstrip('\n') # 12B
            cnt_GBFFLGWEI = cnt_GBFFLGWEI + 1
            if cntPat != cntPat_last_GBFFLGWEI: # complete the current line
                print("GBFFLGWEI_DatWr next patch line:", cnt_GBFFLGWEI-1 ) # Addr ( 0 begin)
                GBFFLGWEI_FrtGrpAddrFile.write( str(hex(cnt_GBFFLGWEI -1)).lstrip('0x').rstrip('L').zfill(8) +'\n')
                DDR_ADDR[0][cntPat] = (cnt_GBFFLGWEI-1)*12 #begin addr
            cntPat_last_GBFFLGWEI = cntPat
         
        PECMAC_FlgWei_item_hex = FlgWei_hex[8*cnt_Flagwei_hex:8*cnt_Flagwei_hex+8] #4B
        PECMAC_FlgWei_item = int(PECMAC_FlgWei_item_hex,16)
        PECMAC_FlgWei_item = str(bin(PECMAC_FlgWei_item)).lstrip('0b').zfill(NumChn)
        if cnt_Flagwei_hex == 2:
            cnt_Flagwei_hex = 0
        else:
            cnt_Flagwei_hex += 1
        PECMAC_FlgWei[j] = PECMAC_FlgWei_item # FlgWei0 FlgWei1

        PECMAC_FlgWei_wr = PECMAC_FlgWei_wr + PECMAC_FlgWei_item_hex

    for j in range (0, NumWei) :
        PECMAC_Wei_1 = ''
        for k in range (0, NumChn):
            if PECMAC_FlgWei[j][k] == '1':

                if ColWei == 12 :
                    WeiFile.read(1)
                    ColWei = 1
                else :
                    ColWei = ColWei + 1 #cnt
                wei = WeiFile.read(2)

                # ***********************************************
                cnt_GBFWEI += 1 # mean: the count of File
                if cnt_GBFWEI % 12 == 1 and cnt_GBFWEI != 1: # when turn line
                    GBFWEI_DatWrFile.write('\n')
                elif cntPat != cntPat_last_GBFWEI and cntPat_last_GBFWEI != -1: # complete the current line
                    
                    if cnt_GBFWEI % 12 == 0:
                        Zero = "xx"*( 1) 
                        cnt_GBFWEI += 1
                    else:
                        Zero = "xx"*( 13 - cnt_GBFWEI % 12) 
                        cnt_GBFWEI +=  13 - cnt_GBFWEI % 12
                    GBFWEI_DatWrFile.write(Zero+'\n')# turn to next line
                if cntPat != cntPat_last_GBFWEI: # complete the current line
                    print("GBFWEI_DatWr next patch line:", cnt_GBFWEI/12) # Addr ( 0 begin)
                    GBFWEI_FrtGrpAddrFile.write( str(hex(cnt_GBFWEI/12)).lstrip('0x').rstrip('L').zfill(8) +'\n')
                    DDR_ADDR[1][cntPat] = cnt_GBFWEI - 1 #begin addr

                GBFWEI_DatWrFile.write(wei) 
                cntPat_last_GBFWEI = cntPat # When new patch's first data, update patch
                # ************************************************

                #cnt_wei += 1

                #if cntPEB==0 and cntPEC ==0 and j == NumWei - 1:
                PECMAC_Wei_1 = PECMAC_Wei_1 + wei
                #print("j k wei:",j,k,wei)
            elif PECMAC_FlgWei[j][k] == '0':
                wei = "00"
                #if cntPEB==0 and cntPEC ==0 and j == NumWei - 1:
                PECMAC_Wei_1 = '00' + PECMAC_Wei_1
            else:
                print('PECMAC_FlgWei['+ (j) +']'+ 'Error')
            wei = int(wei, 16)
            if wei > 127:
                wei = wei - 256
            PECMAC_Wei[j][k] = wei
        PECMAC_Wei_wr = PECMAC_Wei_wr + PECMAC_Wei_1

    return PECMAC_Wei, cnt_Flagwei_hex, PECMAC_FlgWei_wr, ColWei, cnt_GBFWEI, cnt_GBFFLGWEI, cntPat_last_GBFWEI,cntPat_last_GBFFLGWEI,PECMAC_Wei_wr,DDR_ADDR,