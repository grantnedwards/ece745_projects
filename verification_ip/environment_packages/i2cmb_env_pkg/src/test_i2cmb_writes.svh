class test_i2cmb_writes extends ncsu_component;
  i2cmb_env_configuration       cfg;
  i2cmb_environment             env;
  i2cmb_generator               gen;

  class rand_round;
    rand bit [1:0] a;
    rand bit [7:0] b;
  endclass
  rand_round bloat;

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
  bit [WB_DATA_WIDTH-1:0] data;
  write_data = new[1];
  write_data[0] = 11;
  $display("================....INITIALIZING....================");
  gen.initialize(1'b0);         //Place bus number here
  gen.rep_write(8'h22, write_data);
  gen.wb_agents.bus.master_read(DPR, data);
  $display("data = %h", data);
  gen.wb_agents.bus.master_read(CMDR, data);
  if(data==8'h80)$display("CMDR value matched"); else $error("CMDR FAIL");
  $display("data = %h", data);
  gen.wb_agents.bus.master_read(FSMR, data);
  $display("data = %h", data);
  gen.wb_agents.bus.master_read(CSR, data);
  $display("data = %h", data);
  gen.starter();
  gen.transfer();

  bloat = new();
  gen.initialize(1'b0);
  for(int i = 0; i<1024; i++)begin
    bloat.randomize();
    gen.wb_agents.bus.master_write(bloat.a, bloat.b);
    gen.ender();
  end

  run();
endtask
endclass
