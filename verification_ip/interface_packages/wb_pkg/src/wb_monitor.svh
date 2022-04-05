class wb_monitor extends ncsu_component#(.T(wb_transaction));

  wb_configuration  configuration;
  virtual wb_if bus;
  wb_transaction transaction;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null);
      super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
      configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
      this.agent = agent;
  endfunction

  virtual task run ();
    bus.wait_for_reset();
      forever begin
        bit write_enable;
        transaction = new("WB Monitors");
        if (enable_transaction_viewing) transaction.start_time = $time;
        bus.master_monitor(transaction.addr,
                    transaction.data,
                    write_enable
                    );

        agent.nb_put(transaction);
        if(enable_transaction_viewing) begin
           transaction.end_time = $time;
           transaction.add_to_wave(transaction_viewing_stream);
        end
    end
  endtask
endclass
