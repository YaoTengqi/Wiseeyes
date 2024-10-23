import torch
import numpy as np
import collections
import pickle
net = torch.load("./quant/quant_qat_epoch120.pth")

f2 = open("../sim/test_yolo_demo/weights/yolo_tiny_VOC.pickle", 'wb')
pickle_weights = collections.OrderedDict()
# print(net)
keys = list(net.keys())
with open("yolo4_tiny_keys.txt",'w') as f:
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
m = max(net[keys[4*18 + 2]], m)

# m = max(net[keys[4*10 + 2]], net[keys[4*13 + 2]])
# print(net[keys[4*10 + 2]])
# print(net[keys[4*13 + 2]])
# print(net[keys[4*18 + 2]])
# origin_13 = net[keys[4*13 + 2]]
net[keys[4*10 + 2]] = m
net[keys[4*13 + 2]] = m

# m = max(net[keys[4*13 + 2]], net[keys[4*18 + 2]])
# net[keys[4*13 + 2]] = m
net[keys[4*18 + 2]] = m

d_s = float(net['quant.scale']) ##输入scale,在文件末尾
i = 0
w_list =[]
bias_list =[]
data_list =[]
data_list.append(d_s)
for key in net.keys():
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
        if i == 18:
            b = np.divide(b, w_s * data_list[16])
        else:
            b = np.divide(b, w_s*d_s)
        if i == 17:
                # print(key)
                out_scale = net['yolo_headP5.1.scale'].item()
                zero_point = net['yolo_headP5.1.zero_point'].item()-128
                b = b + np.full(b.shape,int(round(zero_point*out_scale/(w_s*data_list[17]))))
                # print(data_list[17])
                # print(d_s)
                # print("******")
                # print(out_scale)
                # print(zero_point)
        if i == 20:
            # print(key)
            out_scale = net['yolo_headP4.1.scale'].item()
            zero_point = net['yolo_headP4.1.zero_point'].item()-128
            b = b + np.full(b.shape, int(round(zero_point * out_scale / (w_s * data_list[20]))))
            # print(out_scale)
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
        print(d_z)

data_list.pop(-1)
# print(data_list)
# print(w_list)
np.save("../dnnweaver2/benchmarks/yolo_tiny_VOC_input_scale.npy", data_list)
np.save("../dnnweaver2/benchmarks/yolo_tiny_VOC_weight_scale.npy", w_list)
# print(pickle_weights)
# print(data_list)
# print(pickle_weights['conv34/Convolution']['bias'][0])
pickle.dump(pickle_weights, f2)