class test_i2cmb_two_stops extends ncsu_component;
    i2cmb_env_configuration       cfg;
    i2cmb_environment             env;
    i2cmb_generator               gen;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
  endfunction

  function void construct(); //constructs overall testbench environment
    cfg = new("cfg");
    cfg.sample_coverage();
    env = new("env",this);
    env.set_configuration(cfg);
    env.build();
    gen = new("gen",this);
    gen.set_i2c_agent(env.get_i2c_agent());
    gen.set_wb_agent(env.get_wb_agent());
  endfunction

  virtual task run();
     env.run();
     gen.run();
  endtask

  virtual task execute(); //Executes contents separately
    bit [7:0] write_data[];
    write_data = new[4];
    write_data[0] = 11;
    write_data[1] = 22;
    write_data[2] = 33;
    write_data[3] = 44;
    $display("================....INITIALIZING....================");
    gen.initialize(1'b0);         //Place bus number here
    $display("================Ascend Writes================");
    gen.write_transactions(8'h22, write_data);
    gen.ender();
    gen.transfer();
    run();
  endtask
endclass
