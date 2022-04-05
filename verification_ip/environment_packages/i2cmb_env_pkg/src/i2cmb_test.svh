class i2cmb_test extends ncsu_component;

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
    bit [7:0] write_dbl[][];
    bit [7:0] read_data[];
    bit [7:0] read_dbl[][];
    write_data = new[32];
    write_dbl = new[64];
    read_data = new[32];
    read_dbl = new[64];
    for(int i=0; i<32; i++) begin
      write_data[i] = i;
      read_data[i] = 100 + i;
    end
    for(int i=0; i<64; i++) begin
      write_dbl[i] = new[1];
      write_dbl[i][0] = 64 + i;
      read_dbl[i] = new[1];
      read_dbl[i][0] = 63 - 1;
    end
    $display("================....INITIALIZING....================");
    gen.initialize(1'b0);         //Place bus number here
    $display("================32 Writes================");
    gen.write_transactions(8'h22, write_data); // Write 32 values
    $display("================32 Reads=================");
    gen.read_transactions(8'h22, read_data);  // Read 32 values


    //interleaved write and read
    $display("================Alternating Reads and Writes================");
     for(int i=0; i<64; i++)begin
       gen.write_transactions(8'h22, write_dbl[i]);
       gen.read_transactions(8'h22, read_dbl[i]);
     end

gen.transfer();

  endtask
endclass
