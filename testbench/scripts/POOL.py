import numpy as np
import random
import os
def POOL(   Psum0, fl,
            FRMPOOL, DELTA, cnt_ACT, cnt_Flag, GBFOFM_DatRd, GBFFLGOFM_DatRd, 
            POOL_SPRS_MEMFile, GBFOFM_DatRdFile, POOL_FLAG_MEMFile, GBFFLGOFM_DatRdFile,
            Len, Stride, NumBlk, NumPEB, NumPEC, PORT_DATAWIDTH, cntfrm ):
    print(cntfrm)
    POOL_MEM = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
    SPRS = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
    FLAG_MEM = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
    POOL_SPRS_MEM = ''
    POOL_FLAG_MEM = ''

    for AddrRow in range ( 0, Len-2 - Stride + 1, Stride):
        AddrPooly = AddrRow / Stride
        for AddrCol in range ( 0, Len-2 - Stride + 1, Stride):
            AddrPoolx = AddrCol / Stride
            POOL_FLAG_MEM = ""
            for cntPEB in range (0, NumPEB):
                for cnt_pooly in range (0, Stride):
                    for cnt_poolx in range (0, Stride):
                        PELPOOL_Dat =Psum0[NumBlk -1][cntPEB][NumPEC -1][AddrRow + cnt_pooly][AddrCol+cnt_poolx]
                        if  PELPOOL_Dat > 0:
                            PELPOOL_Dat = '{:030b}'.format(PELPOOL_Dat)
                            ReLU = '0' +  PELPOOL_Dat[23-fl : 30-fl]
                        elif PELPOOL_Dat <= 0 :
                            ReLU = '{:08b}'.format(0)
                        else:
                            print("PELPOOL_Dat ERROR")
                        ReLU = int(ReLU,2)
                        if ReLU > POOL_MEM[AddrPooly][AddrPoolx][cntPEB] :
                            POOL_MEM[AddrPooly][AddrPoolx][cntPEB] = ReLU;
                # if cntfrm == 1 or cntfrm == 3: # Pooling frame
                if cntfrm % 2 == 1:
                    if FRMPOOL[AddrPooly][AddrPoolx][cntPEB] > POOL_MEM[AddrPooly][AddrPoolx][cntPEB] :
                        POOL_MEM[AddrPooly][AddrPoolx][cntPEB] = FRMPOOL[AddrPooly][AddrPoolx][cntPEB];
                elif cntfrm % 2 == 0: # 0 , 2
                        FRMPOOL[AddrPooly][AddrPoolx][cntPEB] = POOL_MEM[AddrPooly][AddrPoolx][cntPEB] # update frame for pool_frame
                SPRS[AddrPooly][AddrPoolx][cntPEB] = POOL_MEM[AddrPooly][AddrPoolx][cntPEB] - DELTA[AddrPooly][AddrPoolx][cntPEB]
                DELTA[AddrPooly][AddrPoolx][cntPEB] = POOL_MEM[AddrPooly][AddrPoolx][cntPEB];# update frame for delta
                if SPRS[AddrPooly][AddrPoolx][cntPEB] != 0:
                    FLAG_MEM[AddrPooly][AddrPoolx][cntPEB]  = 1

                    if SPRS[AddrPooly][AddrPoolx][cntPEB] > 0:
                        POOL_SPRS_MEM = ((str(hex(SPRS[AddrPooly][AddrPoolx][cntPEB])).lstrip('0x')).rstrip('L')).zfill(2)
                    else: # neg [-127, 0)
                        POOL_SPRS_MEM = ((str(hex(SPRS[AddrPooly][AddrPoolx][cntPEB]+256)).lstrip('0x')).rstrip('L')).zfill(2)
                    POOL_SPRS_MEMFile.write(POOL_SPRS_MEM+'\n')
                    if cnt_ACT < PORT_DATAWIDTH/8 : #12B
                        GBFOFM_DatRd =POOL_SPRS_MEM + GBFOFM_DatRd;
                        cnt_ACT = cnt_ACT + 1
                    else:
                        GBFOFM_DatRdFile.write(GBFOFM_DatRd+'\n')
                        cnt_ACT = 1
                        GBFOFM_DatRd = ''
                        GBFOFM_DatRd =POOL_SPRS_MEM + GBFOFM_DatRd;
                else:
                    FLAG_MEM[AddrPooly][AddrPoolx][cntPEB]  = 0
                POOL_FLAG_MEM =  str(FLAG_MEM[AddrPooly][AddrPoolx][cntPEB] ) +POOL_FLAG_MEM  # PEB15 PEB1 PEB0
            POOL_FLAG_MEM0 = int(POOL_FLAG_MEM[0:8], 2)
            POOL_FLAG_MEM1 = int(POOL_FLAG_MEM[8:16], 2)
            POOL_FLAG_MEM_hex =  str(hex(POOL_FLAG_MEM0)).lstrip('0x').rstrip('L').zfill(2) + str(hex(POOL_FLAG_MEM1)).lstrip('0x').rstrip('L').zfill(2);
            POOL_FLAG_MEMFile.write(POOL_FLAG_MEM_hex+'\n')#HEX
            if cnt_Flag < PORT_DATAWIDTH/NumPEB: #12
                GBFFLGOFM_DatRd = POOL_FLAG_MEM_hex + GBFFLGOFM_DatRd #shift right
                cnt_Flag = cnt_Flag + 1
            else:
                GBFFLGOFM_DatRdFile.write(GBFFLGOFM_DatRd+'\n') #HEX
                cnt_Flag = 1
                GBFFLGOFM_DatRd = ''
                GBFFLGOFM_DatRd = POOL_FLAG_MEM_hex + GBFFLGOFM_DatRd #shift right
            #AddrPoolx = AddrPoolx + 1
        #AddrPooly = AddrPooly + 1;
    return FRMPOOL, DELTA, cnt_ACT, cnt_Flag, GBFOFM_DatRd, GBFFLGOFM_DatRd
