import torch
import numpy as np
import collections
import pickle
net = torch.load("./FD_1214_Final/1214/quant_ptq_fused.pth")
# print(net)



f2 = open("../sim/test_yolo_demo/weights/face_det_int8.pickle", 'wb')
pickle_weights = collections.OrderedDict()

keys = list(net.keys())
with open("face_keys.txt",'w') as f:
    for i in range(len(keys)):
        f.write(str(i)+" "+str(keys[i])+"\n")
## 统一concat的scale
#concat0
m = max(net[keys[4*3 + 2]], net[keys[4*4 + 2]])
net[keys[4*3 + 2]] = m
net[keys[4*4 + 2]] = m
#concat1
m = max(net[keys[4*2 + 2]], net[keys[4*5 + 2]])
net[keys[4*2 + 2]] = m
net[keys[4*5 + 2]] = m

m = max(net[keys[4*7 + 2]], net[keys[4*8 + 2]])
net[keys[4*7 + 2]] = m
net[keys[4*8 + 2]] = m

m = max(net[keys[4*6 + 2]], net[keys[4*9 + 2]])
net[keys[4*6 + 2]] = m
net[keys[4*9 + 2]] = m

m = max(net[keys[4*11 + 2]], net[keys[4*12 + 2]])
net[keys[4*11 + 2]] = m
net[keys[4*12 + 2]] = m

m = max(net[keys[4*10 + 2]], net[keys[4*13 + 2]])
net[keys[4*10 + 2]] = m
net[keys[4*13 + 2]] = m

m = max(net[keys[4*15 + 2]], net[keys[4*17 + 2]])
net[keys[4*15 + 2]] = m
net[keys[4*17 + 2]] = m

m = max(net[keys[4*19 + 2]], net[keys[4*21 + 2]])
m = max(net[keys[4*23 + 2]], m)
net[keys[4*19 + 2]] = m
# print(keys[4*19 + 2])
net[keys[4*21 + 2]] = m
# print(keys[4*21 + 2])
net[keys[4*23 + 2]] = m
# print(keys[4*23 + 2])

m = max(net[keys[4*24 + 2]], net[keys[4*26 + 2]])
m = max(net[keys[4*28 + 2]], m)
net[keys[4*24 + 2]] = m
# print(keys[4*24 + 2])
net[keys[4*26 + 2]] = m
# print(keys[4*26 + 2])
net[keys[4*28 + 2]] = m
# print(keys[4*28 + 2])


d_s = float(net['quant.scale']) ##输入scale,在文件末尾
# print(float(d_s))

i = 0
w_list =[]
bias_list =[]
data_list =[]
data_list.append(d_s)
# print(net)
for key in net.keys():
    if "fpn.output2_1.1" not in key:
        if "weight" in key:
            conv_name = 'conv' + str(i) + '/Convolution'  ##卷积层名称
            weight = net[key]

            w_s = float(str(weight.max()).split(',')[-2].split('=')[1])
            w = np.asarray(weight.int_repr()).astype(np.int8).transpose(0, 2, 3, 1)
            # print(conv_name)
            # print(w.shape)
            # print(w_s)
            # print(w)
            w_list.append(w_s)
        elif "bias" in key:
            b = net[key].detach().numpy()
            if i == 15:
                b = np.divide(b, w_s * data_list[14])
            elif i== 16:
                b = np.divide(b, w_s * data_list[15])
            elif i== 20: #conv69
                b = np.divide(b, w_s * data_list[19]) # conv66
            elif i == 22: #conv72
                b = np.divide(b, w_s * data_list[21]) # conv69
            elif i == 24: #conv77
                b = np.divide(b, w_s * data_list[17]) # conv44
            elif i == 25: #conv78
                b = np.divide(b, w_s * data_list[17]) # conv44
            elif i == 27: # conv81
                b = np.divide(b, w_s * data_list[26]) # conv78
            elif i == 29: # conv103
                b = np.divide(b, w_s * data_list[24]) # conv74
            elif i == 30: # conv111
                b = np.divide(b, w_s * data_list[29]) # conv83
            elif i == 31: # conv86
                b = np.divide(b, w_s * data_list[24])
            elif i == 32:  # conv94
                b = np.divide(b, w_s * data_list[29])
            elif i == 33: # conv120
                b = np.divide(b, w_s * data_list[24])
            elif i == 34:  # conv128
                b = np.divide(b, w_s * data_list[29])
            else:
                b = np.divide(b, w_s*d_s)
            # for j in range(len(b)):
            #     if b[j] > 32767:
            #         b[j] = 32767
            #         print(">>>>")
            #     elif b[j] < -32768:
            #         b[j] = -32768
            #         print("<<<<<<")

           
            # print(i, b)
            # print(b)
            if i == 29:
                print(key)
                out_scale = net['ClassHead.0.conv1x1.scale'].item()
                zero_point = net['ClassHead.0.conv1x1.zero_point'].item()-128
                b = b + np.full(b.shape,int(round(zero_point*out_scale/(w_s*data_list[24]))))
                print(data_list[24])
                print(d_s)
                print("******")
                # print(out_scale)
                # print(zero_point)
            if i == 30:
                print(key)
                out_scale = net['ClassHead.1.conv1x1.scale'].item()
                zero_point = net['ClassHead.1.conv1x1.zero_point'].item()-128
                b = b + np.full(b.shape, int(round(zero_point * out_scale / (w_s * data_list[29]))))
                print(out_scale)
            if i == 31:
                print(key)
                out_scale = net['BboxHead.0.conv1x1.scale'].item()
                zero_point = net['BboxHead.0.conv1x1.zero_point'].item()-128
                b = b + np.full(b.shape, int(round(zero_point * out_scale / (w_s * data_list[24]))))
                print(out_scale)
            if i == 32:
                print(key)
                out_scale = net['BboxHead.1.conv1x1.scale'].item()
                zero_point = net['BboxHead.1.conv1x1.zero_point'].item()-128
                b = b + np.full(b.shape, int(round(zero_point * out_scale / (w_s * data_list[29]))))
                print(out_scale)
            if i == 33:
                print(key)
                out_scale = net['LandmarkHead.0.conv1x1.scale'].item()
                zero_point = net['LandmarkHead.0.conv1x1.zero_point'].item()-128
                b = b + np.full(b.shape, int(round(zero_point * out_scale / (w_s * data_list[24]))))
                print(out_scale)
            if i == 34:
                print(key)
                out_scale = net['LandmarkHead.1.conv1x1.scale'].item()
                zero_point = net['LandmarkHead.1.conv1x1.zero_point'].item() - 128
                b = b + np.full(b.shape, int(round(zero_point * out_scale / (w_s * data_list[29]))))
                print(out_scale)
            b = b.astype(np.int32)
            conv = collections.OrderedDict()
            conv['weights'] = w
            conv['bias'] = b

            pickle_weights[conv_name] = conv
            i = i + 1
        elif "scale" in key:
            d_s = net[key].item()
            data_list.append(d_s)
        elif "zero_point":
            d_z = net[key].item()

data_list.pop(-1)
# print(data_list)
# print(w_list)
np.save("../dnnweaver2/benchmarks/face_det_input_scale.npy", data_list)
np.save("../dnnweaver2/benchmarks/face_det_weight_scale.npy", w_list)
# print(pickle_weights)
print(data_list)
# print(pickle_weights['conv34/Convolution']['bias'][0])
pickle.dump(pickle_weights, f2)
