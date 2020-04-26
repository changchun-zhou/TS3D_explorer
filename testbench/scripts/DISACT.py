import numpy as np
import random
import os

def DISACT( cntPat, actrow, actcol,
            actBlk, FlgAct_hex, cnt_Flag_hex, cnt_GBFFLGACT, GBFFLGACT, cntPat_last, cnt_GBFACT, cntPat_last_GBFACT, cnt_act_col, cntActError,DDR_ADDR,
            FlagActFile, GBFFLGACT_DatWrFile, PECMAC_FlgActFile, ActFile, GBFACT_DatWrFile, PECMAC_ActFile,GBFFLGACT_PatchAddrFile,GBFACT_PatchAddrFile,PECMAC_FLGACT_PatchAddrFile,
            Len, NumChn ):
    #actBlk = [[[ 0 for x in range (0,NumChn)] for y in range (0,Len)] for z in range(0,Len)]
    PECMAC_Act = ''
    #PECMAC_FlgAct  = FlagActFile.read(NumChn) # == DISACT_FlgAct
    # *************************************************************************
    if cnt_Flag_hex == 0:
        FlgAct_hex = FlagActFile.readline().rstrip('\n') # 12B
    PECMAC_FlgAct_hex = FlgAct_hex[8*(cnt_Flag_hex):8*(cnt_Flag_hex)+8] #4B
    PECMAC_FlgAct = int(PECMAC_FlgAct_hex,16)
    PECMAC_FlgAct = str(bin(PECMAC_FlgAct)).lstrip('0b').zfill(NumChn)

    # ****************************
    
    cnt_GBFFLGACT += 1 #4B
    if cnt_GBFFLGACT % 3 == 1 and cnt_GBFFLGACT != 1:  
        GBFFLGACT_DatWrFile.write(GBFFLGACT + '\n' )
        GBFFLGACT = ""
    else:
        if cntPat != cntPat_last and cntPat_last != -1:
            
            if cnt_GBFFLGACT % 3 == 0: # current data is third of last patch line
                GBFFLGACT += "xx"*4
                cnt_GBFFLGACT += 1 #Mean: is first of new line
            elif cnt_GBFFLGACT% 3 == 2:
                GBFFLGACT += "xx"*8
                cnt_GBFFLGACT += 2 #Mean: is first of new line
            GBFFLGACT_DatWrFile.write(GBFFLGACT + '\n' )
            GBFFLGACT = ""
    if cntPat != cntPat_last: # complete the current line
        print("GBFFLGACT_DatWr next patch line:", cnt_GBFFLGACT/3) # Addr ( 0 begin)
        print("PECMAC_FlgAct next patch line:", cnt_GBFFLGACT -1) # Addr ( 0 begin)
        GBFFLGACT_PatchAddrFile.write( str(hex(cnt_GBFFLGACT/3)).lstrip('0x').rstrip('L').zfill(8) +'\n')
        PECMAC_FLGACT_PatchAddrFile.write( str(hex(cnt_GBFFLGACT -1)).lstrip('0x').rstrip('L').zfill(8) +'\n')
        DDR_ADDR[2][cntPat] = (cnt_GBFFLGACT - 1)*4 #begin addr
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
            elif cntPat != cntPat_last_GBFACT and cntPat_last_GBFACT != -1: # complete the current line
                
                if cnt_GBFACT % 12 == 0:
                    Zero = "xx"*( 1) 
                    cnt_GBFACT += 1
                else:
                    Zero = "xx"*( 13 - cnt_GBFACT % 12) 
                    cnt_GBFACT +=  13 - cnt_GBFACT % 12
                GBFACT_DatWrFile.write(Zero+'\n')# turn to next line
            if cntPat != cntPat_last_GBFACT: # complete the current line
                print("GBFACT_DatWr next patch line:", cnt_GBFACT/12) # Addr ( 0 begin)
                GBFACT_PatchAddrFile.write( str(hex(cnt_GBFACT/12)).lstrip('0x').rstrip('L').zfill(8) +'\n')
                DDR_ADDR[3][cntPat] = cnt_GBFACT -1
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
                print('error:',cntPat,actrow,actcol)
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

    return  actBlk, FlgAct_hex, cnt_Flag_hex, cnt_GBFFLGACT, GBFFLGACT, cntPat_last, cnt_GBFACT, cntPat_last_GBFACT, cnt_act_col, cntActError,DDR_ADDR