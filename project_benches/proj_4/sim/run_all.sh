
rm -rf *.udcb
make cli GEN_TRANS_TYPE=i2cmb_test TEST_SEED=12345
make cli GEN_TRANS_TYPE=i2cmb_test_random TEST_SEED=12345
make cli GEN_TRANS_TYPE=test_i2cmb_reads TEST_SEED=random
make cli GEN_TRANS_TYPE=test_i2cmb_writes TEST_SEED=random
make cli GEN_TRANS_TYPE=test_i2cmb_write_before_data TEST_SEED=random
make cli GEN_TRANS_TYPE=test_i2cmb_reg_addrs TEST_SEED=12345
make cli GEN_TRANS_TYPE=test_i2cmb_reg_inits TEST_SEED=12345
make cli GEN_TRANS_TYPE=test_i2cmb_two_starts TEST_SEED=12345
make cli GEN_TRANS_TYPE=test_i2cmb_two_stops TEST_SEED=12345
make merge_testplan

