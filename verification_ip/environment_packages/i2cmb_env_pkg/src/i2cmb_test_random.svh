class i2cmb_test_random extends ncsu_component;
  class random_trans;
    rand bit [I2C_ADDR_WIDTH-1:0]a;
    rand bit [I2C_DATA_WIDTH-1:0]b[7];
  endclass
  i2cmb_env_configuration       cfg;
  i2cmb_environment             env;
  i2cmb_generator               gen;
  random_trans trans;


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
  trans = new();
  gen.initialize(1'b0);
  for(int i = 0; i < 1024; i++)begin
    trans.randomize();
    $display(trans.a);
    gen.write_transactions(trans.a, trans.b);
    //gen.read_transactions(trans.a, trans.b);
  end
  for(int i = 0; i < 64; i++)begin
    trans.randomize();
    $display(trans.a);
    gen.read_transactions(trans.a, trans.b);
  end
  gen.transfer();

  run();
endtask
endclass
