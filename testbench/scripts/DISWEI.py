import numpy as np
import random
import os

def DISWEI( cntPat,  
            cnt_Flagwei_hex, PECMAC_FlgWei_wr, ColWei, cnt_GBFWEI, cntPat_last_GBFWEI,PECMAC_Wei_wr,
            FlagWeiFile, WeiFile, GBFWEI_DatWrFile,
            NumWei,NumChn ):
    PECMAC_Wei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
    PECMAC_FlgWei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
    for j in range (0, NumWei) :
        #PECMAC_FlgWei[NumWei - 1-j] = FlagWeiFile.read(NumChn)
        #FlagWeiFile.read(1)
        if cnt_Flagwei_hex == 0:
            FlgWei_hex = FlagWeiFile.readline().rstrip('\n') # 12B
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
                elif cntPat != cntPat_last_GBFWEI: # complete the current line
                    print("GBFWEI_DatWr next patch line:", cnt_GBFWEI/12)
                    if cnt_GBFWEI % 12 == 0:
                        Zero = "01"*( 1) 
                        cnt_GBFWEI += 1
                    else:
                        Zero = "01"*( 13 - cnt_GBFWEI % 12) 
                        cnt_GBFWEI +=  13 - cnt_GBFWEI % 12
                    GBFWEI_DatWrFile.write(Zero+'\n')# turn to next line
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
    #if cntPEB==0 and cntPEC ==0:
        #PECMAC_WeiFile.write(PECMAC_Wei_wr )
        #PECMAC_WeiFile.write('\n')

    return PECMAC_Wei, cnt_Flagwei_hex, PECMAC_FlgWei_wr, ColWei, cnt_GBFWEI, cntPat_last_GBFWEI,PECMAC_Wei_wr