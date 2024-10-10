prj_path=dnn_accl_vivado_prj/dnn_accl_vivado_prj.xpr
if [ ! -f $prj_path ]; then
    echo "项目文件不存在，创建新的vivado项目..."
    vivado -nolog -nojournal -source run_vivado.tcl
else
    echo "打开项目文件..."
    vivado -nojournal -nolog $prj_path
fi
