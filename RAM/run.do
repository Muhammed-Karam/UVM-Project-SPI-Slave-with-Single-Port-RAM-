vlib work
vlog -f ram_src_files.list +cover -covercells +define+SIM
vsim -voptargs=+acc work.ram_top -classdebug -uvmcontrol=all -cover
add wave -position insertpoint sim:/ram_top/ram_if_inst/*
add wave -position insertpoint sim:/ram_top/DUT/*
add wave -position insertpoint sim:/ram_top/DUT/MEM
coverage save -onexit ram_coverage.ucdb
run -all
coverage report -detail -cvg -file ram_coverage_report.txt