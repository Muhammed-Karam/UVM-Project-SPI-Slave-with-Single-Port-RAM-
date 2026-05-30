vlib work
vlog -f spi_src_files.list +cover -covercells +define+SIM
vsim -voptargs=+acc work.spi_slave_top -classdebug -uvmcontrol=all -cover
add wave -position insertpoint sim:/spi_slave_top/spi_if/*
add wave -position insertpoint sim:/spi_slave_top/DUT/*
coverage save -onexit spi_slave_coverage.ucdb
run -all
coverage report -detail -cvg -file spi_slave_coverage_report.txt