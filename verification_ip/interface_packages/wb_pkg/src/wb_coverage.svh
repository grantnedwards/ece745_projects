class wb_coverage extends ncsu_component#(.T(wb_transaction));
  bit [WB_DATA_WIDTH-1:0] wb_data;
  bit [WB_ADDR_WIDTH-1:0] wb_offsets;
  i2c_op_t wb_operations;
  wb_configuration wb_config;

  covergroup coverage_wb_cg;
    option.per_instance = 1;
    option.name = get_full_name();
    coverpoint wb_data{
      bins datum [32] = {[0:$]};
    }
    coverpoint wb_offsets{
      bins offs [1] = {[0:$]};
    }
    coverpoint wb_operations {
      bins writes_wb = {WRITE};
      bins reads_wb = {READ};
    }
    wb_operations_x_wb_data_x_wb_offsets: cross wb_operations, wb_data, wb_offsets{
      ignore_bins ignore_reads = binsof(wb_operations.reads_wb);
    }
  endgroup

  function void set_configuration(wb_configuration cfg);
    wb_config = cfg;
  endfunction

  function new(string name = "", ncsu_component_base parent =null);
    super.new(name, parent);
    coverage_wb_cg = new;
  endfunction

  virtual function void nb_put(T trans);
    wb_data = trans.data;
    wb_offsets = trans.burst;
    wb_operations = trans.op;
    coverage_wb_cg.sample();
  endfunction


endclass
