class i2cmb_generator extends ncsu_component;
   i2c_transaction i2c_transactions[];
   i2c_transaction wb_transactions[];
   i2c_agent i2c_agents;
   wb_agent wb_agents;
   string trans_name;

   function new(string name = "", ncsu_component #(T) parent = null); 
       super.new(name,parent);
       if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
           $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
           $fatal;
           end
      $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
   endfunction

   virtual task run();
    fork
        foreach(wb_transactions[i]) wb_agents.bl_put(wb_transactions[i]);
        foreach(i2c_transactions[i]) i2c_agents.bl_put(i2c_transactions[i]);
    join
   endtask

    function void set_i2c_agent(i2c_agent agent);
        this.i2c_agent_0 = agent;
    endfunction

    function void set_i2c_transactions(i2c_transaction trans []);
        this.i2c_transactions = trans;
    endfunction

    
    function void set_wb_agent(wb_agent agent);
        this.wb_agent_0 = agent;
    endfunction

    function void set_wb_transactions(i2c_transaction trans []);
        this.wb_transactions = trans;
    endfunction



endclass
