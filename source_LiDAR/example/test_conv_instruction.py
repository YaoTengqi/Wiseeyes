#!/usr/bin/python3
# _*_ coding:utf-8  _*_
# @Time    : 2021/2/19 2:34 PM
# @Author  : 'zhangxun'
# @Email   : 15025689012@163.com
# @File    : test_conv_Instruction.py
# @Software: PyCharm

import logging
import numpy as np
import array

import dnnweaver2
from dnnweaver2.benchmarks import get_graph
from dnnweaver2.simulator.accelerator import Accelerator
from dnnweaver2.compiler import *
from dnnweaver2.fpga.fpgamanager import FPGAManager

from dnnweaver2.scalar.dtypes import FixedPoint


graph = dnnweaver2.benchmarks.get_graph('conv_tiny', train=False)

fpga_spec = dnnweaver2.compiler.FPGASpec(num_ddr=1, size_ddr=1024, bandwidth_per_ddr=512)
fpga_compiler = dnnweaver2.compiler.GraphCompiler(fpga_spec)

sram = {
    'ibuf': 16 * 32 * 512,
    'wbuf': 16 * 32 * 32 * 512,
    'obuf': 64 * 32 * 512,
    'bbuf': 16 * 32 * 512
}

acc_obj = dnnweaver2.simulator.accelerator.Accelerator(N=32, M=32, prec=16, mem_if_width=256, frequency=100e6,
                                                       sram=sram)
inst_array = fpga_compiler.compile(graph=graph, acc_obj=acc_obj)

# 1. design input featuremap, random
# options = {"model": "example/conf/tiny-yolo-voc.cfg", "load": "example/weights/tiny-yolo-voc.weights", "threshold": 0.25}
# tfnet = TFNet(options)
input_png = '/home/rbshi2/xun/code/dnn_weaver/example/test.jpg'
input_im = cv2.imread(input_png, cv2.IMREAD_COLOR)
h, w, _ = input_im.shape
# im = tfnet.framework.resize_input(input_im)
input_im = cv2.resize(input_im, (32, 32))
input_im = input_im / 255
im = input_im[:, :, ::-1]

tin = np.expand_dims(im, 0)


# 2.design weight kernel ,random
weight_filename='/home/rbshi2/xun/code/dnn_weaver/example/weights/yolo2_tiny_dnnweaver2_weights.pickle'
output_conv_weight='/home/rbshi2/xun/code/dnn_weaver/example/weights/conv_tiny_dnnweaver2_weights.pickle'
temp = collections.OrderedDict()
if not os.path.exists(output_conv_weight):
    with open(weight_filename, "rb") as h:
        params = pickle.load(h, encoding='latin1')
        temp["conv0/Convolution"] = params["conv0/Convolution"]
    with open(output_conv_weight, "wb") as handle:
        pickle.dump(temp, handle, protocol=pickle.HIGHEST_PROTOCOL)



# 3.run fpga inference and get output
out_tensors_d = collections.OrderedDict()
fxp_out_tensors_d = collections.OrderedDict()
fpga_manager = FPGAManager(pci_cl_ctrl_device="/dev/xdma0_user", c2h_dma_device="/dev/xdma0_c2h_0",
                               h2c_dma_device="/dev/xdma0_h2c_0")
fpga_manager.initialize_graph_tensors(graph)
graph.load_params_from_pickle(output_conv_weight)
fpga_manager.write('pci_cl_data', 0, inst_array)
fpga_manager.initialize_graph(graph, 32, 32)

start = time()
# tout = dnn_fpga.fpga_inference(fpga_manager, _tin)
fpga_manager.send_input_nparr(tin)
fpga_manager.start()
fpga_manager.wait_fpga_execution()
tout = fpga_manager.recv_output_nparr()
# fpga_manager.print_fpga_registers()  #?

end = time()
fps = 1.0 / (end - start)
fxp_tout = copy.deepcopy(tout)
tout = fxp16tofp32_tensor(tout, fpga_manager.get_tout_frac_bits())
out_tensors_d["conv8"] = [tout, fps, (end - start)]
fxp_out_tensors_d["conv8"] = [fxp_tout, fps, (end - start)]

print("out_tensors_d:{}\nfxp_out_tensors_d{}".format(out_tensors_d,fxp_out_tensors_d))


# 4.check output == ()
# TODO: tf result from pickle
correct_output_featuremap = None
print(tout == correct_output_featuremap)
