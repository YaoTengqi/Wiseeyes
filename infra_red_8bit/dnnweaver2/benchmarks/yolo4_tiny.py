from dnnweaver2.graph import Graph, get_default_graph

from dnnweaver2.tensorOps.cnn import conv2D, maxPool, flatten, matmul, addBias, batch_norm, reorg, concat, leakyReLU, \
    upSampling, split
from dnnweaver2 import get_tensor
import logging
from dnnweaver2.scalar.dtypes import FQDtype, FixedPoint

from dnnweaver2 import get_tensor


def yolo_convolution(tensor_in, filters=32, kernel_size=3,
                     batch_normalize=True, act='leakyReLU', stride=(1, 1, 1, 1),
                     c_dtype=None, w_dtype=None,
                     s_dtype=None, bn_dtype=None):
    input_channels = tensor_in.shape[-1]

    weights = get_tensor(shape=(filters, kernel_size, kernel_size, input_channels),
                         name='weights',
                         dtype=w_dtype)
    biases = get_tensor(shape=(filters),
                        name='biases',
                        dtype=FixedPoint(16, w_dtype.frac_bits + tensor_in.dtype.frac_bits))
    if stride[-2] != 1:
        pad = 'VALID'
    else:
        pad = 'SAME'
    conv = conv2D(tensor_in, weights, biases, pad=pad, stride=stride, dtype=c_dtype)

    if batch_normalize:
        with get_default_graph().name_scope('batch_norm'):
            mean = get_tensor(shape=(filters), name='mean', dtype=FixedPoint(8, c_dtype.frac_bits))
            scale = get_tensor(shape=(filters), name='scale', dtype=s_dtype)
            bn = batch_norm(conv, mean=mean, scale=scale, dtype=bn_dtype)
    else:
        bn = conv

    if act == 'leakyReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn, alpha=0, dtype=bn.dtype)
    elif act == 'ReLU':
        with get_default_graph().name_scope(act):
            act = leakyReLU(bn, alpha=0.1, dtype=bn.dtype)
    elif act == 'linear':
        with get_default_graph().name_scope(act):
            act = bn
    else:
        raise ValueError('Unknown activation type {}'.format(act))

    return act


def get_graph(train=False):
    g = Graph('CONV32*32-Test: 16-bit', dataset='imagenet', log_level=logging.INFO)
    batch_size = 1

    with g.as_default():
        with g.name_scope('inputs'):
            i = get_tensor(shape=(batch_size, 32, 32, 3), name='data', dtype=FixedPoint(8, 6), trainable=False)

        with g.name_scope('conv0'):
            conv0 = yolo_convolution(i, filters=32, kernel_size=3,
                                     batch_normalize=False, act='linear',
                                     w_dtype=FixedPoint(8, 5), c_dtype=FixedPoint(8, 5),
                                     s_dtype=FixedPoint(8, 5), bn_dtype=FixedPoint(8, 6))
        # with g.name_scope('pool0'):
        #     pool0 = maxPool(conv0, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        # with g.name_scope('split0'):
        #     split0 = split(conv0)

        # with g.name_scope('conv1'):
        #     conv1 = yolo_convolution(split0, filters=64, kernel_size=3,
        #                              batch_normalize=False, act='leakyReLU',
        #                              w_dtype=FixedPoint(16, 12), c_dtype=FixedPoint(16, 12),
        #                              s_dtype=FixedPoint(16, 9), bn_dtype=FixedPoint(16, 8))
        # with g.name_scope('pool1'):
        #     pool1 = maxPool(conv1, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')

        # with g.name_scope('concat0'):
        #     cat0 = concat((pool0, pool1), 3)

        # with g.name_scope('conv2'):
        #     conv2 = yolo_convolution(cat0, filters=10, kernel_size=3,
        #                              batch_normalize=False, act='leakyReLU',
        #                              w_dtype=FixedPoint(16, 12), c_dtype=FixedPoint(16, 12),
        #                              s_dtype=FixedPoint(16, 9), bn_dtype=FixedPoint(16, 8))
        # # with g.name_scope('pool0'):
        #     pool0 = maxPool(conv0, pooling_kernel=(1, 2, 2, 1), stride=(1, 2, 2, 1), pad='VALID')
        #
        # with g.name_scope('conv1'):
        #     conv1 = yolo_convolution(pool0, filters=32, kernel_size=3,
        #                              batch_normalize=False, act='leakyReLU',
        #                              w_dtype=FixedPoint(16, 12), c_dtype=FixedPoint(16, 12),
        #                              s_dtype=FixedPoint(16, 9), bn_dtype=FixedPoint(16, 8))
        # with g.name_scope('upsa1mple'):
        #     upsample0 = upSampling(conv1, sample_kernel=(1, 2, 2, 1))
        #
        # with g.name_scope('conv2'):
        #     conv2 = yolo_convolution(conv0, filters=64, kernel_size=3,
        #                              batch_normalize=False, act='leakyReLU',
        #                              w_dtype=FixedPoint(16, 12), c_dtype=FixedPoint(16, 12),
        #                              s_dtype=FixedPoint(16, 9), bn_dtype=FixedPoint(16, 8))
        #
        # with g.name_scope('concat0'):
        #     cat0 = concat((upsample0, conv2), 3)
        #
        # with g.name_scope('conv3'):
        #     conv3 = yolo_convolution(cat0, filters=10, kernel_size=3,
        #                              batch_normalize=False, act='leakyReLU',
        #                              w_dtype=FixedPoint(16, 12), c_dtype=FixedPoint(16, 12),
        #                              s_dtype=FixedPoint(16, 9), bn_dtype=FixedPoint(16, 8))
        # with g.name_scope('split0'):
        #     split0 = split(conv3)


    return g
