class i2cmb_environment extends ncsu_component#(.T(wb_transaction));

  i2cmb_env_configuration configuration;
  i2c_agent         i2c_agents;
  wb_agent          wb_agents;
  i2cmb_predictor         pred;
  i2cmb_scoreboard        scbd;
  i2cmb_coverage          cvg;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    i2c_agents = new("i2c_agents",this);
    i2c_agents.set_configuration(configuration.i2c_config);
    i2c_agents.build();
    wb_agents = new("wb_agents",this);
    wb_agents.set_configuration(configuration.wishbone_config);
    wb_agents.build();
    pred  = new("pred", this);
    pred.set_configuration(configuration);
    pred.build();
    scbd  = new("scbd", this);
    scbd.build();
    cvg = new("cvg", this);
    cvg.set_configuration(configuration);
    cvg.build();
    wb_agents.connect_subscriber(cvg);
    wb_agents.connect_subscriber(pred);
    pred.set_scoreboard(scbd);
    i2c_agents.connect_subscriber(scbd);
  endfunction

  function i2c_agent get_i2c_agent();
    return i2c_agents;
  endfunction

  function wb_agent get_wb_agent();
    return wb_agents;
  endfunction

  virtual task run();
     i2c_agents.run();
     wb_agents.run();
  endtask

endclass
