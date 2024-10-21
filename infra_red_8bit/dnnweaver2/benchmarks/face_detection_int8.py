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
                     out_scale=1.0, out_z=0,
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
    g = Graph('face_detect: 8-bit', dataset='imagenet', log_level=logging.INFO)
    batch_size = 1
    data_scale = list(np.load('../../dnnweaver2/benchmarks/face_det_input_scale.npy'))
    print(data_scale)
    weight_scale = list(np.load('../../dnnweaver2/benchmarks/face_det_weight_scale.npy'))
    with g.as_default():
        with g.name_scope('inputs'):
            #true
            input = get_tensor(shape=(batch_size, 352, 480, 3), name='data', dtype=FQDtype.FXP8, trainable=False,
                               scale=data_scale[0])
        with g.name_scope('conv0'):  # conv0
            layer0 = yolo_convolution(input, filters=32, kernel_size=3,
                                      batch_normalize=False, act='ReLU',
                                      weight_scale=weight_scale[0], out_scale=data_scale[1],
                                      stride=(1, 2, 2, 1))
        with g.name_scope('conv1'):  # conv2  0.28
            layer1 = yolo_convolution(layer0, filters=64, kernel_size=3,
                                      batch_normalize=False, act='ReLU',
                                      weight_scale=weight_scale[1], out_scale=data_scale[2], stride=(1, 2, 2, 1))


        #res0
        with g.name_scope('conv2'):  # conv4  0.28
            layer2 = yolo_convolution(layer1, filters=64, kernel_size=3,
                                      batch_normalize=False, act='ReLU',
                                      weight_scale=weight_scale[2], out_scale=data_scale[3])
        with g.name_scope('pool0'): #15.4
            layer2_pool = maxPool(layer2, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split0'):  # split6   0.2
            layer3 = split(layer2)
        with g.name_scope('conv3'):  # conv7   0.4
            layer4 = yolo_convolution(layer3, filters=32, kernel_size=3,
                                      batch_normalize=False, act='ReLU',
                                      weight_scale=weight_scale[3], out_scale=data_scale[4])
        with g.name_scope('conv4'):  # conv9
            layer5 = yolo_convolution(layer4, filters=32, kernel_size=3,
                                      batch_normalize=False, act='ReLU',
                                      weight_scale=weight_scale[4], out_scale=data_scale[5])
        with g.name_scope('concat0'):  # concat11 0.43
            layer6 = concat((layer5, layer4), 3)
        with g.name_scope('conv5'):  # conv12
            layer7 = yolo_convolution(layer6, filters=64, kernel_size=1,
                                      batch_normalize=False, act='ReLU',
                                      weight_scale=weight_scale[5], out_scale=data_scale[6])
        with g.name_scope('pool1'):  # maxpool15
            layer8 = maxPool(layer7, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat1'):  # concat14
            layer9 = concat((layer2_pool,layer8), 3)


        #res1
        with g.name_scope('conv6'):  # conv16
            layer10 = yolo_convolution(layer9, filters=128, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[6], out_scale=data_scale[7])
        with g.name_scope('pool2'):
            layer10_pool = maxPool(layer10, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split1'):  # split18
            layer11 = split(layer10)
        with g.name_scope('conv7'):  # conv19
            layer12 = yolo_convolution(layer11, filters=64, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[7], out_scale=data_scale[8])
        with g.name_scope('conv8'):  # conv21
            layer13 = yolo_convolution(layer12, filters=64, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[8], out_scale=data_scale[9])
        with g.name_scope('concat2'):  # concat23
            layer14 = concat((layer13, layer12), 3)
        with g.name_scope('conv9'):  # conv24
            layer15 = yolo_convolution(layer14, filters=128, kernel_size=1,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[9], out_scale=data_scale[10])
        with g.name_scope('pool3'):  # maxpool27
            layer16 = maxPool(layer15, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat3'):  # concat26
            layer17 = concat((layer10_pool,layer16), 3)

        #res2
        with g.name_scope('conv10'):  # conv28
            layer18 = yolo_convolution(layer17, filters=256, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[10], out_scale=data_scale[11])
        with g.name_scope('pool4'): #1.29
            layer18_pool = maxPool(layer18, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split2'):  # split30
            layer19 = split(layer18) #0.78
        with g.name_scope('conv11'):  # conv31
            layer20 = yolo_convolution(layer19, filters=128, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[11], out_scale=data_scale[12])
        with g.name_scope('conv12'):  # conv33
            layer21 = yolo_convolution(layer20, filters=128, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[12], out_scale=data_scale[13])
        with g.name_scope('concat4'):  # concat35
            layer22 = concat((layer21, layer20), 3)
        with g.name_scope('conv13'):  # conv36
            layer23 = yolo_convolution(layer22, filters=256, kernel_size=1,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[13], out_scale=data_scale[14])
        with g.name_scope('pool5'):  # maxpool39
            layer24 = maxPool(layer23, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat5'):  # concat38
            layer25 = concat((layer18_pool,layer24), 3)
        with g.name_scope('conv14'):  # conv40
            layer26 = yolo_convolution(layer25, filters=512, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[14], out_scale=data_scale[15])

        #FPN1
        with g.name_scope('conv15'):  # conv42
            layer27 = yolo_convolution(layer23, filters=64, kernel_size=1,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[15], out_scale=data_scale[16])

        with g.name_scope('conv16'):  # conv44
            layer28 = yolo_convolution(layer26, filters=64, kernel_size=1,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[16], out_scale=data_scale[17])
        with g.name_scope('conv17'):  # conv46
            layer29 = yolo_convolution(layer28, filters=64, kernel_size=1,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[17], out_scale=data_scale[18])
        with g.name_scope('upsample0'):  # upsample64
            layer30 = upSampling(layer29, sample_kernel=(1, 2, 2, 1))

        with g.name_scope('concat6'):  # concat65
            layer31 = concat((layer27,layer30), 3)

        with g.name_scope('conv18'):  # conv66
            layer32 = yolo_convolution(layer31, filters=64, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[18], out_scale=data_scale[19])

        with g.name_scope('conv19'):  # conv68
            layer33 = yolo_convolution(layer32, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[19], out_scale=data_scale[20])

        with g.name_scope('conv20'):  # conv69
            layer34 = yolo_convolution(layer32, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[20], out_scale=data_scale[21])

        with g.name_scope('conv21'):  # conv71
            layer35 = yolo_convolution(layer34, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[21], out_scale=data_scale[22])

        with g.name_scope('conv22'):  # conv72
            layer36 = yolo_convolution(layer34, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[22], out_scale=data_scale[23])

        with g.name_scope('conv23'):  # conv74
            layer37 = yolo_convolution(layer36, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[23], out_scale=data_scale[24])

        with g.name_scope('concat7'):  # concat75
            layer38 = concat((layer33,layer35,layer37), 3)

        with g.name_scope('conv24'):  # conv77
            layer39 = yolo_convolution(layer28, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[24], out_scale=data_scale[25])

        with g.name_scope('conv25'):  # conv78
            layer40 = yolo_convolution(layer28, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[25], out_scale=data_scale[26])

        with g.name_scope('conv26'):  # conv80
            layer41 = yolo_convolution(layer40, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[26], out_scale=data_scale[27])

        with g.name_scope('conv27'):  # conv81
            layer42 = yolo_convolution(layer40, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[27], out_scale=data_scale[28])

        with g.name_scope('conv28'):  # conv83
            layer43 = yolo_convolution(layer42, filters=32, kernel_size=3,
                                       batch_normalize=False, act='ReLU',
                                       weight_scale=weight_scale[28], out_scale=data_scale[29])

        with g.name_scope('concat8'):  # concat84
            layer44 = concat((layer39,layer41,layer43), 3)


        with g.name_scope('conv29'):  # conv103 4.98 0.73
            layer46 = yolo_convolution(layer38, filters=4, kernel_size=1,
                                       batch_normalize=False, act='linear',
                                       weight_scale=weight_scale[29], out_scale=data_scale[30], out_z=-1)
        
        with g.name_scope('conv30'):  # conv111 1.17 0.84
            layer47 = yolo_convolution(layer44, filters=4, kernel_size=1,
                                       batch_normalize=False, act='linear',
                                       weight_scale=weight_scale[30], out_scale=data_scale[31], out_z=-1)
        with g.name_scope('conv31'):  # conv86 2.66 0.72
            layer48 = yolo_convolution(layer38, filters=8, kernel_size=1,
                                       batch_normalize=False, act='linear',
                                       weight_scale=weight_scale[31], out_scale=data_scale[32], out_z=-1)
        
        with g.name_scope('conv32'):  # conv94 7.728 0.95
            layer49 = yolo_convolution(layer44, filters=8, kernel_size=1,
                                       batch_normalize=False, act='linear',
                                       weight_scale=weight_scale[32], out_scale=data_scale[33], out_z=-7)
        
        with g.name_scope('conv33'):  # conv120 3.01 0.59
            layer50 = yolo_convolution(layer38, filters=20, kernel_size=1,
                                       batch_normalize=False, act='linear',
                                       weight_scale=weight_scale[33], out_scale=data_scale[34], out_z=-6)
        
        with g.name_scope('conv34'):  # conv128 12.65 1.19
            layer51 = yolo_convolution(layer44, filters=20, kernel_size=1,
                                       batch_normalize=False, act='linear',
                                       weight_scale=weight_scale[34], out_scale=data_scale[35], out_z=-17)

    return g
