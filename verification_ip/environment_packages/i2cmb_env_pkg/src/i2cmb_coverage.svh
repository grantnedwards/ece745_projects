class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

  i2cmb_env_configuration     configuration;
  T                   coverage_transaction;
  header_type_t         header_type;
  bit                   loopback;
  bit                   invert;

  covergroup i2cmb_coverage_cg;
  	option.per_instance = 1;
    option.name = get_full_name();
    //Will implement later when coverage is added to the scope of project fully
    // header_type: coverpoint header_type;
    // loopback:    coverpoint loopback;
    // invert:      coverpoint invert;
    // header_x_loopback: cross header_type, loopback;
    // header_x_invert:   cross header_type, invert;
  endgroup

  function void set_configuration(i2cmb_env_configuration cfg);
  	configuration = cfg;
  endfunction

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name,parent);
    i2cmb_coverage_cg = new;
  endfunction

  virtual function void nb_put(T trans);
    // $display({get_full_name()," ",trans.convert2string()});
    // header_type = header_type_t'(trans.header[63:60]);
    // loopback    = configuration.loopback;
    // invert      = configuration.invert;
    i2cmb_coverage_cg.sample();
  endfunction

endclass
