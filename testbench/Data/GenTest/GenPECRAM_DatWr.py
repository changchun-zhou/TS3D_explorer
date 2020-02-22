import numpy as np
import random
import os

FlagActFileName = '../RAM_GBFFLGACT_bin.dat'
FlagWeiFileName = '../RAM_GBFFLGWEI.dat'
ActFileName = '../RAM_GBFACT.dat'
WeiFileName = '../RAM_GBFWEI.dat'
PECRAM_DatWrFileName = 'PECRAM_DatWr_Ref.dat'
CNVOUT_Psum2FileName = 'CNVOUT_Psum2.dat'
CNVOUT_Psum1FileName = 'CNVOUT_Psum1.dat'
CNVOUT_Psum0FileName = 'CNVOUT_Psum0.dat'
PECMAC_ActFileName = "PECMAC_Act_Gen.dat"
PECMAC_FlgActFileName='PECMAC_FlgAct_Gen.dat'
PECMAC_Wei0FileName = 'PECMAC_Wei0.dat'

NumChn = 32
NumWei = 9
NumBlk = 2
NumFrm = 4

NumPEC = 3
NumPEB = 2
Len = 16
KerSize = 3
# PSUM_WIDTH = 23

PECMAC_Wei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
PECMAC_FlgWei = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]

   
#CNVOUT_PsumHEX = [['' for x in range ( 0, Len )] for y in range(0, KerSize)]
'''
Mac0 = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
Mac1 = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
Mac2 = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
CNVOUT_Psum = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
'''
# acc = [ [0 for x in range (0,NumWei)] for y in range(0, Len*Len)]
# acc = [ [ [[0] * NumWei] * Len ] * Len ]
#out = [ [ 0 for x in range (0,Len -2)] for y in range(0, Len -2) ]

cntActError = 0
# def int2hex (dat_int, width):
#     dat_hex = '{:0widthb}'.format(dat_int)
#     return dat_hex
with    open(FlagActFileName, 'r') as FlagActFile, \
        open(ActFileName, 'r') as ActFile,\
        open (CNVOUT_Psum2FileName, 'w') as CNVOUT_Psum2File,\
        open (CNVOUT_Psum1FileName, 'w') as CNVOUT_Psum1File,\
        open (CNVOUT_Psum0FileName, 'w') as CNVOUT_Psum0File,\
        open (PECMAC_ActFileName, 'w') as PECMAC_ActFile,\
        open(PECMAC_FlgActFileName, 'w') as PECMAC_FlgActFile,\
        open(PECRAM_DatWrFileName, 'w') as PECRAM_DatWrFile, \
        open (PECMAC_Wei0FileName,'w') as PECMAC_Wei0File:
                        Psum2 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ] for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
                        Psum1 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]
                        Psum0 = [[[[ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]for z in range(0, NumPEC)] for m in range(0,NumPEB)] for n in range(0,NumBlk)]

                        for cntfrm in range(0,NumFrm):

                            # same weight per frame
                            with open(FlagWeiFileName, 'r') as FlagWeiFile,\
                                open(WeiFileName, 'r') as WeiFile:
                                ColWei = 0

                                for cntBlk in range (0, NumBlk ):
                                    actBlk = [[[ 0 for x in range (0,NumChn)] for y in range (0,Len)] for z in range(0,Len)]
                                    CNVOUT_Psum2_PEL = ['' for x in range ( 0, Len )]
                                    CNVOUT_Psum1_PEL = ['' for x in range ( 0, Len )]
                                    CNVOUT_Psum0_PEL = ['' for x in range ( 0, Len )]
                                    PECRAM_DatWr_PEL = ['' for x in range ( 0, Len-2)]

                                    #Fetch a block activation
                                    for actrow in range(0, Len) : 
                                        for actcol in range(0, Len):
                                            PECMAC_Act = ''
                                            #PECMAC_FlgAct = ['' for x in range (0,NumChn)]
                                            PECMAC_FlgAct  = FlagActFile.read(NumChn) # == DISACT_FlgAct
                                            PECMAC_FlgActFile.write(PECMAC_FlgAct)

                                            FlagActFile.read(1)
                                            for i in range (0, NumChn): 
                                                if PECMAC_FlgAct[NumChn-1-i] == '1' :
                                                    act = ActFile.read(2)
                                                    ActFile.read(1)
                                                    cntActError = cntActError + 1
                                                    PECMAC_Act = PECMAC_Act + act
                                                    
                                                   # PECMAC_ActFile.write(act)

                                                    if act == '':
                                                        print('error')
                                                        print(cntActError)
                                                else :
                                                    act = 0
                                                    PECMAC_Act = "00" + PECMAC_Act
                                            # transfer to not sparsity: one demensional row
                                                actBlk[actrow][actcol][i] = act
                                            #if actrow ==0 and actcol==0 and cntBlk==0:
                                                #print(PECMAC_FlgAct)
                                                #print(PECMAC_Act)
                                            PECMAC_ActFile.write(PECMAC_Act)

                                            PECMAC_ActFile.write('\n')
                                            PECMAC_FlgActFile.write('\n')
                                    for cntPEB in range(0, NumPEB):
                                        for cntPEC in range (0, NumPEC):

                                            for j in range (0, NumWei) :
                                                PECMAC_FlgWei[NumWei - 1-j] = FlagWeiFile.read(NumChn)
                                                FlagWeiFile.read(1)
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
                                                        wei = 0
                                                        if cntPEB==0 and cntPEC ==0 and j == NumWei - 1:
                                                            PECMAC_Wei0 = '00' + PECMAC_Wei0
                                                    else:
                                                        print('PECMAC_FlgWei['+ (NumWei - 1-j) +']'+ 'Error')
                                                    PECMAC_Wei[NumWei-1-j][NumChn-1-k] = wei
                                           # if cntPEB ==0 and cntPEC ==0:
                                                #print(PECMAC_FlgWei[0]) # wei0
                                                #print(DISWEIPEC_Wei)
                                            if cntPEB==0 and cntPEC ==0:
                                                PECMAC_Wei0File.write(PECMAC_Wei0 )
                                                PECMAC_Wei0File.write('\n')
                                            acc = [ [ [0 for x in range (0,NumWei)] for y in range(0, Len)] for z in range(0, Len)]
                                            for actrow in range(0, Len) : 
                                                for actcol in range(0, Len):
                                                    for j in range(0, NumWei):
                                                        for m in range (0, NumChn):
                                                            acc[actrow][actcol][j] = acc[actrow][actcol][j] + int(str(actBlk[actrow][actcol][m]),16) * int(str(PECMAC_Wei[j][NumChn-1-m]),16)
                                            #print(DISWEIPEC_Wei)
                                            #if cntPEB ==0 and cntPEC==0 and cntBlk ==0:
                                                #print(acc[0][0])
                                               # print(PECMAC_Wei[6])
                                            CNVOUT_Psum2 = ['' for x in range ( 0, Len )]
                                            CNVOUT_Psum1 = ['' for x in range ( 0, Len )]
                                            CNVOUT_Psum0 = ['' for x in range ( 0, Len )]
                                            PECRAM_DatWr = ['' for x in range ( 0, Len-2)]
                                            for psumrow in range(0, Len):
                                                for psumcol in range(0, Len-2):
                                                    # add previous Psum of previous blk
                                                    if cntBlk == 0:
                                                        if cntPEC > 0:
                                                            #Firstly, Compute fist blk of all PEC. Psum0[NumBlk-1]
                                                            #pass across RF0 to PEC1 AT first Block
                                                            Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] = Psum0[NumBlk-1][cntPEB][cntPEC-1][psumrow][psumcol] + acc[psumrow][psumcol][0] + acc[psumrow][psumcol+1][1] + acc[psumrow][psumcol+2][2];
                                                        else:
                                                            Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] = 0 + acc[psumrow][psumcol][0] + acc[psumrow][psumcol+1][1] + acc[psumrow][psumcol+2][2];
                                                        if psumrow == 0 :
                                                            Psum1[cntBlk][cntPEB][cntPEC][psumrow][psumcol]  = 0 + acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5];
                                                        else :
                                                            Psum1[cntBlk][cntPEB][cntPEC][psumrow][psumcol]  = 0 + acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5] + Psum2[cntBlk][cntPEB][cntPEC][psumrow -1][psumcol];
                                                        #if psumrow == 0 :
                                                           # Psum0[psumrow][psumcol] = acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8];
                                                        if psumrow >= 2 :
                                                            Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol] =  0  + acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8] + Psum1[cntBlk][cntPEB][cntPEC][psumrow -1][psumcol];
                                                        
                                                        CNVOUT_Psum2[psumrow] = CNVOUT_Psum2[psumrow] + '{:023b}'.format(Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol])
                                                        CNVOUT_Psum1[psumrow] = CNVOUT_Psum1[psumrow] + '{:023b}'.format(Psum1[cntBlk][cntPEB][cntPEC][psumrow][psumcol])
                                                        if psumrow >= 2 :  # 14rows
                                                            CNVOUT_Psum0[psumrow-2] = CNVOUT_Psum0[psumrow-2] + '{:023b}'.format(Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol])
                                                            if psumcol > 1 : #drop two rows
                                                                PECRAM_DatWr[psumrow-2] = PECRAM_DatWr[psumrow-2] + '{:023b}'.format(Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol])
                                                            else :
                                                                PECRAM_DatWr[psumrow-2] = '{:023b}'.format(0) + PECRAM_DatWr[psumrow-2] 
                                                    else : # ACCumulate across channel
                                                        #DPsum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] = Psum0[cntBlk-1][cntPEB][cntPEC][psumrow][psumcol] + acc[psumrow][psumcol][0] + acc[psumrow][psumcol+1][1] + acc[psumrow][psumcol+2][2];
                                                        Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol] = Psum0[cntBlk-1][cntPEB][cntPEC][psumrow][psumcol] + acc[psumrow][psumcol][0] + acc[psumrow][psumcol+1][1] + acc[psumrow][psumcol+2][2];
                                                        if psumrow == 0 :
                                                            Psum1[cntBlk][cntPEB][cntPEC][psumrow][psumcol]  =  acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5];
                                                        else :
                                                            Psum1[cntBlk][cntPEB][cntPEC][psumrow][psumcol]  =  acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5] + Psum2[cntBlk][cntPEB][cntPEC][psumrow -1][psumcol];
                                                        #if psumrow == 0 :
                                                           # Psum0[psumrow][psumcol] = acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8];
                                                        if psumrow >= 2 :
                                                            Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol] =   acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8] + Psum1[cntBlk][cntPEB][cntPEC][psumrow -1][psumcol];
                                                        CNVOUT_Psum2[psumrow] = CNVOUT_Psum2[psumrow] + '{:023b}'.format(Psum2[cntBlk][cntPEB][cntPEC][psumrow][psumcol])
                                                        CNVOUT_Psum1[psumrow] = CNVOUT_Psum1[psumrow] + '{:023b}'.format(Psum1[cntBlk][cntPEB][cntPEC][psumrow][psumcol])
                                                        if psumrow >= 2 :  # 14rows
                                                            CNVOUT_Psum0[psumrow-2] = CNVOUT_Psum0[psumrow-2] + '{:023b}'.format(Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol])
                                                            if psumcol > 1 : #drop two rows
                                                                PECRAM_DatWr[psumrow-2] = PECRAM_DatWr[psumrow-2] + '{:023b}'.format(Psum0[cntBlk][cntPEB][cntPEC][psumrow-2][psumcol])
                                                            else :
                                                                PECRAM_DatWr[psumrow-2] = '{:023b}'.format(0) + PECRAM_DatWr[psumrow-2] 

                                                #print(CNVOUT_Psum0[psumrow])

                                                # transfer to hex firstly
                                                # All PEC: PEC0PEC1PEC2PEC3PEC4....
                                                CNVOUT_Psum2_PEL[psumrow] = CNVOUT_Psum2_PEL[psumrow] + ((str(hex(int(CNVOUT_Psum2[psumrow],2))).lstrip('0x')).rstrip('L')).zfill(92);
                                                CNVOUT_Psum1_PEL[psumrow] = CNVOUT_Psum1_PEL[psumrow] + ((str(hex(int(CNVOUT_Psum1[psumrow],2))).lstrip('0x')).rstrip('L')).zfill(92);
                                                if psumrow >= 2:
                                                    CNVOUT_Psum0_PEL[psumrow-2] = CNVOUT_Psum0_PEL[psumrow-2] + ((str(hex(int(CNVOUT_Psum0[psumrow-2],2))).lstrip('0x')).rstrip('L')).zfill(92);

                                                #print(psumrow)
                                                #print(CNVOUT_Psum0_PEL)
                                                if psumrow >= 2 :  # 14rows

                                                    PECRAM_DatWr_PEL[psumrow-2] = PECRAM_DatWr_PEL[psumrow-2] + ((str(hex(int(PECRAM_DatWr[psumrow-2],2))).lstrip('0x')).rstrip('L')).zfill(81);
                                    # save first block then second block
                                    for psumrow in range(0, Len):
                                        #CNVOUT_Psum2_PEL[psumrow] = hex(int(CNVOUT_Psum2_PEL[psumrow],2))
                                        CNVOUT_Psum2File.write(str(CNVOUT_Psum2_PEL[psumrow]))
                                        CNVOUT_Psum2File.write('\n')

                                        #CNVOUT_Psum1_PEL[psumrow] = hex(int(CNVOUT_Psum1_PEL[psumrow],2))
                                        CNVOUT_Psum1File.write(str(CNVOUT_Psum1_PEL[psumrow]))
                                        CNVOUT_Psum1File.write('\n')
                                        if psumrow >= 2 :  # 14rows
                                            #print( CNVOUT_Psum0_PEL[psumrow-2])
                                            #CNVOUT_Psum0_PEL[psumrow-2] = hex(int(CNVOUT_Psum0_PEL[psumrow-2],2))
                                            CNVOUT_Psum0File.write(str(CNVOUT_Psum0_PEL[psumrow-2]))
                                            CNVOUT_Psum0File.write('\n')

                                            #PECRAM_DatWr_PEL[psumrow-2] = ((str(hex(int(PECRAM_DatWr_PEL[psumrow-2],2))).lstrip('0x')).rstrip('L')).zfill(81*NumPEC*NumPEB)
                                            PECRAM_DatWrFile.write(PECRAM_DatWr_PEL[psumrow-2]+'\n')


                                        


"""               for outrow in range (0, Len -2):
                                    for outcol in range (0, Len - 2 ):
                                        out[outrow][outcol] = acc[outrow  ][outcol][0] + acc[outrow  ][outcol+1][1] +  acc[outrow  ][outcol+2][2] + \
                                                              acc[outrow+1][outcol][3] + acc[outrow+1][outcol+1][4] +  acc[outrow+1][outcol+2][5] + \
                                                              acc[outrow+2][outcol][6] + acc[outrow+2][outcol+1][7] +  acc[outrow+2][outcol+2][8]
                                        PECRAM_DatWr[outrow] = PECRAM_DatWr[outrow] + '{:023b}'.format(out[outrow][outcol])
                                    PECRAM_DatWr[outrow] = hex(int(PECRAM_DatWr[outrow],2))
"""

'''
with open (CNVOUT_Psum2FileName, 'w') as CNVOUT_Psum2File:
    for outrow in range (0, Len):
        CNVOUT_Psum2File.write(str(CNVOUT_Psum2[outrow]))
        CNVOUT_Psum2File.write('\n')
with open (CNVOUT_Psum1FileName, 'w') as CNVOUT_Psum1File:
    for outrow in range (0, Len):
        CNVOUT_Psum1File.write(str(CNVOUT_Psum1[outrow]))
        CNVOUT_Psum1File.write('\n')
with open (CNVOUT_Psum0FileName, 'w') as CNVOUT_Psum0File:
    for outrow in range (0, Len-2):
        CNVOUT_Psum0File.write(str(CNVOUT_Psum0[outrow]))
        CNVOUT_Psum0File.write('\n')
'''
'''with open (WrFileName, 'w') as WrFile:
    for outrow in range (0, Len - 2):
        WrFile.write(str(PECRAM_DatWr[outrow]))
        WrFile.write('\n')
        '''

"""                               for cnvrow in range (0, KerSize) :
                                    for psumrow in range(0, Len):
                                        for psumcol in range(0, Len):
                                            CNVOUT_PsumHEX[cnvrow][psumrow] = CNVOUT_PsumHEX[cnvrow][psumrow] + '{:023b}'.format(CNVOUT_Psum[cnvrow][psumrow][psumcol])
                                        CNVOUT_PsumHEX[cnvrow][psumrow] = hex(int(CNVOUT_PsumHEX[cnvrow][psumrow],2))
                                print(CNVOUT_Psum[2][0])
                                print(CNVOUT_PsumHEX[2][0])
                                print(hex(int('10111111',2)))
"""
                                
'''                                            for cnvrow in range (0, KerSize) :
                                                for psumrow in range(0, Len):
                                                    for psumcol in range(0, Len):
                                                        Mac0[2-cnvrow][psumrow][psumcol] = acc [psumrow][psumcol][0 + cnvrow*3];
                                                    for psumcol in range(1, Len):
                                                        Mac1[2-cnvrow][psumrow][psumcol] = Mac0[2-cnvrow][psumrow][psumcol-1] + acc[psumrow][psumcol][1+ cnvrow*3];
                                                    for psumcol in range(2, Len):
                                                        Mac2[2-cnvrow][psumrow][psumcol] = Mac1[2-cnvrow][psumrow][psumcol-1] + acc[psumrow][psumcol][2+ cnvrow*3];

                                            # for cnvrow in range(0, KerSize):
                                                # for psumrow in range(0, Len):
                                                #     for psumcol in range(0, Len):
                                                        # CNVOUT_Psum[2-cnvrow][psumrow][psumcol] =  Mac2[cnvrow][psumrow][psumcol] + CNVOUT_Psum[3-cnvrow];
                                            CNVOUT_Psum[2] =  Mac2[2];
                                            CNVOUT_Psum[1] =  Mac2[1] + CNVOUT_Psum[2];
                                            CNVOUT_Psum[0] =  Mac2[0] + CNVOUT_Psum[1];
'''