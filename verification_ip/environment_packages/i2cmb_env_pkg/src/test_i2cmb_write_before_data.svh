class test_i2cmb_write_before_data extends ncsu_component;
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
      write_data = new[1];
      write_data[0] = 11;
      $display("================....INITIALIZING....================");
      gen.initialize(1'b0);         //Place bus number here
      gen.hung_write(8'h22, write_data);
      $display("================Ascend Writes================");
      gen.starter();
      gen.transfer();
      run();
    endtask
endclass
