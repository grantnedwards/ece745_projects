xml2ucdb -format Excel ./i2cmb_layered_test_plan.xml i2cmb_layered_test_plan.ucdb;
add testbrowser ./*.ucdb;
vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb;
coverage open ./sim_and_testplan_merged.ucdb;
