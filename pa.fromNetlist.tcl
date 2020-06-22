
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name DAC_control -dir "E:/hoshino_Data/SotsuKen/ISE/DAC_control/planAhead_run_3" -part xc6slx9tqg144-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "E:/hoshino_Data/SotsuKen/ISE/DAC_control/MCP4726_ctrl.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/hoshino_Data/SotsuKen/ISE/DAC_control} {ipcore_dir} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "MCP4726_ctrl.ucf" [current_fileset -constrset]
add_files [list {MCP4726_ctrl.ucf}] -fileset [get_property constrset [current_run]]
link_design
