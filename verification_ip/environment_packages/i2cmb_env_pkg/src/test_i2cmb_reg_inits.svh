class test_i2cmb_reg_inits extends ncsu_component;
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
  reg [WB_DATA_WIDTH-1:0] data;
  gen.wb_agents.bus.master_write(CSR, 8'b0xxxxxxx);
  gen.wb_agents.bus.wait_for_reset();
  gen.wb_agents.bus.master_read(CSR, data);
  if(~data)$display("CSR PASS - val %h", data); else $error("CSR FAIL");
  gen.wb_agents.bus.master_read(DPR, data);
  if(~data)$display("DPR PASS - val %h", data); else $error("DPR FAIL");
  gen.wb_agents.bus.master_read(CMDR, data);
  if(~data)$display("CMDR PASS - val %h", data); else $error("CMDR FAIL");
  gen.wb_agents.bus.master_read(FSMR, data);
  if(~data)$display("FSMR PASS - val %h", data); else $error("FSMR FAIL");
  //gen.transfer();
  run();
endtask
endclass
