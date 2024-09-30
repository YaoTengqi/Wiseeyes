# set variables
set project_name {dnn_accl_vivado_prj}
set board_part xczu15eg-ffvb1156-2-i
set bd_path hw_handoff/dnn_accl_15eg_bd.tcl
set bd_name dnn_accl_15eg

# create vivado project
create_project ${project_name} ./${project_name} -part ${board_part}

# set ip repository
set_property ip_repo_paths {ip_repo/cl_wrapper} [current_project]
update_ip_catalog

# add block design, create hdl wrapper
source ${bd_path}
make_wrapper -files [get_files ${project_name}/${project_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
add_files -norecurse ${project_name}/${project_name}.srcs/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v
update_compile_order -fileset sources_1
