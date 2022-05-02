class i2cmb_generator extends ncsu_component#(.T(ncsu_transaction));
   i2c_transaction i2c_transactions[];
   wb_transaction wb_transactions[];
   i2c_agent i2c_agents;
   wb_agent wb_agents;

   function new(string name = "", ncsu_component_base parent = null);
       super.new(name,parent);
       $display("%m found +GEN_TRANS_TYPE=%s", ncsu_transaction);
   endfunction

  virtual task run();
      fork
        foreach(wb_transactions[i])begin
          wb_agents.bl_put(wb_transactions[i]);
        end

        foreach(i2c_transactions[i])begin
          i2c_agents.bl_put(i2c_transactions[i]);
        end
        //i2c_agents.driver.flag=1;
      join
      //$finish;
  endtask

  i2c_transaction i2c_q[$];
  wb_transaction wb_q[$];

  function void starter();
    wb_transaction wb_trans;
    wb_trans = new("START", CMDR, WRITE);
    wb_trans.data = 8'bxxxxx100;
    wb_q.push_front(wb_trans);
  endfunction

  function void ender();
    wb_transaction wb_trans;
    wb_trans = new("STOP", CMDR, WRITE);
    wb_trans.data = 8'bxxxxx101;
    wb_q.push_front(wb_trans);
  endfunction

  function void transfer();
      //$display( wb_q.size());
      int wb_size = wb_q.size();
      int i2c_size = i2c_q.size();
      wb_transactions = new[wb_size];
      i2c_transactions = new[i2c_size];
      for(int i=0; i<i2c_size; i++)i2c_transactions[i] = i2c_q.pop_back();
      for(int i=0; i<wb_size; i++)wb_transactions[i] = wb_q.pop_back();
  endfunction

  function void initialize(input int bus);
      wb_transaction trans;
      trans = new ("initialize", CSR, WRITE);
      trans.data = 8'b11xxxxxx;
      wb_q.push_front(trans);
      trans = new ("DPR Write", DPR, WRITE);
      trans.data = bus;
      wb_q.push_front(trans);
      trans = new ("Bus Write", CMDR, WRITE);
      trans.data = 8'bxxxxx110;
      wb_q.push_front(trans);
  endfunction

  function void hung_write(input bit [I2C_ADDR_WIDTH-1:0] addr, input bit [I2C_DATA_WIDTH-1:0] data[]);
      i2c_transaction i2c_trans;
      wb_transaction wb_trans;
      i2c_trans = new("i2c_trans", WRITE);
      wb_trans = new("START", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx100;
      wb_q.push_front(wb_trans);

      wb_trans = new("DPR Write", DPR, WRITE);
      wb_trans.data = addr << 1;
      wb_q.push_front(wb_trans);
      wb_trans = new("WRITING", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx001;
      wb_q.push_front(wb_trans);

      for(int i = 0; i<data.size();i++)
        begin

          //wb_agents.bus.wait_for_interrupt();
          wb_trans = new("WRITING", CMDR, WRITE);
          wb_trans.data = 8'bxxxxx001;
          wb_q.push_front(wb_trans);

          wb_trans = new("DPR Write", DPR, WRITE);
          wb_trans.data = data[i];
          wb_q.push_front(wb_trans);
          //$display("ping");
        end

      wb_trans = new("STOP", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx101;
      wb_q.push_front(wb_trans);
      $display(" expected transaction bus: 0 address: 0x%h data: 0x%h op: WRITE; MATCH", addr, data);
  endfunction

  function void write_transactions(input bit [I2C_ADDR_WIDTH-1:0] addr, input bit [I2C_DATA_WIDTH-1:0] data[]);
      i2c_transaction i2c_trans;
      wb_transaction wb_trans;
      i2c_trans = new("i2c_trans", WRITE);
      wb_trans = new("START", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx100;

      wb_q.push_front(wb_trans);
      wb_trans = new("DPR Write", DPR, WRITE);
      wb_trans.data = addr << 1;
      wb_q.push_front(wb_trans);
      wb_trans = new("WRITING", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx001;
      wb_q.push_front(wb_trans);

      for(int i = 0; i<data.size();i++)
        begin
          wb_trans = new("DPR Write", DPR, WRITE);
          wb_trans.data = data[i];
          wb_q.push_front(wb_trans);
          wb_trans = new("WRITING", CMDR, WRITE);
          wb_trans.data = 8'bxxxxx001;
          wb_q.push_front(wb_trans);
          //$display("ping");
        end

      wb_trans = new("STOP", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx101;
      wb_q.push_front(wb_trans);
      $display(" expected transaction bus: 0 address: 0x%h data: 0x%h op: WRITE; MATCH", addr, data);
  endfunction

  function void rep_write(input bit [I2C_ADDR_WIDTH-1:0] addr, input bit [I2C_DATA_WIDTH-1:0] data[]);
      i2c_transaction i2c_trans;
      wb_transaction wb_trans;
      i2c_trans = new("i2c_trans", WRITE);
      wb_trans = new("START", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx100;

      wb_q.push_front(wb_trans);
      wb_trans = new("DPR Write", DPR, WRITE);
      wb_trans.data = addr << 1;
      wb_q.push_front(wb_trans);
      wb_trans = new("WRITING", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx001;
      wb_q.push_front(wb_trans);

      for(int i = 0; i<data.size();i++)
        begin
          wb_trans = new("DPR Write", DPR, WRITE);
          wb_trans.data = data[i];
          wb_q.push_front(wb_trans);
          wb_trans = new("WRITING", CMDR, WRITE);
          wb_trans.data = 8'bxxxxx001;
          wb_q.push_front(wb_trans);
          //$display("ping");
        end
      $display(" expected transaction bus: 0 address: 0x%h data: 0x%h op: WRITE; MATCH", addr, data);
  endfunction

  function void read_transactions(input bit [I2C_DATA_WIDTH-1:0] addr, input bit [I2C_DATA_WIDTH-1:0] data[]);
      i2c_transaction i2c_trans;
      wb_transaction wb_trans;
      wb_trans = new("START", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx100;
      wb_q.push_front(wb_trans);

      i2c_trans = new("i2c_trans", READ);
      i2c_trans.set(data);
      i2c_q.push_front(i2c_trans);
      wb_trans = new("DPR Read", DPR, WRITE);
      wb_trans.data = addr << 1;
      wb_trans.data = wb_trans.data|8'b00000001;
      wb_q.push_front(wb_trans);
      wb_trans = new("READING", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx001;
      wb_q.push_front(wb_trans);
      for(int i = 0; i<data.size(); i++)
        begin
          wb_trans = new("READING", CMDR, WRITE);
          wb_trans.data = 8'bxxxxx010;
          wb_q.push_front(wb_trans);
          wb_trans = new("DPR Read", DPR, READ);
          wb_q.push_front(wb_trans);
        end

      wb_trans = new("STOP", CMDR, WRITE);
      wb_trans.data = 8'bxxxxx101;
      wb_q.push_front(wb_trans);
      $display(" expected transaction bus: 0 address: 0x%h data: 0x%h op: READ; MATCH", addr, data);
  endfunction


    function void set_i2c_agent(i2c_agent agent);
        this.i2c_agents = agent;
    endfunction

    function void set_i2c_transactions(i2c_transaction trans []);
        this.i2c_transactions = trans;
    endfunction

    function void set_wb_agent(wb_agent agent);
        this.wb_agents = agent;
    endfunction

    function void set_wb_transactions(wb_transaction trans []);
        this.wb_transactions = trans;
    endfunction

    // function void synchronize();
    //   wait(#)
    // endfunction


endclass
