from dnnweaver2.graph import Graph, get_default_graph

from dnnweaver2.tensorOps.cnn import conv2D, maxPool, flatten, matmul, addBias, batch_norm, reorg, concat, leakyReLU, \
    upSampling, split
from dnnweaver2 import get_tensor
import logging
from dnnweaver2.scalar.dtypes import FQDtype, FixedPoint

from dnnweaver2 import get_tensor
import numpy as np

def yolo_convolution(tensor_in, filters=32, kernel_size=3,
                     batch_normalize=True, act='leakyReLU', weight_scale=1.0,
                     out_scale=1.0, out_z = 0,
                     stride=(1, 1, 1, 1)):
    input_channels = tensor_in.shape[-1]
    tensor_in.ddr_vilid = True
    weights = get_tensor(shape=(filters, kernel_size, kernel_size, input_channels),
                         name='weights',
                         dtype=FQDtype.FXP8, scale=weight_scale)
    biases = get_tensor(shape=(filters),
                        name='biases',
                        dtype=FQDtype.FXP32, scale=tensor_in.scale * weight_scale)
    weights.ddr_vilid = True
    biases.ddr_vilid = True
    
    if stride[-2] != 1:
        pad = 'VALID'
    else:
        pad = 'SAME'
    conv = conv2D(tensor_in, weights, biases, pad=pad, stride=stride, dtype=FQDtype.FXP8, out_scale=out_scale)

    bn = conv

    if act == 'leakyReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn, dtype=bn.dtype)
    elif act == 'ReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn, alpha=0, dtype=FQDtype.FXP8, out_scale=out_scale)
    elif act == 'linear':
        with get_default_graph().name_scope(act):
            act = bn
    else:
        raise ValueError('Unknown activation type {}'.format(act))

    act.ddr_vilid = True
    act.zero_point = out_z
    return act


def get_graph(train=False):
    g = Graph('YOLOv4-Test: 8-bit', dataset='imagenet', log_level=logging.INFO)
    batch_size = 1
    #/home/sy/work/yolov4/DNNAccel_1020yt_8b
    data_scale = list(np.load('../../dnnweaver2/benchmarks/input_scale_c18.npy'))
    weight_scale = list(np.load('../../dnnweaver2/benchmarks/weight_scale_c18.npy'))
    with g.as_default():
        with g.name_scope('inputs'):
            input = get_tensor(shape=(batch_size, 352, 480, 3), name='data', dtype=FQDtype.FXP8, trainable=False, scale=data_scale[0])

        with g.name_scope('conv0'):
            layer0 = yolo_convolution(input, filters=32, kernel_size=3,
                batch_normalize=False, act='ReLU',
                weight_scale=weight_scale[0],  out_scale=data_scale[1],
                stride=(1, 2, 2, 1))

        with g.name_scope('conv1'):
            layer1 = yolo_convolution(layer0, filters=64, kernel_size=3,
                batch_normalize=False, act='ReLU',
                weight_scale=weight_scale[1],  out_scale=data_scale[2], stride=(1, 2, 2, 1))

        with g.name_scope('conv2'):
            layer2 = yolo_convolution(layer1, filters=64, kernel_size=3,
                batch_normalize=False, act='ReLU',
                weight_scale=weight_scale[2],  out_scale=data_scale[3])

        with g.name_scope('pool0'):
            layer2_pool = maxPool(layer2, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split0'):
            layer3 = split(layer2)

        with g.name_scope('conv3'):
            layer4 = yolo_convolution(layer3, filters=32, kernel_size=3,
            batch_normalize=False, act='ReLU',
            weight_scale=weight_scale[3],  out_scale=data_scale[4])

        with g.name_scope('conv4'):
            layer5 = yolo_convolution(layer4, filters=32, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[4], out_scale=data_scale[5])
        with g.name_scope('concat0'):
            layer6 = concat((layer5, layer4), 3)

        with g.name_scope('conv5'):
            layer7 = yolo_convolution(layer6, filters=64, kernel_size=1,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[5], out_scale=data_scale[6])
        with g.name_scope('pool1'):
            layer8 = maxPool(layer7, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat1'):
            layer9 = concat((layer2_pool, layer8) ,3)

        with g.name_scope('conv6'):
            layer10 = yolo_convolution(layer9, filters=128, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[6], out_scale=data_scale[7])
        with g.name_scope('pool2'):
            layer10_pool = maxPool(layer10, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split1'):
            layer11 = split(layer10)

        with g.name_scope('conv7'):
            layer12 = yolo_convolution(layer11, filters=64, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[7], out_scale=data_scale[8])

        with g.name_scope('conv8'):
            layer13 = yolo_convolution(layer12, filters=64, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[8], out_scale=data_scale[9])
        with g.name_scope('concat2'):
            layer14 = concat((layer13, layer12), 3)

        with g.name_scope('conv9'):
            layer15 = yolo_convolution(layer14, filters=128, kernel_size=1,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[9], out_scale=data_scale[10])
        with g.name_scope('pool3'):
            layer16 = maxPool(layer15, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat3'):
            layer17 = concat((layer10_pool, layer16), 3)

        with g.name_scope('conv10'):
            layer18 = yolo_convolution(layer17, filters=256, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[10], out_scale=data_scale[11])
        with g.name_scope('pool4'):
            layer18_pool = maxPool(layer18, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split2'):
            layer19 = split(layer18)

        with g.name_scope('conv11'):
            layer20 = yolo_convolution(layer19, filters=128, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[11], out_scale=data_scale[12])

        with g.name_scope('conv12'):
            layer21 = yolo_convolution(layer20, filters=128, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[12], out_scale=data_scale[13])
        with g.name_scope('concat4'):
            layer22 = concat((layer21, layer20), 3)

        with g.name_scope('conv13'):
            layer23 = yolo_convolution(layer22, filters=256, kernel_size=1,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[13], out_scale=data_scale[14])
        with g.name_scope('pool5'):
            layer24 = maxPool(layer23, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat5'):
            layer25 = concat((layer18_pool, layer24),3)

        with g.name_scope('conv14'):
            layer26 = yolo_convolution(layer25, filters=512, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[14], out_scale=data_scale[15])

        with g.name_scope('conv15'):
            layer27 = yolo_convolution(layer26, filters=256, kernel_size=1,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[15], out_scale=data_scale[16])

        with g.name_scope('conv16'):
            layer28 = yolo_convolution(layer27, filters=512, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[16], out_scale=data_scale[17])

        with g.name_scope('conv17'):
            layer29 = yolo_convolution(layer28, filters=18, kernel_size=1,
                    batch_normalize=False, act='linear',
                    weight_scale=weight_scale[17], out_scale=data_scale[18], out_z = 28)

        with g.name_scope('conv18'):
            layer32 = yolo_convolution(layer27, filters=128, kernel_size=1,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[18], out_scale=data_scale[19])
        with g.name_scope('upsample0'):
            layer33 = upSampling(layer32, sample_kernel=(1, 2, 2, 1))
        with g.name_scope('concat6'):
            layer34 = concat((layer33, layer23), 3)

        with g.name_scope('conv19'):
            layer35 = yolo_convolution(layer34, filters=256, kernel_size=3,
                    batch_normalize=False, act='ReLU',
                    weight_scale=weight_scale[19], out_scale=data_scale[20])

        with g.name_scope('conv20'):
            layer36 = yolo_convolution(layer35, filters=18, kernel_size=1,
                    batch_normalize=False, act='linear',
                    weight_scale=weight_scale[20], out_scale=data_scale[21], out_z = 35)
    return g
