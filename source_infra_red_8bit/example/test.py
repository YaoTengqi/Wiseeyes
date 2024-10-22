import numpy as np
import pickle
import torch

# data_w_r = open('../sim/test_yolo_demo/weights/yolo_tiny_VOC.pickle', 'rb')
# data_w_r = pickle.load(data_w_r)
# print(data_w_r['conv17/Convolution']['weights'].shape)

# input_im = np.asarray(np.load("../sim/test_yolo_demo/input_data_VOC.npy", allow_pickle=True)).transpose(0,2,3,1)
# print(input_im.shape)

# data = np.load('./quant/output/conv_18.npy')
# data = data.transpose(0, 2, 3, 1)
# print(data)

data_w_r = open('../sim/test_yolo_demo/result_VOC.pickle', 'rb')
data_w_r = pickle.load(data_w_r)

output = np.asarray(np.load("./quant/output/output_1_float.npy")).transpose(0,2,3,1)
print(output.shape)
print(data_w_r.keys())
right = np.asarray(data_w_r['conv20/TypeCastOp'][0])
print(right.shape)
print("result1:", (((np.sqrt(np.mean(( right- output) ** 2))) / (right.max() - right.min()) * 100)))