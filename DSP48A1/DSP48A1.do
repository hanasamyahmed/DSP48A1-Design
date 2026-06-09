vlib work
vlog BLOCK.V DSP48A1.v tb_DSP.v
vsim -voptargs=+acc work.tb_DSP48A1
add wave *
run -all
#quit -sim