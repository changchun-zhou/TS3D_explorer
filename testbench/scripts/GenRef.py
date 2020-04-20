import numpy as np
import random
import os
import PEC
import POOL
import DISWEI
#*********** read files *******************************************
# FlagActFileName = '../Data/dequant_data/prune_quant_extract_high/Activation_45_pool3b_flag.dat'
# ActFileName = '../Data/dequant_data/prune_quant_extract_high/Activation_45_pool3b_data.dat'
# FlagWeiFileName = '../Data/dequant_data/prune_quant_extract_high/Weight_45_conv4a.float_weight_flag.dat'
# WeiFileName = '../Data/dequant_data/prune_quant_extract_high/Weight_45_conv4a.float_weight_data.dat'
FlagActFileName = '../Data/dequant_data/prune_quant_extract_proportion/Activation_45_pool1_flag.dat'
ActFileName = '../Data/dequant_data/prune_quant_extract_proportion/Activation_45_pool1_data.dat'
FlagWeiFileName = '../Data/dequant_data/prune_quant_extract_proportion/Weight_45_conv2.float_weight_flag.dat'
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
GBFFLGACT_DatWrFileName = '../Data/GenTest/GBFFLGACT_DatWr.dat'
GBFACT_DatWrFileName = '../Data/GenTest/GBFACT_DatWr.dat'
GBFWEI_DatWrFileName = '../Data/GenTest/GBFWEI_DatWr.dat'
GBFOFM_DatRdFileName = '../Data/GenTest/RAM_GBFOFM_12B.dat'
PECMAC_WeiFileName = '../Data/GenTest/PECMAC_Wei_Ref.dat'
PECMAC_FlgWeiFileName = '../Data/GenTest/PECMAC_FlgWei_Ref.dat'
NumChn = 32
NumWei = 9
NumBlk = 2
NumFrm = 16
NumPat = 16
KerSize = 3
Stride = 2
fl = 0

NumPEC = 3
NumPEB = 16
Len = 16

PORT_DATAWIDTH = 96
# PSUM_WIDTH = 23

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
GBFFLGACT_DatWrFile = open(GBFFLGACT_DatWrFileName,'w')
GBFACT_DatWrFile = open(GBFACT_DatWrFileName,'w')
GBFWEI_DatWrFile = open(GBFWEI_DatWrFileName,'w')
#Psum2 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ] for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
#Psum1 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
Psum0 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
FRMPOOL = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
DELTA = [[[ 0 for x in range(NumPEB)] for y in range (Len-2)] for z in range(Len-2)]
cnt_ACT = 0
cnt_Flag = 0 # continously save one frame by one frame
GBFFLGOFM_DatRd = ""
GBFOFM_DatRd = ""

cnt_wei = 0
cnt_GBFFLGACT = 0
GBFFLGACT = ""
cntPat_last = 0

cnt_GBFACT = 0
GBFACT = ""
cntPat_last_GBFACT = 0
#cntPat_GBFACT = 0

cnt_GBFWEI = 0;
#cntPat_GBFWEI = 0
cntPat_last_GBFWEI = 0
for cntPat in range(0, NumPat):
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
                        PECMAC_FlgAct_hex = FlgAct_hex[8*(cnt_Flag_hex):8*(cnt_Flag_hex)+8] #4B
                        PECMAC_FlgAct = int(PECMAC_FlgAct_hex,16)
                        PECMAC_FlgAct = str(bin(PECMAC_FlgAct)).lstrip('0b').zfill(NumChn)

                        # ****************************
                        
                        cnt_GBFFLGACT += 1
                        if cnt_GBFFLGACT % 3 == 1 and cnt_GBFFLGACT != 1:  
                            GBFFLGACT_DatWrFile.write(GBFFLGACT + '\n' )
                            GBFFLGACT = ""
                        else:
                            if cntPat != cntPat_last:
                                print("GBFFLGACT_DatWr next patch line:", cnt_GBFFLGACT/12)
                                if cnt_GBFFLGACT % 3 == 0: # current data is third of last patch line
                                    GBFFLGACT += "01"*4
                                    cnt_GBFFLGACT += 1 #Mean: is first of new line
                                elif cnt_GBFFLGACT% 3 == 2:
                                    GBFFLGACT += "01"*8
                                    cnt_GBFFLGACT += 2 #Mean: is first of new line
                                GBFFLGACT_DatWrFile.write(GBFFLGACT + '\n' )
                                GBFFLGACT = ""
                        GBFFLGACT = GBFFLGACT + PECMAC_FlgAct_hex
                        cntPat_last = cntPat #when First data of Patch is write, updata Patch_last
                        # *****************************
                        

                        if cnt_Flag_hex == 2:
                            cnt_Flag_hex = 0
                        else:
                            cnt_Flag_hex += 1
                        # ***************************************************************************

                        PECMAC_FlgActFile.write(PECMAC_FlgAct_hex)
                        PECMAC_FlgActFile.write('\n')
                        #FlagActFile.read(1)
                        for i in range (0, NumChn):
                            if PECMAC_FlgAct[i] == '1' :#ch0
                                act = ActFile.read(2)

                                # ***********************************************
                                cnt_GBFACT += 1 # mean: the count of File
                                if cnt_GBFACT % 12 == 1 and cnt_GBFACT != 1: # when turn line
                                    GBFACT_DatWrFile.write('\n')
                                elif cntPat != cntPat_last_GBFACT: # complete the current line
                                    print("GBFACT_DatWr next patch line:", cnt_GBFACT/12)
                                    if cnt_GBFACT % 12 == 0:
                                        Zero = "01"*( 1) 
                                        cnt_GBFACT += 1
                                    else:
                                        Zero = "01"*( 13 - cnt_GBFACT % 12) 
                                        cnt_GBFACT +=  13 - cnt_GBFACT % 12
                                    GBFACT_DatWrFile.write(Zero+'\n')# turn to next line
                                GBFACT_DatWrFile.write(act) 
                                cntPat_last_GBFACT = cntPat # When new patch's first data, update patch
                                # ************************************************
                                
                                if cnt_act_col == 11:
                                    ActFile.read(1)
                                    cnt_act_col = 0
                                else:
                                    cnt_act_col += 1

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


                for cntPEB in range(0, NumPEB):
                    for cntPEC in range (0, NumPEC):
                        PECMAC_Wei, cnt_Flagwei_hex, PECMAC_FlgWei_wr, ColWei, cnt_GBFWEI, cntPat_last_GBFWEI,PECMAC_Wei_wr= \
                            DISWEI.DISWEI(  cntPat,  
                                            cnt_Flagwei_hex, PECMAC_FlgWei_wr, ColWei, cnt_GBFWEI, cntPat_last_GBFWEI,PECMAC_Wei_wr,
                                            FlagWeiFile, WeiFile, GBFWEI_DatWrFile,
                                            NumWei,NumChn )
 
                        # ***************** PEC **********************************************************
                        # Input: actBlk PECMAC_Wei Psum0(accum) PECRAM_DatWr_PEL RAMPEC_DatRd_PEL ; File, Len, NumWei,cntBlk, frm, PEB,PEC,
                        # input \ iterate \ File \ constan

                        RAMPEC_DatRd_PEL, PECRAM_DatWr_PEL, Psum0 = \
                            PEC.PEC(actBlk, PECMAC_Wei, 
                                    Psum0, PECRAM_DatWr_PEL, RAMPEC_DatRd_PEL, 
                                    CNVOUT_Psum1File, CNVOUT_Psum2File,
                                    Len,NumBlk, NumWei, NumChn,  NumPEB, NumPEC,cntfrm,cntBlk, cntPEB,cntPEC )
                        # Output: RAMPEC_DatRd_PEL PECRAM_DatWr_PEL Psum0
                        # ****** End PEC ***************************

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

        # ************* POOL *****************************
        FRMPOOL, DELTA, cnt_ACT, cnt_Flag, GBFOFM_DatRd, GBFFLGOFM_DatRd = \
            POOL.POOL(  Psum0,fl,
                        FRMPOOL, DELTA, cnt_ACT, cnt_Flag, GBFOFM_DatRd, GBFFLGOFM_DatRd,
                        POOL_SPRS_MEMFile, GBFOFM_DatRdFile, POOL_FLAG_MEMFile, GBFFLGOFM_DatRdFile,
                        Len, Stride, NumBlk, NumPEB, NumPEC, PORT_DATAWIDTH, cntfrm )

