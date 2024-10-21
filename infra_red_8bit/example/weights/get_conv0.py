import pickle
import collections
file = open('yolo2_tiny_dnnweaver2_weights.pickle', 'rb')
data = pickle.load(file,encoding='latin1')

file2 = open('yolo2_tiny_conv0_weights.pickle', 'wb')
conv0 = data['conv0/Convolution']

weight = collections.OrderedDict()
weight['conv0/Convolution'] = conv0

print(weight)
pickle.dump(weight,file2)