vlib work
vlog -f wrapper_src_files.list +cover -covercells +define+SIM
vsim -voptargs=+acc work.wrapper_top -classdebug -uvmcontrol=all -cover
add wave /wrapper_top/wrapper_if_inst/*
add wave /wrapper_top/spi_if_inst/*
add wave /wrapper_top/ram_if_inst/*
add wave -position insertpoint  \
sim:/wrapper_top/DUT/SLAVE_instance/cs \
sim:/wrapper_top/DUT/SLAVE_instance/ns
add wave -position insertpoint  \
sim:/wrapper_top/DUT/RAM_instance/MEM
coverage save -onexit spi_wrapper_coverage.ucdb
run -all
coverage exclude -du RAM -togglenode {MEM}
coverage report -detail -cvg -file spi_wrapper_coverage_report.txt