class i2c_coverage extends ncsu_component#(.T(i2c_transaction));
  i2c_configuration cfg_main;
  T trans;
  bit [I2C_DATA_WIDTH-1:0] i2c_data;
  bit [I2C_ADDR_WIDTH-1:0] i2c_address;
  bit [I2C_DATA_WIDTH-1:0] temp;
  int burst;
  i2c_op_t i2c_operations;
  int bus;

  covergroup coverage_i2c_cg;
      option.per_instance = 1;
      option.name = get_full_name();
      coverpoint i2c_data{
        bins datums [2] = {[0:$]};
      }
      coverpoint i2c_address{
        bins addrs [2] = {[0:$]};
      }
      coverpoint i2c_operations{
        bins writes = {WRITE};
        bins reads = {READ};
      }
      i2c_operations_x_i2c_data_x_i2c_address: cross i2c_operations, i2c_data, i2c_address{
        //ignore_bins
      }
  endgroup

  function void set_configuration(i2c_configuration cfg);
    cfg_main = cfg;
  endfunction

  function new(string name = "", ncsu_component_base parent =null);
    super.new(name, parent);
    coverage_i2c_cg = new;
  endfunction

  virtual function void nb_put(T trans);
    i2c_address = trans.addr;
    i2c_data = trans.data[0];
    i2c_operations = trans.op;
    coverage_i2c_cg.sample();
  endfunction


endclass
