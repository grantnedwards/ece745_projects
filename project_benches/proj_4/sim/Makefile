export ECE745_PROJECT_HOME ?= $(PWD)/../../..


include $(ECE745_PROJECT_HOME)/verification_ip/data_types_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

# GEN_TRANS_TYPE ?= i2cmb_test
# GEN_TRANS_TYPE ?= i2cmb_test_random
# GEN_TRANS_TYPE ?= test_i2cmb_reads
# GEN_TRANS_TYPE ?= test_i2cmb_reg_addrs
# GEN_TRANS_TYPE ?= test_i2cmb_reg_inits
# GEN_TRANS_TYPE ?= test_i2cmb_two_starts
# GEN_TRANS_TYPE ?= test_i2cmb_two_stops
# GEN_TRANS_TYPE ?= test_i2cmb_write_before_data
# GEN_TRANS_TYPE ?= test_i2cmb_writes

TEST_SEED ?= 12345

clean:
	rm -rf work *.wlf transcript

comp_I2C_MB:
	vcom -cover bcefst ../rtl/iicmb_int_pkg.vhd
	vcom -cover bcefst ../rtl/iicmb_pkg.vhd
	vcom -cover bcefst ../rtl/mbyte.vhd
	vcom -cover bcefst ../rtl/mbit.vhd
	vcom -cover bcefst ../rtl/bus_state.vhd
	vcom -cover bcefst ../rtl/filter.vhd
	vcom -cover bcefst ../rtl/conditioner.vhd
	vcom -cover bcefst ../rtl/conditioner_mux.vhd
	vcom -cover bcefst ../rtl/iicmb_m.vhd
	vcom -cover bcefst ../rtl/regblock.vhd
	vcom -cover bcefst ../rtl/wishbone.vhd
	vcom -cover bcefst ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_types_pkg comp_i2c_pkg comp_i2c_pkg_pkg comp_wb_pkg comp_wb_pkg_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_layered_test_plan.xml ./i2cmb_layered_test_plan.ucdb
	add testbrowser ./*.ucdb

merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb
	coverage open ./sim_and_testplan_merged.ucdb

merge_testplan: #README: RUN THIS FOR PROJECT 3 RESULTS
	vsim -sv_seed $(TEST_SEED) -do "do things.do"

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

run_cli:
	vsim  -c -sv_seed $(TEST_SEED) -coverage -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

run_gui:
	vsim -sv_seed $(TEST_SEED) -coverage -do "do wave.do;run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: clean compile optimize run_cli

debug: clean compile simulate
