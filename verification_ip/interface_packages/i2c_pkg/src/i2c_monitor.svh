class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration  configuration;
  virtual i2c_if bus;
  i2c_transaction transaction;
  i2c_transaction monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null);
      super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
      configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
      this.agent = agent;
  endfunction

  virtual task run ();
      forever begin
        monitored_trans = new("i2c_monitor");
        transaction = new("interstitial");
        bus.monitor(monitored_trans.addr,
                    monitored_trans.op,
                    monitored_trans.data
                    );
        monitored_trans.burst = monitored_trans.data.size();
        agent.nb_put(monitored_trans);
    end
  endtask

  endclass
