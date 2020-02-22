import numpy as np
from scipy import sparse
import random
import os
import binascii
NumBlk = 2
BIT_WIDTH  = 1
PATCH_LINE = 432 * NumBlk # one Blk's number of row 9 x 3 x 16  * NumBlk
PATCH_ROW  = 32 #number of every row
file_name_bin = 'RAM_GBFFLGACT_bin.dat'
file_name_hex = 'RAM_GBFFLGACT.dat'
# param_type = 'WEI_/'
# data_type = 'FLAG_/'


# spar = ['10/', '30/', '70/', '50/', '90/', '100/']
spar = ['75/']
# per = [0.1, 0.3, 0.7, 0.5, 0.9, 1]
per = [0.25]
for folder_name in range(0,1):
    # for cnt in range(0, 32):
    for cnt in range(0,1):
        c = sparse.rand(PATCH_LINE, PATCH_ROW, density=per[folder_name - 1], format='csc')
        b = (c.toarray())
        a = ''
        for i in b:
            for j in i:
                if (j == 0):
                    for n in range(0, BIT_WIDTH):
                        a = a + '0'
                else:
                    for i in range(0, BIT_WIDTH):
                        # a = a + str(random.randint(0, 1))
                        a = a + '1'
                # a = a + ' '
                # print(a)
            a = a + '\n'
        # file_name = param_type[0: -1] + '_'  + data_type[0: -1] + '_' + str(cnt) + '.dat'
        # folder = '/workspace/home/zhoucc/S2CNN/Project/TS3D/testbench/Data/' + param_type + data_type + spar[folder_name]
        # if os.path.exists(folder):
        #     pass
        # else:
        #     os.mkdir(folder)
        with open(file_name_bin, 'w') as file:
            file.write(a)
#  Transfer to HEX
fh = open(file_name_bin,'rb')
# size = os.path.getsize('RAM_GBFFLGWEI.dat')
for j in range (PATCH_LINE):
    for m in range (0,PATCH_ROW/8): # \n
        accu = 0
        for i in range (0,8): # 8 bit to 0x
            a = fh.read(1)
            if (a == '1'):
                accu = 2**(7-i) + accu
            # elif(a == '0'):
                # accu = accu
            elif( a == '\n'):
                a = fh.read(1) # read again
                if (a == '1'):
                    accu = 2**(7-i) + accu
                # elif(a == '0'):
                # accu = accu
        hexdat = hex(accu)
        strdat = str(hexdat)
        # print(strdat)
        hexdis = strdat.lstrip('0x')
        hexdis = hexdis.rstrip('L')
        hexdis = hexdis.zfill(2)
        with open(file_name_hex,'a') as file:
            file.write(str(hexdis))
    with open(file_name_hex,'a') as file:
        file.write('\n')


# for folder_name in range(0, 6):
#     folder = '/workspace/home/zhoucc/S2CNN/test_CNNPR/src/Dat/' + param_type + data_type + spar[folder_name]
#     path = folder + param_type[0: -1] + '_'  + data_type[0: -1] + '.dat'
#     if os.path.exists(path):
#         os.remove(path)
#     else:
#         print('no such file')
#     with open(path, 'a') as file_w:
#         for cnt in range(0, 32):
#             with open(folder + param_type[0: -1] + '_'  + data_type[0: -1] + '_' + str(cnt) + '.dat', 'r') as file_r:
#                 for line in file_r:
#                     line = line.strip()
#                     line = line.split(' ')
#                     # print(line)
#                     file_w.write(''.join(line))
#                     file_w.write('\n')
