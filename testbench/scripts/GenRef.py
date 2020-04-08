import numpy as np
import random
import os
#*********** read files *******************************************
FlagActFileName = '../Data/dequant_data/prune_quant_extract_proportion/Activation_45_pool1_flag.dat'
FlagWeiFileName = '../Data/dequant_data/prune_quant_extract_proportion/Weight_45_conv2.float_weight_flag.dat'
ActFileName = '../Data/dequant_data/prune_quant_extract_proportion/Activation_45_pool1_data.dat'
WeiFileName = '../Data/dequant_data/prune_quant_extract_proportion/Weight_45_conv2.float_weight_data.dat'

#*********** write files  *****************************************
PECRAM_DatWrFileName = '../Data/GenTest/PECRAM_DatWr_Ref.dat'
RAMPEC_DatRdFileName = '../Data/GenTest/RAMPEC_DatRd_Ref.dat'
CNVOUT_Psum2FileName = '../Data/GenTest/CNVOUT_Psum2.dat'
CNVOUT_Psum1FileName = '../Data/GenTest/CNVOUT_Psum1.dat'
CNVOUT_Psum0FileName = '../Data/GenTest/CNVOUT_Psum0.dat'
PECMAC_ActFileName = "../Data/GenTest/PECMAC_Act_Gen.dat"
PECMAC_FlgActFileName='../Data/GenTest/PECMAC_FlgAct_Gen.dat'
POOL_SPRS_MEMFileName='../Data/GenTest/POOL_SPRS_MEM_Ref.dat'
POOL_FLAG_MEMFileName='../Data/GenTest/POOL_FLAG_MEM_Ref.dat'
GBFFLGOFM_DatRdFileName = '../Data/GenTest/RAM_GBFFLGOFM_12B.dat'
GBFOFM_DatRdFileName = '../Data/GenTest/RAM_GBFOFM_12B.dat'
PECMAC_WeiFileName = '../Data/GenTest/PECMAC_Wei_Ref.dat'
PECMAC_FlgWeiFileName = '../Data/GenTest/PECMAC_FlgWei_Ref.dat'
NumChn = 32
NumWei = 9
NumBlk = 2
NumFrm = 4

NumPEC = 3
NumPEB = 16
Len = 16
KerSize = 3
Stride = 2
fl = 0
PORT_DATAWIDTH = 96
# PSUM_WIDTH = 23

PECMAC_Wei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
PECMAC_FlgWei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
cnt_Flag_hex = 0
cntActError = 0
cnt_act_hex = 0
cnt_act_col = 0
# def int2hex (dat_int, width):
#     dat_hex = '{:0widthb}'.format(dat_int)
#     return dat_hex

FlagActFile        = open (FlagActFileName,        'r')
ActFile            = open (ActFileName,            'r')
PECMAC_ActFile     = open (PECMAC_ActFileName,     'w') 
PECMAC_FlgActFile  = open (PECMAC_FlgActFileName,  'w')
POOL_SPRS_MEMFile  = open (POOL_SPRS_MEMFileName,  'w')
POOL_FLAG_MEMFile  = open (POOL_FLAG_MEMFileName,  'w') 
RAMPEC_DatRdFile   = open (RAMPEC_DatRdFileName,   'w') 
PECMAC_FlgWeiFile = open (PECMAC_FlgWeiFileName, 'w')
GBFFLGOFM_DatRdFile= open (GBFFLGOFM_DatRdFileName,'w')
GBFOFM_DatRdFile   = open (GBFOFM_DatRdFileName,   'w') 

CNVOUT_Psum2File   = open(CNVOUT_Psum2FileName, 'w')
PECRAM_DatWrFile   = open(PECRAM_DatWrFileName, 'w')
PECMAC_WeiFile    = open (PECMAC_WeiFileName,'w')
CNVOUT_Psum1File   = open(CNVOUT_Psum1FileName, 'w')

Psum2 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ] for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
Psum1 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
Psum0 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
FRMPOOL = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
DELTA = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
cnt_ACT = 0
cnt_Flag = 0 # continously save one frame by one frame
GBFFLGOFM_DatRd = ""
GBFOFM_DatRd = ""
cnt_wei = 0
for cntfrm in range(0,NumFrm):
    # same weight per frame
    with open(FlagWeiFileName, 'r') as FlagWeiFile,\
        open(WeiFileName, 'r') as WeiFile:
        cnt_Flagwei_hex = 0
        cnt_wei_hex = 0
        ColWei = 0
        for cntBlk in range (0, NumBlk ):
            PECMAC_Wei_wr = ''
            PECMAC_FlgWei_wr = ''
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
                    #PECMAC_FlgAct  = FlagActFile.read(NumChn) # == DISACT_FlgAct
                    # *************************************************************************
                    if cnt_Flag_hex == 0:
                        FlgAct_hex = FlagActFile.readline().rstrip('\n') # 12B
                    PECMAC_FlgAct = FlgAct_hex[8*(cnt_Flag_hex):8*(cnt_Flag_hex)+8] #4B
                    PECMAC_FlgAct = int(PECMAC_FlgAct,16)
                    PECMAC_FlgAct = str(bin(PECMAC_FlgAct)).lstrip('0b').zfill(NumChn)
                    if cnt_Flag_hex == 2:
                        cnt_Flag_hex = 0
                    else:
                        cnt_Flag_hex += 1
                    #***************************************************************************

                    PECMAC_FlgActFile.write(PECMAC_FlgAct)
                    #FlagActFile.read(1)
                    for i in range (0, NumChn):
                        if PECMAC_FlgAct[i] == '1' :#ch0
                            act = ActFile.read(2)
                            if cnt_act_col == 11:
                                ActFile.read(1)
                                cnt_act_col = 0
                            else:
                                cnt_act_col += 1
                            #ActFile.read(1)
                            """# *************************************************************************
                            if cnt_act_hex == 0:
                                Act_hex = ActFile.readline().rstrip('\n') # 12B
                            act = Act_hex[2*(11-cnt_act_hex):2*(11-cnt_act_hex)+2] #4B ch0
                            if cnt_act_hex == 11:
                                cnt_act_hex = 0
                            else:
                                cnt_act_hex += 1
                            #***************************************************************************
                            """

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
            
            for cntPEB in range(0, NumPEB):
                for cntPEC in range (0, NumPEC):

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
                                cnt_wei += 1

                                """
                                if cnt_wei_hex == 0:
                                    Wei_hex_array = ''
                                    #Wei_hex = WeiFile.readline().rstrip('\n') # 12B
                                    Wei_hex_array = Wei_hex_array + WeiFile.readline().rstrip('\n')
                                    Wei_hex_array = Wei_hex_array + WeiFile.readline().rstrip('\n')
                                    Wei_hex_array = Wei_hex_array + WeiFile.readline().rstrip('\n')
                                wei = Wei_hex_array[2*cnt_wei_hex:2*cnt_wei_hex+2] #4B
                                if cnt_wei_hex == 3:
                                    cnt_wei_hex = 0
                                else:
                                    cnt_wei_hex += 1
                                """
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
                    acc = [ [ [0 for x in range (0,NumWei)] for y in range(0, Len)] for z in range(0, Len)]
                    for actrow in range(0, Len) :
                        for actcol in range(0, Len):
                            for j in range(0, NumWei):
                                for m in range (0, NumChn):
                                    acc[actrow][actcol][j] = acc[actrow][actcol][j] + actBlk[actrow][actcol][m] * PECMAC_Wei[j][m]
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
                    # Every PEC a line: WEI0(0000ch1 ch31) WEI1   
                    PECMAC_WeiFile.write(PECMAC_Wei_wr )
                    PECMAC_WeiFile.write('\n')
                    PECMAC_Wei_wr = ''
            #Block0:[[Chn0-31]wei0-wei8]PEC0-PEC47 \n
            PECMAC_FlgWeiFile.write(PECMAC_FlgWei_wr+'\n')
            # save first block then second block
            for psumrow in range(0, Len):
                for psumcol in range(0,Len):
                    #if psumrow >=2:
                        #CNVOUT_Psum2File.write(CNVOUT_Psum2_PEL[psumrow][psumcol]+'\n')
                    #CNVOUT_Psum1File.write(CNVOUT_Psum1_PEL[psumrow][psumcol]+'\n')
                    if psumrow < Len - 2  and psumcol < Len-2:  # 14rows
                        # (PEB0)PEC0 PEC1 PEC2 (PEB1)PEC0 PEC1 PEC2 .....
                        RAMPEC_DatRdFile.write(RAMPEC_DatRd_PEL[psumrow][psumcol]+'\n')
                        PECRAM_DatWrFile.write(PECRAM_DatWr_PEL[psumrow][psumcol]+'\n')

    print(cntfrm)
    POOL_MEM = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
    SPRS = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
    FLAG_MEM = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
    POOL_SPRS_MEM = ''
    POOL_FLAG_MEM = ''
    GBFFLGOFM_DatRd = ""
    GBFOFM_DatRd = ""
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
                if cntfrm == 1 or cntfrm == 3: # Pooling frame
                    if FRMPOOL[AddrPooly][AddrPoolx][cntPEB] > POOL_MEM[AddrPooly][AddrPoolx][cntPEB] :
                        POOL_MEM[AddrPooly][AddrPoolx][cntPEB] = FRMPOOL[AddrPooly][AddrPoolx][cntPEB];
                elif cntfrm == 0 or cntfrm == 2:
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
                        cnt_ACT = 0
                        GBFOFM_DatRd = ''
                else:
                    FLAG_MEM[AddrPooly][AddrPoolx][cntPEB]  = 0
                POOL_FLAG_MEM =  str(FLAG_MEM[AddrPooly][AddrPoolx][cntPEB] ) +POOL_FLAG_MEM  # PEB15 PEB1 PEB0
            POOL_FLAG_MEMFile.write(POOL_FLAG_MEM+'\n')#二进制
            if cnt_Flag < PORT_DATAWIDTH/NumPEB: #12
                GBFFLGOFM_DatRd = POOL_FLAG_MEM + GBFFLGOFM_DatRd #shift right
                cnt_Flag = cnt_Flag + 1
            else:
                GBFFLGOFM_DatRdFile.write(GBFFLGOFM_DatRd+'\n')
                cnt_Flag = 0
                GBFFLGOFM_DatRd = ''
            #AddrPoolx = AddrPoolx + 1
        #AddrPooly = AddrPooly + 1;

