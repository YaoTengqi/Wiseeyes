import numpy as np
import pickle
import torch

def read_origin_ouput(path,save_path):
    data = np.load(path)
    data = data.transpose(0, 2, 3, 1)
    print(data.shape)
    with open(save_path, 'w') as f:
        for i in range(data.shape[1]):
            for j in range(data.shape[2]):
                f.writelines("(0," + str(i) + "," + str(j) + ')' + "  " + str(data[0][i][j][:]) + "\n")

def read_run_result(key_index,save_path):
    data_result = open('../sim/test_yolo_demo/result.pickle', 'rb')
    data = pickle.load(data_result)
    keys = list(data.keys())
    for i in range(len(keys)):
        print(str(i) + " " + keys[i])
    data = data[keys[key_index]][0]
    with open(save_path, 'w') as f:
        for i in range(data.shape[1]):
            for j in range(data.shape[2]):
                f.writelines("(0,"+str(i)+","+str(j)+')'+"  "+str(data[0][i][j][:])+"\n")

def compare_difference(origin_path,key_index):
    data = np.load(origin_path)
    data = data.transpose(0, 2, 3, 1)
    # print(data.shape)

    data_result = open('../sim/test_yolo_demo/result_face_det.pickle', 'rb')
    data_r = pickle.load(data_result)
    keys = list(data_r.keys())
    for i in range(len(keys)):
        print(str(i) + " " + keys[i])

    # print((((np.sqrt(np.mean(((data[:,:,:,int(data.shape[-1]/2):] - data_r[keys[k]][0])** 2))) / (data.max() - data.min()) * 100))))

    # comp = data_r[keys[k]][0]
    # with open('conv16_compare', 'w') as f:
    #     for i in range(comp.shape[1]):
    #         for j in range(comp.shape[2]):
    #             f.writelines("(0," + str(i) + "," + str(j) + ')' + "  " + str(comp[0][i][j][:]) + "\n")
    #             print(comp[0][i][j][:])
    #             print("\n")
    # print(data_r[keys[key_index]][0])
    print((((np.sqrt(np.mean(((data - data_r[keys[key_index]][0]) ** 2))) / (data.max() - data.min()) * 100))))

def compare_conv_1(input_type="cpu",output_type="cpu"):
    data_result = open('../sim/test_yolo_demo/result.pickle', 'rb')
    data_r = pickle.load(data_result)
    keys = list(data_r.keys())

    if input_type=="cpu":
        # data = np.load('/home/zhangyuling/Documents/compile/output_quant_FD(1)/output/conv_13.npy')
        data = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_128x128_1202/1202/output/conv_13.npy')
        data = data.transpose(0, 2, 3, 1)
        # print(data.shape)
    else:
        for i in range(len(keys)):
            print(str(i) + " " + keys[i])
        data = data_r[keys[24]][0]

    if output_type == "cpu":
        # data_right = np.load('/home/zhangyuling/Documents/compile/output_quant_FD(1)/output/FPN_conv_1x1_1.npy')
        data_right = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_128x128_1202/1202/output/FPN_conv_1x1_1.npy')
        data_right = data_right.transpose(0, 2, 3, 1)
    else:
        data_right = data_r[keys[28]][0]
        # print(data_conv)

    #get scale
    weight_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_weight_scale.npy'))
    data_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_input_scale.npy'))

    data_w_r = open('../sim/test_yolo_demo/weights/face_det_dnn_int8.pickle', 'rb')
    data_w_r = pickle.load(data_w_r)

    data_w = data_w_r['conv15/Convolution']['weights']
    data_b = data_w_r['conv15/Convolution']['bias']
    # print(data_b)

    data_conv = np.zeros((1, data_right.shape[1], data_right.shape[2], data_right.shape[3]))


    po = 15
    for i in range(data_right.shape[3]):
        for j in range(data_right.shape[1]):
            for k in range(data_right.shape[2]):
                # print(data[0][j][k][:])
                # print(data_w[i][0][0][:]*s)
                data_conv[0][j][k][i] = max(0, np.sum(
                    np.multiply(data[0][j][k][:], data_w[i][0][0][:] * weight_scale[15])) + data_b[i] * data_scale[14] *
                                            weight_scale[15])
                # data_conv[0][j][k][i]=max(0,np.sum(np.multiply(data[0][j][k][:],data_w[i][0][0][:]*weight_scale[15]))+data_b[i]*data_scale[16]*weight_scale[15])

    # print(data_conv - data_right)
    print((((np.sqrt(np.mean(((data_conv - data_right) ** 2))) / (data_conv.max() - data_conv.min()) * 100))))

    # print(data_conv-data_right)
    # with open('conv16_manual_pre_32_noRelu', 'w') as f:
    #     for i in range(data_conv.shape[1]):
    #         for j in range(data_conv.shape[2]):
    #             f.writelines("(0," + str(i) + "," + str(j) + ')' + "  " + str(data_conv[0][i][j][:]) + "\n")

def compare_conv_3(input_type="cpu", output_type="cpu"):
    data_result = open('../sim/test_yolo_demo/result.pickle', 'rb')
    data_r = pickle.load(data_result)
    keys = list(data_r.keys())

    for i in range(len(keys)):
        print(str(i) + " " + keys[i])

    if input_type == "cpu":
        data = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_128x128_1202/1202/output/SSH_1_5x5_1.npy')
        data = data.transpose(0, 2, 3, 1)
        # print(data.shape)
    else:
        data = data_r[keys[40]][0]
    data = np.pad(data, ((0, 0), (1, 1), (1, 1), (0, 0)), 'constant', constant_values=(0, 0))

    if output_type == "cpu":
        # data_right = np.load('/home/zhangyuling/Documents/compile/output_quant_FD(1)/output/FPN_conv_1x1_1.npy')
        data_right = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_128x128_1202/1202/output/SSH_1_5x5_2.npy')
        data_right = data_right.transpose(0, 2, 3, 1)
    else:
        data_right = data_r[keys[41]][0]
        # print(data_conv)

    # get scale
    weight_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_weight_scale.npy'))
    data_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_input_scale.npy'))

    data_w_r = open('../sim/test_yolo_demo/weights/face_det_dnn_int8.pickle', 'rb')
    data_w_r = pickle.load(data_w_r)

    data_w = data_w_r['conv26/Convolution']['weights']
    data_b = data_w_r['conv26/Convolution']['bias']
    # print(data_b)

    data_conv = np.zeros((1, data_right.shape[1], data_right.shape[2], data_right.shape[3]))

    po = 15
    for i in range(data_right.shape[3]):
        for j in range(data_right.shape[1]):
            for k in range(data_right.shape[2]):
                # print(data[0][j][k][:])
                # print(data_w[i][0][0][:]*s)
                data_conv[0][j][k][i] = max(0,np.sum(np.multiply(data[0][j:j + 3, k:k + 3, :], data_w[i][:][:][:] * weight_scale[26])) + data_b[i] * data_scale[26] * weight_scale[26])
                # data_conv[0][j][k][i]=max(0,np.sum(np.multiply(data[0][j][k][:],data_w[i][0][0][:]*weight_scale[15]))+data_b[i]*data_scale[16]*weight_scale[15])

    print(data_conv - data_right)
    # print((((np.sqrt(np.mean(((data_conv - data_right) ** 2))) / (data_conv.max() - data_conv.min()) * 100))))

    # print(data_conv-data_right)
    # with open('conv16_manual_pre_32_noRelu', 'w') as f:
    #     for i in range(data_conv.shape[1]):
    #         for j in range(data_conv.shape[2]):
    #             f.writelines("(0," + str(i) + "," + str(j) + ')' + "  " + str(data_conv[0][i][j][:]) + "\n")

def compare_concat():
    data = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_128x128_1202/1202/output/SSH_0_3x3.npy')
    data = data.transpose(0, 2, 3, 1)
    print(data.shape)

    data_result = open('../sim/test_yolo_demo/result.pickle', 'rb')
    data_r = pickle.load(data_result)
    keys = list(data_r.keys())
    for i in range(len(keys)):
        print(str(i) + " " + keys[i])

    k = 38
    k1 = 33
    k2 = 35
    k3 = 37
    d = data_r[keys[k]][0]
    d1 = data_r[keys[k1]][0]
    d2 = data_r[keys[k2]][0]
    d3 = data_r[keys[k3]][0]
    print(d1[0][0][0][:])
    print(d2[0][0][0][:])
    print(d3[0][0][0][:])
    # print(d1)
    print("\n")
    print(d[0][0][0][:])

def other_test(input_type="cpu",output_type="cpu"):
    data_result = open('../sim/test_yolo_demo/result.pickle', 'rb')
    data_r = pickle.load(data_result)
    keys = list(data_r.keys())

    for i in range(len(keys)):
        print(str(i) + " " + keys[i])

    if input_type == "cpu":
        data = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_1202/1202/output/conv_13.npy')
        data = data.transpose(0, 2, 3, 1)
        # print(data.shape)
    else:
        data = data_r[keys[24]][0]

    if output_type == "cpu":
        # data_right = np.load('/home/zhangyuling/Documents/compile/output_quant_FD(1)/output/FPN_conv_1x1_1.npy')
        data_right = np.load('/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_1202/1202/output/FPN_conv_1x1_1.npy')
        data_right = data_right.transpose(0, 2, 3, 1)
    else:
        data_right = data_r[keys[28]][0]
        # print(data_conv)

    net = torch.load("/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_1202/1202/quant_ptq_fused.pth")
    # print(net)

    # get scale
    weight_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_weight_scale.npy'))
    data_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_input_scale.npy'))

    data_w_r = open('../sim/test_yolo_demo/weights/face_det_dnn_int8.pickle', 'rb')
    data_w_r = pickle.load(data_w_r)


    data_w = data_w_r['conv15/Convolution']['weights']

    # print(data_w)
    data_b = data_w_r['conv15/Convolution']['bias']


    data_conv = np.zeros((1, data_right.shape[1], data_right.shape[2], data_right.shape[3]))

    po = 15
    for i in range(data_right.shape[3]):
        for j in range(data_right.shape[1]):
            for k in range(data_right.shape[2]):
                # print(data[0][j][k][:])
                # print(data_w[i][0][0][:]*s)
                data_conv[0][j][k][i] = (np.sum(np.multiply(data[0][j][k][:], data_w[i][0][0][:] * weight_scale[15])) + data_b[i] * data_scale[14] *weight_scale[15])*17/4096
                # data_conv[0][j][k][i]=max(0,np.sum(np.multiply(data[0][j][k][:],data_w[i][0][0][:]*weight_scale[15]))+data_b[i]*data_scale[16]*weight_scale[15])

    # print(data_conv - data_right)
    print((((np.sqrt(np.mean(((data_conv - data_right) ** 2))) / (data_conv.max() - data_conv.min()) * 100))))

    # print(data_conv-data_right)
    # with open('conv16_manual_pre_32_noRelu', 'w') as f:
    #     for i in range(data_conv.shape[1]):
    #         for j in range(data_conv.shape[2]):
    #             f.writelines("(0," + str(i) + "," + str(j) + ')' + "  " + str(data_conv[0][i][j][:]) + "\n")

def read_file():
    import os
    ddr_list =  []
    for root, dirs, files in os.walk("../sim/test_yolo_demo/data_yolo_v2"):
        print(files)
        i=0
        for file in files:
            if "output" in file:
                i+=1
                print(i)
                print(file[-14:-4])
if __name__=="__main__":
    # read_origin_ouput(path='/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_128x128_1202/1202/output//FPN_conv_1x1_1.npy',save_path='test_compare')
    # read_run_result(key_index=33,save_path='test_compare')
    compare_difference(origin_path="./FD_1214_Final/1214/output/ClassHead_0.npy",key_index= 45)
    compare_difference(origin_path="./FD_1214_Final/1214/output/ClassHead_1.npy",key_index= 46)

    compare_difference(origin_path="./FD_1214_Final/1214/output/BboxHead_0.npy",key_index= 47)
    compare_difference(origin_path="./FD_1214_Final/1214/output/BboxHead_1.npy",key_index= 48)

    compare_difference(origin_path="./FD_1214_Final/1214/output/LandmsHead_0.npy",key_index= 49)
    compare_difference(origin_path="./FD_1214_Final/1214/output/LandmsHead_1.npy",key_index= 50)
    # data_result = open('../sim/test_yolo_demo/weights/face_det_dnn_int8.pickle', 'rb')
    # data_r = pickle.load(data_result)
    # print(data_r)
    # keys = list(data_r.keys())
    # print(keys)
    # print(data_r['conv1/Convolution']['bias'])
    # input_test = np.load("/home/zhangyuling/DNNAccel_1101_8b_13/example/FD_1214_Final/1214/output/input_data.npy")
    # input_final = np.load("/home/zhangyuling/DNNAccel_0110_pdet/sim/test_yolo_demo/input_data_face_det.npy")
    # # input_now = np.load("./input_data_face.npy")
    # diff = input_test-input_final
    # for i in range(input_final.shape[0]):
    #     for j in range(input_final.shape[1]):
    #         for k in range(input_final.shape[2]):
    #             print(diff[i][j][k])
    # compare_conv_1(input_type="run",output_type="run")
    # compare_conv_3(input_type="run", output_type="run")
    # other_test("cpu","run")
    # import shutil
    # import os
    # shutil.rmtree('../sim/test_yolo_demo/data_yolo_v2')
    # os.mkdir('../sim/test_yolo_demo/data_yolo_v2')
    # print(read_file())
    # data_scale = list(np.load('../dnnweaver2/benchmarks/face_detect_input_scale.npy'))
    # print(data_scale[30:])