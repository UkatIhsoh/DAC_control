
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name DAC_control -dir "E:/hoshino_Data/SotsuKen/ISE/DAC_control/planAhead_run_2" -part xc6slx9tqg144-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "MCP4726_ctrl.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ipcore_dir/DCMto100k.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {MCP4726_ctrl.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top MCP4726_ctrl $srcset
add_files [list {MCP4726_ctrl.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-2
