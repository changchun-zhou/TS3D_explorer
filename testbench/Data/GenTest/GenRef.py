import numpy as np
import random
import os

FlagActFileName = '../RAM_GBFFLGACT_bin.dat'
FlagWeiFileName = '../RAM_GBFFLGWEI.dat'
ActFileName = '../RAM_GBFACT_1B.dat'
WeiFileName = '../RAM_GBFWEI.dat'
PECRAM_DatWrFileName = 'PECRAM_DatWr_Ref.dat'
RAMPEC_DatRdFileName = 'RAMPEC_DatRd_Ref.dat'
CNVOUT_Psum2FileName = 'CNVOUT_Psum2.dat'
CNVOUT_Psum1FileName = 'CNVOUT_Psum1.dat'
CNVOUT_Psum0FileName = 'CNVOUT_Psum0.dat'
PECMAC_ActFileName = "PECMAC_Act_Gen.dat"
PECMAC_FlgActFileName='PECMAC_FlgAct_Gen.dat'
GBFOFM_DatWrFileName='GBFOFM_DatWr_Ref.dat'
GBFFLGOFM_DatWrFileName='GBFFLGOFM_DatWr_Ref.dat'
PECMAC_Wei0FileName = 'PECMAC_Wei0.dat'
PECMAC_FlgWei0FileName = 'PECMAC_FlgWei0_Ref.dat'
NumChn = 32
NumWei = 9
NumBlk = 2
NumFrm = 4

NumPEC = 3
NumPEB = 2
Len = 16
KerSize = 3
Stride = 2
fl = 0
PORT_DATAWIDTH = 96
# PSUM_WIDTH = 23

PECMAC_Wei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
PECMAC_FlgWei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]

cntActError = 0
# def int2hex (dat_int, width):
#     dat_hex = '{:0widthb}'.format(dat_int)
#     return dat_hex
with    open(FlagActFileName, 'r') as FlagActFile, \
        open(ActFileName, 'r') as ActFile,\
        open (PECMAC_ActFileName, 'w') as PECMAC_ActFile,\
        open(PECMAC_FlgActFileName, 'w') as PECMAC_FlgActFile,\
        open(GBFOFM_DatWrFileName,'w') as GBFOFM_DatWrFile, \
        open(GBFFLGOFM_DatWrFileName,'w') as GBFFLGOFM_DatWrFile, \
        open(CNVOUT_Psum2FileName, 'w') as CNVOUT_Psum2File, \
        open(PECRAM_DatWrFileName, 'w') as PECRAM_DatWrFile, \
        open(RAMPEC_DatRdFileName, 'w') as RAMPEC_DatRdFile, \
        open(PECMAC_FlgWei0FileName,'w') as PECMAC_FlgWei0File:
        #open (PECMAC_Wei0FileName,'w') as PECMAC_Wei0File:
        #open(CNVOUT_Psum1FileName, 'w') as CNVOUT_Psum1File, \

                        Psum2 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ] for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
                        Psum1 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
                        Psum0 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
                        FRMPOOL = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
                        DELTA = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
                        cnt_ACT = 0
                        cnt_Flag = 0 # continously save one frame by one frame
                        for cntfrm in range(0,NumFrm):

                            # same weight per frame
                            with open(FlagWeiFileName, 'r') as FlagWeiFile,\
                                open(WeiFileName, 'r') as WeiFile:
                                ColWei = 0

                                for cntBlk in range (0, NumBlk ):
                                    actBlk = [[[ 0 for x in range (0,NumChn)] for y in range (0,Len)] for z in range(0,Len)]
                                    CNVOUT_Psum2_PEL =[['' for x in range ( 0, Len)] for y in range(0,Len)]
                                    CNVOUT_Psum1_PEL =[['' for x in range ( 0, Len)] for y in range(0,Len)]
                                    CNVOUT_Psum0_PEL = [['' for x in range ( 0, Len)] for y in range(0,Len)]
                                    PECRAM_DatWr_PEL = [['' for x in range ( 0, Len-2)] for y in range(0,Len-2)]
                                    RAMPEC_DatRd_PEL = [['' for x in range ( 0, Len-2)] for y in range(0,Len-2)]

                                    #Fetch a block activation
                                    for actrow in range(0, Len) :
                                        for actcol in range(0, Len):
                                            PECMAC_Act = ''
                                            PECMAC_FlgAct  = FlagActFile.read(NumChn) # == DISACT_FlgAct
                                            PECMAC_FlgActFile.write(PECMAC_FlgAct)
                                            FlagActFile.read(1)
                                            for i in range (0, NumChn):
                                                if PECMAC_FlgAct[NumChn-1-i] == '1' :
                                                    act = ActFile.read(2)
                                                    ActFile.read(1)
                                                    cntActError = cntActError + 1
                                                    PECMAC_Act = PECMAC_Act + act
                                                    if act == '':
                                                        print('error')
                                                        print(cntActError)
                                                else :
                                                    act = "00"
                                                    PECMAC_Act = "00" + PECMAC_Act
                                            # transfer to not sparsity: one demensional row
                                                act = int(act,16)
                                                if act >127:
                                                    act = act -256
                                                actBlk[actrow][actcol][i] = act
                                            PECMAC_ActFile.write(PECMAC_Act)

                                            PECMAC_ActFile.write('\n')
                                            PECMAC_FlgActFile.write('\n')
                                    temp_PECMAC_FlgWei = ''
                                    for cntPEB in range(0, NumPEB):
                                        for cntPEC in range (0, NumPEC):

                                            for j in range (0, NumWei) :
                                                PECMAC_FlgWei[NumWei - 1-j] = FlagWeiFile.read(NumChn)
                                                FlagWeiFile.read(1)
                                            for j in range(0,NumWei):
                                                for i in range (0, NumChn):
                                                    temp_PECMAC_FlgWei = temp_PECMAC_FlgWei + str(PECMAC_FlgWei[j][i])
                                            PECMAC_Wei0 = ''
                                            for j in range (0, NumWei) :
                                                for k in range (0, NumChn):
                                                    if PECMAC_FlgWei[NumWei - 1-j][NumChn-1-k] == '1':
                                                        if ColWei == 9 :
                                                            WeiFile.read(1)
                                                            ColWei = 1
                                                        else :
                                                            ColWei = ColWei + 1 #cnt
                                                        wei = WeiFile.read(2)
                                                        if cntPEB==0 and cntPEC ==0 and j == NumWei - 1:
                                                            PECMAC_Wei0 = PECMAC_Wei0 + wei
                                                    elif PECMAC_FlgWei[NumWei - 1-j][NumChn-1-k] == '0':
                                                        wei = "00"
                                                        if cntPEB==0 and cntPEC ==0 and j == NumWei - 1:
                                                            PECMAC_Wei0 = '00' + PECMAC_Wei0
                                                    else:
                                                        print('PECMAC_FlgWei['+ (NumWei - 1-j) +']'+ 'Error')
                                                    wei = int(wei, 16)
                                                    if wei > 127:
                                                        wei = wei - 256
                                                    PECMAC_Wei[NumWei-1-j][NumChn-1-k] = wei
                                            #if cntPEB==0 and cntPEC ==0:
                                                #PECMAC_Wei0File.write(PECMAC_Wei0 )
                                               # PECMAC_Wei0File.write('\n')
                                            acc = [ [ [0 for x in range (0,NumWei)] for y in range(0, Len)] for z in range(0, Len)]
                                            for actrow in range(0, Len) :
                                                for actcol in range(0, Len):
                                                    for j in range(0, NumWei):
                                                        for m in range (0, NumChn):
                                                            acc[actrow][actcol][j] = acc[actrow][actcol][j] + actBlk[actrow][actcol][m] * PECMAC_Wei[j][NumChn-1-m]
                                            CNVOUT_Psum2 = [['' for x in range ( 0, Len)] for y in range(0,Len)]
                                            CNVOUT_Psum1 = [['' for x in range ( 0, Len)] for y in range(0,Len)]
                                            CNVOUT_Psum0 = [['' for x in range ( 0, Len)] for y in range(0,Len)]
                                            PECRAM_DatWr = [['' for x in range ( 0, Len-2)] for y in range(0,Len-2)]
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
                                    PECMAC_FlgWei0File.write(temp_PECMAC_FlgWei+'\n')
                                    # save first block then second block
                                    for psumrow in range(0, Len):
                                        for psumcol in range(0,Len):
                                            #if psumrow >=2:
                                                #CNVOUT_Psum2File.write(CNVOUT_Psum2_PEL[psumrow][psumcol]+'\n')
                                            #CNVOUT_Psum1File.write(CNVOUT_Psum1_PEL[psumrow][psumcol]+'\n')
                                            if psumrow < Len - 2  and psumcol < Len-2:  # 14rows
                                                RAMPEC_DatRdFile.write(RAMPEC_DatRd_PEL[psumrow][psumcol]+'\n')
                                                PECRAM_DatWrFile.write(PECRAM_DatWr_PEL[psumrow][psumcol]+'\n')

                            print(cntfrm)
                            POOL_MEM = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
                            SPRS = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
                            FLAG_MEM = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
                            GBFOFM_DatWr = ''
                            GBFFLGOFM_DatWr = ''

                            for AddrRow in range ( 0, Len-2 - Stride + 1, Stride):
                                AddrPooly = AddrRow / Stride
                                for AddrCol in range ( 0, Len-2 - Stride + 1, Stride):
                                    AddrPoolx = AddrCol / Stride
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
                                        if cntfrm == 1 or cntfrm == 3: # Pooling frame
                                            if FRMPOOL[AddrPooly][AddrPoolx][cntPEB] > POOL_MEM[AddrPooly][AddrPoolx][cntPEB] :
                                                POOL_MEM[AddrPooly][AddrPoolx][cntPEB] = FRMPOOL[AddrPooly][AddrPoolx][cntPEB];
                                        elif cntfrm == 0 or cntfrm == 2:
                                                FRMPOOL[AddrPooly][AddrPoolx][cntPEB] = POOL_MEM[AddrPooly][AddrPoolx][cntPEB] # update frame for pool_frame
                                        SPRS[AddrPooly][AddrPoolx][cntPEB] = POOL_MEM[AddrPooly][AddrPoolx][cntPEB] - DELTA[AddrPooly][AddrPoolx][cntPEB]
                                        DELTA[AddrPooly][AddrPoolx][cntPEB] = POOL_MEM[AddrPooly][AddrPoolx][cntPEB];# update frame for delta
                                        if SPRS[AddrPooly][AddrPoolx][cntPEB] != 0:
                                            FLAG_MEM[AddrPooly][AddrPoolx][cntPEB]  = 1
                                            #if cnt_ACT < PORT_DATAWIDTH/8 :
                                            if SPRS[AddrPooly][AddrPoolx][cntPEB] > 0:
                                                GBFOFM_DatWr = ((str(hex(SPRS[AddrPooly][AddrPoolx][cntPEB])).lstrip('0x')).rstrip('L')).zfill(2)
                                            else: # neg [-127, 0)
                                                GBFOFM_DatWr = ((str(hex(SPRS[AddrPooly][AddrPoolx][cntPEB]+256)).lstrip('0x')).rstrip('L')).zfill(2)
                                            GBFOFM_DatWrFile.write(GBFOFM_DatWr+'\n')
                                            #cnt_ACT = cnt_ACT + 1
                                        #else:
                                            #GBFOFM_DatWrFile.write(GBFOFM_DatWr+'\n')
                                            #cnt_ACT = 0
                                            #GBFOFM_DatWr = ''
                                        else:
                                            FLAG_MEM[AddrPooly][AddrPoolx][cntPEB]  = 0
                                        if cnt_Flag < PORT_DATAWIDTH:
                                            GBFFLGOFM_DatWr = str(FLAG_MEM[AddrPooly][AddrPoolx][cntPEB] ) + GBFFLGOFM_DatWr
                                            cnt_Flag = cnt_Flag + 1
                                        else:
                                            GBFFLGOFM_DatWrFile.write(GBFFLGOFM_DatWr+'\n')
                                            cnt_Flag = 0
                                            GBFFLGOFM_DatWr = ''
                                    #AddrPoolx = AddrPoolx + 1
                                #AddrPooly = AddrPooly + 1;

