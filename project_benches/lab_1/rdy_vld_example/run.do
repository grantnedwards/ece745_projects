vlog ready_valid_if.sv
vlog ready_valid_dut.sv
vlog top.sv
vsim -i -voptargs=+acc -do "do wave.do; run 500ns" top
