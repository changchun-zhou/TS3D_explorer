# ***********************************************************************
# statistic weight
# ***********************************************************************
import matplotlib.pyplot as plt 
import pandas as pd
import heapq
def Statistic( actBlk, PECMAC_Wei, 
         Len, NumFtrGrp, NumBlk, NumWei, NumChn, NumPEB, NumPEC, cntfrm,cntBlk, cntPEB,cntPEC ):
    NumFtr = NumFtrGrp*NumPEB
    CntWeiNotZero_FtrGrp = [ 0 for x in range(NumFtr)]
    CntWeiNotZero_FtrGrp_Sort = [ 0 for x in range(NumFtr)]
    Statistic_CntWeiNotZero = [[[[0 for x in range(NumFtr)]
                                    for y in range(NumWei)]
                                    for z in range(NumPEC)]
                                    for m in range(NumBlk)]
    Statistic_CntWeiNotZero_Filter = [[[[0
                                    for y in range(NumWei)]
                                    for z in range(NumPEC)]
                                    for m in range(NumBlk)]
                                    for x in range(NumFtr)]
    Statistic_CntPsumNotZero= [[[[0 for x in range(NumFtr)]
                                    for y in range(NumWei)]
                                    for z in range(NumPEC)]
                                    for m in range(NumBlk)]
    Statistic_CntPsumNotZero_PEB= [[[0 for o in range(Len)]
                                    for x in range(NumFtr)]
                                    for m in range(NumBlk)]
    PECMAC_Wei_Sort =       [[[[[[ 0 for x in range(NumChn)]
                                    for y in range(NumWei)]
                                    for z in range(NumPEC)]
                                    for m in range(NumPEB)]
                                    for n in range(NumBlk)]
                                    for o in range(NumFtrGrp)]
    color = [['lightsteelblue','blue','navy',    
            'springgreen','lime','forestgreen',
            'orchid','m','purple'], #block
            ['salmon','tomato','lightcoral',
             'indianred','red','firebrick',
             'maroon','darkred','crimson']]
    bar_width = 0.3
    Theshold = 5
    bottom = [0 for x in range(NumFtr)];
    # sort PECMAC_Wei
    for cntFtrGrp in range(NumFtrGrp):
        for cntBlk in range(NumBlk):
            for cntPEB in range(NumPEB):
                for cntPEC in range(NumPEC):
                    for cntwei in range(NumWei):
                        for cntchn in range(NumChn):
                            if PECMAC_Wei[cntFtrGrp][cntBlk][cntPEB][cntPEC][cntwei][cntchn] !=0:
                                CntWeiNotZero_FtrGrp[cntPEB + NumPEB*cntFtrGrp] += 1
    CntWeiNotZero_FtrGrp_Sort = heapq.nsmallest(NumFtr,CntWeiNotZero_FtrGrp)
    print("CntWeiNotZero_FtrGrp_Sort",CntWeiNotZero_FtrGrp_Sort)
    CntWeiNotZero_FtrGrp_Sort_index = list(map(CntWeiNotZero_FtrGrp.index, CntWeiNotZero_FtrGrp_Sort))
    print("CntWeiNotZero_FtrGrp_Sort_index", CntWeiNotZero_FtrGrp_Sort_index)
    for cntFtrGrp in range(NumFtrGrp):
        for cntBlk in range(NumBlk):
            for cntPEB in range(NumPEB):
                cntFtr = cntPEB + NumPEB*cntFtrGrp
                PECMAC_Wei_Sort[cntFtrGrp][cntBlk][cntPEB] = \
                PECMAC_Wei[CntWeiNotZero_FtrGrp_Sort_index[cntFtr]//NumPEB][cntBlk][CntWeiNotZero_FtrGrp_Sort_index[cntFtr]%NumPEB]
    for cntFtrGrp in range(NumFtrGrp):
        for cntPEB in range(NumPEB):
            # Statistic_CntFtrNotZero[cntFtrGrp*cntPEB] = 0;
            for cntBlk in range(NumBlk):
                # Statistic_CntBlkNotZero = 0;
                for actrow in range(Len):
                    for actcol in range(Len):

                        for cntPEC in range(NumPEC):
                            # Statistic_CntPECNotZero = 0;
                            for cntwei in range(NumWei):

                                for cntchn in range(NumChn):
                   
                                    if PECMAC_Wei_Sort[cntFtrGrp][cntBlk][cntPEB][cntPEC][cntwei][cntchn] !=0 and \
                                       ( actBlk[1][1][cntBlk][actrow][actcol][cntchn] > Theshold or \
                                         actBlk[1][1][cntBlk][actrow][actcol][cntchn] < -Theshold):

                                        # Statistic_CntFtrNotZero[cntFtrGrp*cntPEB] += 1;
                                        # Statistic_CntBlkNotZero[cntFtrGrp*cntPEB][cntBlk] += 1;
                                        # Statistic_CntPECNotZero[cntFtrGrp*cntPEB][cntBlk][cntPEC] += 1;
                                        Statistic_CntPsumNotZero[cntBlk][cntPEC][cntwei][cntFtrGrp*NumPEB + cntPEB] += 1;
                                        Statistic_CntPsumNotZero_PEB[cntBlk][cntFtrGrp*NumPEB + cntPEB][actrow] += 1;
                            if PECMAC_Wei_Sort[cntFtrGrp][cntBlk][cntPEB][cntPEC][cntwei][cntchn] != 0:
                                Statistic_CntWeiNotZero[cntBlk][cntPEC][cntwei][cntFtrGrp*NumPEB + cntPEB] += 1;
                                Statistic_CntWeiNotZero_Filter[cntFtrGrp*NumPEB + cntPEB][cntBlk][cntPEC][cntwei] += 1;
                        # if cntBlk == 0:
                        #     plt.bar(x=cntwei+( cntPEB*NumPEC+cntPEC)*NumWei, height =Statistic_CntPsumNotZero[cntBlk][cntPEC][cntwei][cntFtrGrp*NumPEB + cntPEB]
                        #     , bottom =0, label='Blk:'+str(cntBlk)+';PEC:'+str(cntPEC)+';Wei:'+str(cntwei) ,color=color[0][cntwei],width=bar_width);             
                        # else:
                        #     plt.bar(x=cntwei+( cntPEB*NumPEC+cntPEC)*NumWei, height =Statistic_CntPsumNotZero[cntBlk][cntPEC][cntwei][cntFtrGrp*NumPEB + cntPEB]
                        #     , bottom =Statistic_CntPsumNotZero[cntBlk-1][cntPEC][cntwei][cntFtrGrp*NumPEB + cntPEB], label='Blk:'+str(cntBlk)+';PEC:'+str(cntPEC)+';Wei:'+str(cntwei) ,color=color[cntBlk][cntwei],width=bar_width);             
                    plt.bar(x=cntPEB + NumPEB*cntFtrGrp, height =Statistic_CntPsumNotZero_PEB[cntBlk][cntFtrGrp*NumPEB + cntPEB][actrow]
                    , bottom =bottom[cntPEB + NumPEB*cntFtrGrp],color=color[0][actrow%9],width=bar_width);             
                    bottom[cntPEB + NumPEB*cntFtrGrp] += Statistic_CntPsumNotZero_PEB[cntBlk][cntFtrGrp*NumPEB + cntPEB][actrow]
    # ******** Psum Bar *****************



    # # plt.bar(x=range(NumFtrGrp*NumPEB), height =Statistic_CntFtrNotZero, label='NumberZero of Filter',color='steelblue',width=bar_width)
    # # plt.bar(x=range(NumFtrGrp*NumPEB), height =Statistic_CntFtrNotZero, label='NumberZero of Filter',color='steelblue',width=bar_width)

    # bottom_psum = [0 for x in range(NumFtr)];
   
    # for cntBlk in range(1):
    #     for cntPEC in range(1):
    #         for cntwei in range(NumWei):
    #             plt.bar(x=np.arange(NumFtr), height =np.array(Statistic_CntWeiNotZero[cntBlk][cntPEC][cntwei])
    #                 , bottom =bottom, label='Blk:'+str(cntBlk)+';PEC:'+str(cntPEC)+';Wei:'+str(cntwei) ,color=color[cntBlk][cntwei],width=bar_width);
    #             bottom = np.array(bottom) + np.array(Statistic_CntWeiNotZero[cntBlk][cntPEC][cntwei])

    #             plt.bar(x=np.arange(NumFtr)+bar_width, height =np.array(Statistic_CntPsumNotZero[cntBlk][cntPEC][cntwei])/100
    #                 , bottom =bottom_psum, label='Blk:'+str(cntBlk)+';PEC:'+str(cntPEC)+';Wei:'+str(cntwei) ,color=color[cntBlk][cntwei],width=bar_width);
    #             bottom_psum = np.array(bottom_psum) + np.array(Statistic_CntPsumNotZero[cntBlk][cntPEC][cntwei])/100

    # plt.xticks(np.arange(0,NumFtr,5),np.arange(0,NumFtr,5), rotation=60, fontsize=10)
    plt.savefig('Statistic_psum_PEB_16row_2blk_patch1.jpg')
    print('*'*8 +'Finish Statistic'+'*'*8)
    # End Statistic 
    # *****************************************************

    # *****************************
    # 3D figure
    # fig = plt.figure()
    # plt_3d = fig.add_subplot(111,projection='3d')
    # color_array = ['r','g','b','k']
    # for x in range(Len):
    #     for y in range(Len):
    #         for z in range(NumChn): # Only analysis one Block of delta frame
    #             if actBlk[0][1][0][x][y][z] > 5 or actBlk[0][1][0][x][y][z] < -5:
    #                 plt_3d.scatter(x,y,z,c=color_array[z%4],alpha=0.4, marker='s')#c ,marker, totation,     
    # plt_3d.view_init(elev=0, azim = 0)
    # plt.savefig("Visual_IFM_Block_3D.jpg",dpi=8000)

    # 2D figure
    # fig = plt.figure()
    # for z in range(NumChn): # Only analysis one Block of delta frame
    #     plt_2d = fig.add_subplot(4,8,z+1)
    #     for x in range(Len):
    #         for y in range(Len):
    #             if actBlk[0][1][0][x][y][z] > 5 or actBlk[0][1][0][x][y][z] < -5:
    #                 plt_2d.scatter(x,y, c='b',marker='s')#c ,marker, totation,
    # # plt.savefig("Visual_IFM_channel_2D_"+str(z)+".jpg",dpi=300)
    # plt.savefig("Visual_IFM_channel_2D.jpg",dpi=800)

    # print('*'*8 +'Finish Visual'+'*'*8)
    # # *********************************************************

    # *************************************************************

    # Get Addition Config for every Wei of 1 PEB
    # CfgWei[PEC][Wei][config:help:1/helped:0,begin Addr,help_whichPEC,help_whichWei
    
    NumHelp = 9
    Theshold_Help = 2
    Largest9cnt = [0 for x in range(NumHelp)]
    Smallest9cnt = [0 for x in range(NumHelp)]
    CfgWei = [[[ 0 for x in range(4)]
                 for y in range(NumWei)]
                 for z in range(NumPEC)]
    Largest9Index = [ 0 for z in range(NumHelp)]
    Smallest9Index = [0 for z in range(NumHelp)]
    Statistic_CntWeiNotZero_CurFilter = [ 0 for x in range(NumWei*NumPEC)]
    print(NumPEC, NumWei)
    for cntPEC in range(NumPEC):# to 1 D array
        for cntwei in range(NumWei):
                Statistic_CntWeiNotZero_CurFilter[cntwei+cntPEC*NumWei] = Statistic_CntWeiNotZero_Filter[0][0][cntPEC][cntwei]
    print(Statistic_CntWeiNotZero_CurFilter)
    Largest9cnt = heapq.nlargest(9,Statistic_CntWeiNotZero_CurFilter)
    Smallest9cnt= heapq.nsmallest(9,Statistic_CntWeiNotZero_CurFilter)
    print("Statistic_CntWeiNotZero_Filter[0][0]")
    print(Statistic_CntWeiNotZero_Filter[0][0])
    print("Statistic_CntWeiNotZero_Filter[1][0]")
    print(Statistic_CntWeiNotZero_Filter[1][0])
    print("Statistic_CntWeiNotZero_Filter[2][0]")
    print(Statistic_CntWeiNotZero_Filter[2][0])

    print("Largest9cnt")
    print(Largest9cnt)
    print("Smallest9cnt")
    print(Smallest9cnt)

    Largest9Index = list(map(Statistic_CntWeiNotZero_CurFilter.index, Largest9cnt))
    Smallest9Index = list(map(Statistic_CntWeiNotZero_CurFilter.index, Smallest9cnt))
    print(Largest9Index)
    print(Smallest9Index)
    for cnthelp in range(NumHelp):
        if Largest9cnt[cnthelp] - Smallest9cnt[cnthelp] >= Theshold_Help:
            [L_PEC,L_Wei]= [Largest9Index[cnthelp]//NumWei, Largest9Index[cnthelp]%NumWei]
            CountHelp = (Largest9cnt[cnthelp] - Smallest9cnt[cnthelp])//2
            countNotZero = 0
            for cntchn in range(NumChn):
                if countNotZero == CountHelp:
                    AddrHelp = cntchn
                if PECMAC_Wei[0][0][0][L_PEC][L_Wei][cntchn] != 0:
                    countNotZero += 1

            print("L_PEC L_Wei")
            print(L_PEC,L_Wei)
            CfgWei[L_PEC][L_Wei] = [0,AddrHelp,0,0] # Error: is Addr not count
            [S_PEC,S_Wei]= [Smallest9Index[cnthelp]//NumWei, Smallest9Index[cnthelp]%NumWei]
            CfgWei[S_PEC][S_Wei] = [1,AddrHelp,L_PEC,L_Wei] 
    print("Help config:",CfgWei)  
    TotalClk = 0
    TotalClk_worst = 0
    Theshold = 5

    CurCntPsum_best = 0
    for actrow in range(Len):
        for actcol in range(Len):
            MaxCntPsum = 0
            MaxCntPsum_worst = 0

            for cntPEC in range(NumPEC):
                for cntwei in range(NumWei):
                    CurCntPsum = 0
                    
                    CurCntPsum_worst = 0
                    if CfgWei[cntPEC][cntwei][0] == 0:
                        for cntchn in range(CfgWei[cntPEC][cntwei][1]+10,NumChn):
                            if PECMAC_Wei[0][0][0][cntPEC][cntwei][cntchn] !=0 and \
                               ( actBlk[0][1][0][actrow][actcol][cntchn]  > Theshold or actBlk[0][1][0][actrow][actcol][cntchn] < -Theshold):
                                CurCntPsum += 1
                    # elif CfgWei[cntPEC][cntwei][0] == 1:
                    #     for cntchn in range(NumChn):# self
                    #         if PECMAC_Wei[0][0][0][cntPEC][cntwei][cntchn] != 0 and  \
                    #            ( actBlk[0][1][0][actrow][actcol][cntchn]  > Theshold or actBlk[0][1][0][actrow][actcol][cntchn] < -Theshold):
                    #            CurCntPsum += 1
                    #     for cntchn in range(CfgWei[cntPEC][cntwei][1]):#help
                    #         if PECMAC_Wei[0][0][0][CfgWei[cntPEC][cntwei][2]][CfgWei[cntPEC][cntwei][3]][cntchn] != 0 and  \
                    #            ( actBlk[0][1][0][actrow][actcol][cntchn]  > Theshold or actBlk[0][1][0][actrow][actcol][cntchn] < -Theshold):
                    #            CurCntPsum += 1

                    # else:
                    #     print('<'*8+' Error Help/Helped '+'>'*8)
                    if CurCntPsum > MaxCntPsum :
                        MaxCntPsum = CurCntPsum
                    # ****************************************
                    for cntchn in range(NumChn):
                        if PECMAC_Wei[0][0][0][cntPEC][cntwei][cntchn] !=0 and \
                        ( actBlk[0][1][0][actrow][actcol][cntchn]  > Theshold or actBlk[0][1][0][actrow][actcol][cntchn] < -Theshold):
                            CurCntPsum_worst += 1
                            CurCntPsum_best += 1
                    if CurCntPsum_worst > MaxCntPsum_worst :
                        MaxCntPsum_worst = CurCntPsum_worst


            TotalClk += MaxCntPsum
            TotalClk_worst += MaxCntPsum_worst
    print("TotalClk: "+str(TotalClk))
    print("TotalClk_worst: "+str(TotalClk_worst))
    print("TotalClk_best :", CurCntPsum_best/(NumPEC*NumWei))
    print("Short percentage :"+str(float(TotalClk_worst - TotalClk)/TotalClk_worst*100)+ "%")

    return
