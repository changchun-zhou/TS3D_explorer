import numpy as np
import random
import os

row_index = 1024 # 32 x 9 x 3 x 16 / 9
line_index = 1 #  9 X 8bit
file_name = 'RAM_GBFACT.dat'
# param_type = 'WEI_/'
# flag_folder = 'FLAG_/'
# data_folder = 'DATA_/'

spar = ['75/']
for folder_name in range(0, 1):
    # folder_flag = '/workspace/home/zhoucc/S2CNN/test_CNNPR/src/Dat/' + param_type + flag_folder + spar[folder_name]
    # folder_data = '/workspace/home/zhoucc/S2CNN/test_CNNPR/src/Dat/' + param_type + data_folder + spar[folder_name]
    for cnt in range(0, 1):
        # file_flag = param_type[0: -1] + '_'  + flag_folder[0: -1] + '_' + str(cnt) + '.dat'
        # file_data = param_type[0: -1] + '_'  + data_folder[0: -1] + '_' + str(cnt) + '.dat'
        output_fm = [[]for i in range(row_index)]
        cnt = 0
        cnt_non_zero = 0
        # with open(folder_flag + file_flag, "r") as file:
        for rownum in range(0, row_index):
            # for line in file:
                #line = line.strip()
                #line = line.split(" ")
                for bit in range(0, line_index):
                    # if(line[bit] == '1'):
                    #     a = '1'
                    #     for i in range(0, 7):
                    #         i = random.randint(0, 1)
                    #         a = a + str(i)
                    #     output_fm[cnt].append(a)
                    #     cnt_non_zero = cnt_non_zero + 1
                    # elif(line[bit] == '0'):
                    #     output_fm[cnt].append('00000000')
                    #     cnt_non_zero = cnt_non_zero
                    normal = np.random.normal(0, 16, 1)
                    # print(normal)
                    j = normal.astype(int)
                    # print(j)
                    # for m in range (j)
                    # print(hex(j[0]))
                    if(j[0] < 0):
                        y = 256 + j[0]
                    else:
                        y = j[0]
                    print(y)
                    hexdat = hex(y)
                    strdat = str(hexdat)
                    # print(strdat)
                    hexdis = strdat.lstrip('0x')
                    hexdis = hexdis.rstrip('L')
                    hexdis = hexdis.zfill(2)
                    print(hexdis)
                    output_fm[cnt].append(hexdis)
                cnt = cnt + 1
        # if os.path.exists(folder_data):
        #     pass
        # else:
        #     os.mkdir(folder_data)
        # with open(folder_data + file_data, 'w') as file:
        with open(file_name, 'w') as file:
            for i in range(0, row_index):
                for k in range(0, line_index):
                    # for k in range(0, 1):
                    file.write(str(output_fm[i][k]))
                    # file.write(" ")
                file.write("\n")


# for folder_name in range(0, 6):
#     # folder = 'C:/Users/Administrator/Desktop/DNN/CNN_ACC_V1/1.Vcode/9.conv_test/1_BLOCK/PE_4/' + param_type + data_folder + spar[folder_name]
#     folder = 'C:/Users/Administrator/Desktop/DNN/CNN_ACC_V1/1.Vcode/9.conv_test/' + param_type + data_folder + spar[folder_name]
#     path = folder + param_type[0: -1] + '_'  + data_folder[0: -1] + '.dat'
#     if os.path.exists(path):
#         os.remove(path)
#     else:
#         print('no such file')
#     with open(path, 'a') as file_w:
#         new_line = ''
#         iteration = 0
#         for cnt in range(0, 32):
#             with open(folder + param_type[0: -1] + '_'  + data_folder[0: -1] + '_' + str(cnt) + '.dat', 'r') as file_r:
#                 for line in file_r:
#                     line = line.strip()
#                     line = line.split(' ')
#                     for word in line:
#                         if (word == '00000000'):
#                             pass
#                         else:
#                             if (iteration == 4):
#                                 file_w.write(new_line)
#                                 file_w.write('\n')
#                                 iteration = 1
#                                 new_line = word
#                             else:
#                                 new_line = new_line + word
#                                 iteration = iteration + 1
#                             # print(new_line)
