import numpy as np
import random
import os

FlagActFileName = '../RAM_GBFFLGACT_bin.dat'
FlagWeiFileName = '../RAM_GBFFLGWEI.dat'
ActFileName = '../RAM_GBFACT.dat'
WeiFileName = '../RAM_GBFWEI.dat'
WrFileName = 'GenPECRAM_DatWr.dat'
CNVOUT_Psum2FileName = 'CNVOUT_Psum2.dat'
CNVOUT_Psum1FileName = 'CNVOUT_Psum1.dat'
CNVOUT_Psum0FileName = 'CNVOUT_Psum0.dat'
NumChn = 32
NumWei = 9
NumBlk = 2
Len = 16
KerSize = 3
# PSUM_WIDTH = 23
actchn = [ 0 for x in range (0,NumChn)]
weichn = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]
acc = [ [ [0 for x in range (0,NumWei)] for y in range(0, Len)] for z in range(0, Len)]
PECRAM_DatWr = ['' for x in range ( 0, Len - 2)]
CNVOUT_Psum2 = ['' for x in range ( 0, Len )]
CNVOUT_Psum1 = ['' for x in range ( 0, Len )]
CNVOUT_Psum0 = ['' for x in range ( 0, Len )]
CNVOUT_PsumHEX = [['' for x in range ( 0, Len )] for y in range(0, KerSize)]
Psum2 = [ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]
Psum1 = [ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]
Psum0 = [ [ 0 for x in range (0,Len -2)] for y in range(0, Len) ]
Mac0 = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
Mac1 = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
Mac2 = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
CNVOUT_Psum = [[ [ 0 for x in range (0,Len )] for y in range(0, Len) ] for z in range(0, KerSize)]
flagweichn = [ [ 0 for x in range (0,NumChn)] for y in range(0, NumWei) ]

# acc = [ [0 for x in range (0,NumWei)] for y in range(0, Len*Len)]
# acc = [ [ [[0] * NumWei] * Len ] * Len ]
out = [ [ 0 for x in range (0,Len -2)] for y in range(0, Len -2) ]
cnt = 0
# def int2hex (dat_int, width):
#     dat_hex = '{:0widthb}'.format(dat_int)
#     return dat_hex
with open(FlagActFileName, 'r') as FlagActFile:
    with open(FlagWeiFileName, 'r') as FlagWeiFile:
        with open(ActFileName, 'r') as ActFile:
            with open(WeiFileName, 'r') as WeiFile:
                #for cntfrm in range(0,)
                for cntblk in range (0, NumBlk ):
                    for j in range (0, NumWei) :
                        flagweichn[j] = FlagWeiFile.read(NumChn)
                        FlagWeiFile.read(1)
                    for j in range (0, NumWei) :
                        for k in range (0, NumChn):
                            if flagweichn[j][NumChn-1-k] == '1':
                                if cnt == 9 :
                                    WeiFile.read(1)
                                    cnt = 1
                                else :
                                    cnt = cnt + 1
                                wei = WeiFile.read(2)
                            else :
                                wei = 0
                            weichn[NumWei-1-j][k] = wei
                         
                    for actrow in range(0, Len) : 
                        for actcol in range(0, Len):
                            flagactchn  = FlagActFile.read(32)
                            FlagActFile.read(1)
                            for i in range (0, NumChn): 
                                if flagactchn[NumChn-1-i] == '1' :
                                    act = ActFile.read(2)
                                    ActFile.read(1)
                                    if act == '':
                                        print('error')
                                else :
                                    act = 0
                            # transfer to not sparsity: one demensional row
                                actchn[i] = act
                            # print(actchn)
                            for j in range(0, NumWei):
                                for m in range (0, NumChn):
                                    # print(type(actchn[m]))
                                    acc[actrow][actcol][j] = acc[actrow][actcol][j] + int(str(actchn[m]),16) * int(str(weichn[j][m]),16)
                                # if actrow == 0 and j == 0:
                                    # print(acc[actrow][actcol][j])
                            # if actrow ==0 and actcol < 3 :
                                # print('actchn')
                                # print(actchn)
                    # print('actwei:')
                    # print(weichn[0])
                    # print('acc')
                    # print(acc[0][0][0]) # correct

                    # print(weichn[0])
                    # print(weichn[1])
                    # print(weichn[2])
                    for cnvrow in range (0, KerSize) :
                        for psumrow in range(0, Len):
                            for psumcol in range(0, Len):
                                Mac0[2-cnvrow][psumrow][psumcol] = acc [psumrow][psumcol][0 + cnvrow*3];
                            for psumcol in range(1, Len):
                                Mac1[2-cnvrow][psumrow][psumcol] = Mac0[2-cnvrow][psumrow][psumcol-1] + acc[psumrow][psumcol][1+ cnvrow*3];
                            for psumcol in range(2, Len):
                                Mac2[2-cnvrow][psumrow][psumcol] = Mac1[2-cnvrow][psumrow][psumcol-1] + acc[psumrow][psumcol][2+ cnvrow*3];

                    # print(Mac0[1][0])
                    # print(Mac1[1][0])
                    # print(Mac2[1][0])

                    # for cnvrow in range(0, KerSize):
                        # for psumrow in range(0, Len):
                        #     for psumcol in range(0, Len):
                                # CNVOUT_Psum[2-cnvrow][psumrow][psumcol] =  Mac2[cnvrow][psumrow][psumcol] + CNVOUT_Psum[3-cnvrow];
                    CNVOUT_Psum[2] =  Mac2[2];
                    CNVOUT_Psum[1] =  Mac2[1] + CNVOUT_Psum[2];
                    CNVOUT_Psum[0] =  Mac2[0] + CNVOUT_Psum[1];
                    for cnvrow in range (0, KerSize) :
                        for psumrow in range(0, Len):
                            for psumcol in range(0, Len):
                                CNVOUT_PsumHEX[cnvrow][psumrow] = CNVOUT_PsumHEX[cnvrow][psumrow] + '{:023b}'.format(CNVOUT_Psum[cnvrow][psumrow][psumcol])
                            CNVOUT_PsumHEX[cnvrow][psumrow] = hex(int(CNVOUT_PsumHEX[cnvrow][psumrow],2))
                    print(CNVOUT_Psum[2][0])
                    print(CNVOUT_PsumHEX[2][0])
                    print(hex(int('10111111',2)))
                    for psumrow in range(0, Len):
                        for psumcol in range(0, Len-2):
                            Psum2[psumrow][psumcol] = acc[psumrow][psumcol][0] + acc[psumrow][psumcol+1][1] + acc[psumrow][psumcol+2][2];
                            if psumrow == 0 :
                                Psum1[psumrow][psumcol] = acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5];
                            else :
                                Psum1[psumrow][psumcol] = acc[psumrow][psumcol][3] + acc[psumrow][psumcol+1][4] + acc[psumrow][psumcol+2][5] + Psum2[psumrow -1][psumcol];
                            if psumrow == 0 :
                                Psum0[psumrow][psumcol] = acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8];
                            else :
                                Psum0[psumrow][psumcol] = acc[psumrow][psumcol][6] + acc[psumrow][psumcol+1][7] + acc[psumrow][psumcol+2][8] + Psum1[psumrow -1][psumcol];
                            CNVOUT_Psum2[psumrow] = CNVOUT_Psum2[psumrow] + '{:023b}'.format(Psum2[psumrow][psumcol])
                            CNVOUT_Psum1[psumrow] = CNVOUT_Psum1[psumrow] + '{:023b}'.format(Psum1[psumrow][psumcol])
                            if psumrow < Len-2 :  # 14rows
                                CNVOUT_Psum0[psumrow] = CNVOUT_Psum0[psumrow] + '{:023b}'.format(Psum0[psumrow][psumcol])
                        CNVOUT_Psum2[psumrow] = hex(int(CNVOUT_Psum2[psumrow],2))
                        CNVOUT_Psum1[psumrow] = hex(int(CNVOUT_Psum1[psumrow],2))
                        if psumrow < Len-2 :  # 14rows
                            CNVOUT_Psum0[psumrow] = hex(int(CNVOUT_Psum0[psumrow],2))
     '''               for outrow in range (0, Len -2):
                        for outcol in range (0, Len - 2 ):
                            out[outrow][outcol] = acc[outrow  ][outcol][0] + acc[outrow  ][outcol+1][1] +  acc[outrow  ][outcol+2][2] + \
                                                  acc[outrow+1][outcol][3] + acc[outrow+1][outcol+1][4] +  acc[outrow+1][outcol+2][5] + \
                                                  acc[outrow+2][outcol][6] + acc[outrow+2][outcol+1][7] +  acc[outrow+2][outcol+2][8]
                            PECRAM_DatWr[outrow] = PECRAM_DatWr[outrow] + '{:023b}'.format(out[outrow][outcol])
                        PECRAM_DatWr[outrow] = hex(int(PECRAM_DatWr[outrow],2))
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

with open (WrFileName, 'w') as WrFile:
    for outrow in range (0, Len - 2):
        WrFile.write(str(PECRAM_DatWr[outrow]))
        WrFile.write('\n')


