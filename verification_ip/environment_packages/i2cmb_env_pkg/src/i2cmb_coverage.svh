class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

  i2cmb_env_configuration     configuration;
  T                   coverage_transaction;
  header_type_t         header_type;
  bit                   loopback;
  bit                   invert;

  bit writes;
  bit waits;
  bit bus_sets;

  covergroup coverage_fsm_cg;
  	option.per_instance = 1;
    option.name = get_full_name();
    writes: coverpoint writes;
    waits: coverpoint waits;
    bus_sets: coverpoint bus_sets;
    //coverpoint writes;
    ///coverpoint waits;
    //coverpoint bus_sets;
  endgroup

  covergroup i2cmb_coverage_cg;
  	option.per_instance = 1;
    option.name = get_full_name();
    //coverpoint writes;
    ///coverpoint waits;
    //coverpoint bus_sets;
  endgroup

  // property i2cmb_arbitration;
  // endproperty

  // assert property(i2cmb_arbitration);
  // cover property(i2cmb_arbitration);

  function void set_configuration(i2cmb_env_configuration cfg);
  	configuration = cfg;
  endfunction

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name,parent);
    i2cmb_coverage_cg = new;
    coverage_fsm_cg = new;
  endfunction

  virtual function void nb_put(T trans);
    writes = trans.data;
    waits = trans.data;
    bus_sets = trans.burst;
    //$display({get_full_name()," ",trans.convert2string()});
    // header_type = header_type_t'(trans.header[63:60]);
    // loopback    = configuration.loopback;
    // invert      = configuration.invert;
    coverage_fsm_cg.sample();
    i2cmb_coverage_cg.sample();
  endfunction

endclass
