transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/sync_diff.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/num_convert.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/my_multiplier.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/matrix_ram.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/data_generator_pack.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/Components_Pkg.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/bin2bcd_12bit_sync.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/bcd_to_7seg.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/ALL_Components_Pkg.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/main_controller.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/mult_matrices.vhd}
vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/src/data_generator.vhd}

vcom -93 -work work {C:/Intel/VHDL/FINAL_V5/par/../src/matrices_mult_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  matrices_mult_tb

add wave *
view structure
view signals
run -all
