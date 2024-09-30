from dnnweaver2.graph import Graph, get_default_graph

from dnnweaver2.tensorOps.cnn import conv2D, maxPool, flatten, matmul, addBias, batch_norm, reorg, concat, leakyReLU, \
    upSampling, split
from dnnweaver2 import get_tensor
import logging
from dnnweaver2.scalar.dtypes import FQDtype, FixedPoint

from dnnweaver2 import get_tensor


def yolo_convolution(tensor_in, filters=32, kernel_size=3,
                     batch_normalize=True, act='leakyReLU', stride=(1, 1, 1, 1),
                     w_dtype=None, c_dtype=None,
                     s_dtype=None, bn_dtype=None):
    input_channels = tensor_in.shape[-1]
    tensor_in.ddr_vilid = True
    weights = get_tensor(shape=(filters, kernel_size, kernel_size, input_channels),
                         name='weights',
                         dtype=w_dtype)
    biases = get_tensor(shape=(filters),
                        name='biases',
                        dtype=FixedPoint(32, w_dtype.frac_bits + tensor_in.dtype.frac_bits))
    weights.ddr_vilid = True
    biases.ddr_vilid = True
    if stride[-2] != 1:
        pad = 'VALID'
    else:
        pad = 'SAME'
    conv = conv2D(tensor_in, weights, biases, pad=pad, dtype=c_dtype)
    
    if batch_normalize:
        with get_default_graph().name_scope('batch_norm'):
            mean = get_tensor(shape=(filters), name='mean', dtype=FixedPoint(16, c_dtype.frac_bits))
            scale = get_tensor(shape=(filters), name='scale', dtype=s_dtype)
            mean.ddr_vilid = True
            scale.ddr_vilid =True
            bn = batch_norm(conv, mean=mean, scale=scale, dtype=bn_dtype)
    else:
        bn = conv

    if act == 'leakyReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn, dtype=bn.dtype)
    elif act == 'ReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn, alpha=0, dtype=bn.dtype)
    elif act == 'linear':
        with get_default_graph().name_scope(act):
            act = bn
    else:
        raise ValueError('Unknown activation type {}'.format(act))
    act.ddr_vilid = True
    return act


def get_graph(train=False):
    g = Graph('ResBlock-Test: 16-bit', dataset='imagenet', log_level=logging.INFO)
    batch_size = 1

    with g.as_default():
        with g.name_scope('inputs'):
            i = get_tensor(shape=(batch_size, 128, 256, 64), name='data', dtype=FQDtype.FXP16, trainable=False)

        # begin res_block_1
        with g.name_scope('conv0'):
            conv0 = yolo_convolution(i, filters=64, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('pool0'):
            pool0 = maxPool(conv0, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split0'):
            split0 = split(conv0)

        with g.name_scope('conv1'):
            conv1 = yolo_convolution(split0, filters=32, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

        with g.name_scope('conv2'):
            conv2 = yolo_convolution(conv1, filters=32, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('concat0'):
            concat0 = concat((conv2, conv1), 3)

        with g.name_scope('conv3'):
            conv3 = yolo_convolution(concat0, filters=64, kernel_size=1,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('pool1'):
            pool1 = maxPool(conv3, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat1'):
            concat1 = concat((pool0, pool1), 3)

        with g.name_scope('conv4'):
            conv4 = yolo_convolution(concat1, filters=192, kernel_size=1,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        # end res_block_1

        # begin res_block_2
        with g.name_scope('conv5'):
            conv5 = yolo_convolution(concat1, filters=128, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('pool2'):
            pool2 = maxPool(conv5, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('split1'):
            split1 = split(conv5)

        with g.name_scope('conv6'):
            conv6 = yolo_convolution(split1, filters=64, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

        with g.name_scope('conv7'):
            conv7 = yolo_convolution(conv6, filters=64, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('concat2'):
            concat2 = concat((conv7, conv6), 3)

        with g.name_scope('conv8'):
            conv8 = yolo_convolution(concat2, filters=128, kernel_size=1,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('pool3'):
            pool3 = maxPool(conv8, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        with g.name_scope('concat3'):
            concat3 = concat((pool2, pool3), 3)
        # end res_block_2

        # begin res_block_3
        with g.name_scope('conv9'):
            conv9 = yolo_convolution(concat3, filters=256, kernel_size=3,
                                     batch_normalize=True, act='ReLU',
                                     w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                     s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('split2'):
            split2 = split(conv9)

        with g.name_scope('conv10'):
            conv10 = yolo_convolution(split2, filters=128, kernel_size=3,
                                      batch_normalize=True, act='ReLU',
                                      w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

        with g.name_scope('conv11'):
            conv11 = yolo_convolution(conv10, filters=128, kernel_size=3,
                                      batch_normalize=True, act='ReLU',
                                      w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('concat4'):
            concat4 = concat((conv11, conv10), 3)

        with g.name_scope('conv12'):
            conv12 = yolo_convolution(concat4, filters=256, kernel_size=1,
                                      batch_normalize=True, act='ReLU',
                                      w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('concat5'):
            concat5 = concat((conv9, conv12), 3)
        # end res_block_3

        with g.name_scope('conv13'):
            conv13 = yolo_convolution(concat5, filters=192, kernel_size=1,
                                      batch_normalize=True, act='ReLU',
                                      w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 13), bn_dtype=FixedPoint(16, 8))
        with g.name_scope('upsample0'):
            upsample0 = upSampling(conv13, sample_kernel=(1, 2, 2, 1))
        with g.name_scope('concat6'):
            concat6 = concat((upsample0, conv4), 3)

        # conv_cls
        with g.name_scope('conv14'):
            conv14 = yolo_convolution(concat6, filters=2, kernel_size=1,
                                      batch_normalize=False, act='linear',
                                      w_dtype=FixedPoint(16, 13), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

        # conv_box
        with g.name_scope('conv15'):
            conv15 = yolo_convolution(concat6, filters=14, kernel_size=1,
                                      batch_normalize=False, act='linear',
                                      w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

        # conv_dir_cls
        with g.name_scope('conv16'):
            conv16 = yolo_convolution(concat6, filters=4, kernel_size=1,
                                      batch_normalize=False, act='linear',
                                      w_dtype=FixedPoint(16, 14), c_dtype=FixedPoint(16, 8),
                                      s_dtype=FixedPoint(16, 14), bn_dtype=FixedPoint(16, 8))

    return g
