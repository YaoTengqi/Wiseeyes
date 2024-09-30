from dnnweaver2.graph import Graph, get_default_graph

from dnnweaver2.tensorOps.cnn import conv2D, maxPool, flatten, matmul, addBias, batch_norm, reorg, concat, leakyReLU, upSampling, split
from dnnweaver2 import get_tensor
import logging
from dnnweaver2.scalar.dtypes import FQDtype, FixedPoint

from dnnweaver2 import get_tensor

def yolo_convolution(tensor_in, filters=32, kernel_size=3,
        batch_normalize=True, act='leakyReLU', stride = (1,1,1,1),
        c_dtype=None, w_dtype=None,
        s_dtype=None, bn_dtype=None):

    input_channels = tensor_in.shape[-1]
    tensor_in.ddr_vilid = True
    weights = get_tensor(shape=(filters, kernel_size, kernel_size, input_channels),
                         name='weights',
                         dtype=w_dtype)
    biases = get_tensor(shape=(filters),
                         name='biases',
                         dtype=FixedPoint(32,w_dtype.frac_bits + tensor_in.dtype.frac_bits))
    weights.ddr_vilid = True
    biases.ddr_vilid = True
    if stride[-2] != 1:
        pad = 'VALID'
    else:
        pad = 'SAME'
    conv = conv2D(tensor_in, weights, biases, pad=pad, stride = stride, dtype=c_dtype)

    if batch_normalize:
        with get_default_graph().name_scope('batch_norm'):
            mean = get_tensor(shape=(filters), name='mean', dtype=FixedPoint(16,c_dtype.frac_bits))
            scale = get_tensor(shape=(filters), name='scale', dtype=s_dtype)
            bn = batch_norm(conv, mean=mean, scale=scale, dtype=bn_dtype)
    else:
        bn = conv

    if act == 'leakyReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn,alpha=0, dtype=bn_dtype)

    elif act == 'linear':
        with get_default_graph().name_scope(act):
            act = bn
    else:
        raise ValueError('Unknown activation type {}'.format(act))
    act.ddr_vilid = True
    return act

def get_graph(train=False):
    g = Graph('YOLOv4-Test: 16-bit', dataset='imagenet', log_level=logging.INFO)
    batch_size = 1

    with g.as_default():

            with g.name_scope('inputs'):
                i = get_tensor(shape=(batch_size, 352,480,3), name='data', dtype=FQDtype.FXP16, trainable=False)

            with g.name_scope('conv0'):
                layer0 = yolo_convolution(i, filters=32, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 10), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 10), bn_dtype=FixedPoint(16, 8), stride=(1, 2, 2, 1))

            with g.name_scope('conv1'):
                layer1 = yolo_convolution(layer0, filters=64, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 13), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8), stride=(1, 2, 2, 1))

            with g.name_scope('conv2'):
                layer2 = yolo_convolution(layer1, filters=64, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('pool0'):
                layer2_pool = maxPool(layer2, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
            with g.name_scope('split0'):
                layer3 = split(layer2)

            with g.name_scope('conv3'):
                layer4 = yolo_convolution(layer3, filters=32, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

            with g.name_scope('conv4'):
                layer5 = yolo_convolution(layer4, filters=32, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('concat0'):
                layer6 = concat((layer5, layer4), 3)

            with g.name_scope('conv5'):
                layer7 = yolo_convolution(layer6, filters=64, kernel_size=1,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('pool1'):
                layer8 = maxPool(layer7, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
            with g.name_scope('concat1'):
                layer9 = concat((layer2_pool, layer8) ,3)

            with g.name_scope('conv6'):
                layer10 = yolo_convolution(layer9, filters=128, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 15), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('pool2'):
                layer10_pool = maxPool(layer10, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
            with g.name_scope('split1'):
                layer11 = split(layer10)

            with g.name_scope('conv7'):
                layer12 = yolo_convolution(layer11, filters=64, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

            with g.name_scope('conv8'):
                layer13 = yolo_convolution(layer12, filters=64, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('concat2'):
                layer14 = concat((layer13, layer12), 3)

            with g.name_scope('conv9'):
                layer15 = yolo_convolution(layer14, filters=128, kernel_size=1,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 13), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('pool3'):
                layer16 = maxPool(layer15, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
            with g.name_scope('concat3'):
                layer17 = concat((layer10_pool, layer16), 3)

            with g.name_scope('conv10'):
                layer18 = yolo_convolution(layer17, filters=256, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('pool4'):
                layer18_pool = maxPool(layer18, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
            with g.name_scope('split2'):
                layer19 = split(layer18)

            with g.name_scope('conv11'):
                layer20 = yolo_convolution(layer19, filters=128, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 13), bn_dtype=FixedPoint(16, 8))

            with g.name_scope('conv12'):
                layer21 = yolo_convolution(layer20, filters=128, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 13), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('concat4'):
                layer22 = concat((layer21, layer20), 3)
            with g.name_scope('conv13'):
                layer23 = yolo_convolution(layer22, filters=256, kernel_size=1,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 13), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('pool5'):
                layer24 = maxPool(layer23, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
            with g.name_scope('concat5'):
                layer25 = concat((layer18_pool, layer24),3)
            
            with g.name_scope('conv14'):
                layer26 = yolo_convolution(layer25, filters=512, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('conv15'):
                layer27 = yolo_convolution(layer26, filters=256, kernel_size=1,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 12), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('conv16'):
                layer28 = yolo_convolution(layer27, filters=512, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 12), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('conv17'):
                layer29 = yolo_convolution(layer28, filters=18, kernel_size=1,
                        batch_normalize=False, act='linear',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 12), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('conv18'):
                layer32 = yolo_convolution(layer27, filters=128, kernel_size=1,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 12), bn_dtype=FixedPoint(16, 8))
            with g.name_scope('upsample0'):
                layer33 = upSampling(layer32, sample_kernel=(1, 2, 2, 1))
            with g.name_scope('concat6'):
                layer34 = concat((layer33, layer23), 3)

            with g.name_scope('conv19'):
                layer35 = yolo_convolution(layer34, filters=256, kernel_size=3,
                        batch_normalize=False, act='leakyReLU',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 13), bn_dtype=FixedPoint(16, 8))

            with g.name_scope('conv20'):
                layer36 = yolo_convolution(layer35, filters=18, kernel_size=1,
                        batch_normalize=False, act='linear',
                        w_dtype=FixedPoint(16, 15), c_dtype=FixedPoint(16, 8),
                        s_dtype=FixedPoint(16, 10), bn_dtype=FixedPoint(16, 8))


    return g
