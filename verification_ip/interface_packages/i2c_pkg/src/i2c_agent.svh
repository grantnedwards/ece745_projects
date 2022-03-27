class i2c_agent extends ncsu_component;
    i2c_configuration configuration;
    i2c_driver driver;
    i2c_monitor monitor;
    ncsu_component #(T) subscribers[$];
    virtual i2c_if bus;

    function new(string name = "", ncsu_component #(T) parent = null);
        super.new(name,parent);
        if ( !(ncsu_config_db#(virtual i2c_if)::get(get_full_name(), this.bus))) begin;
            $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
            $finish;
        end
    endfunction

    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void build();
        driver = new("i2c_driver",this);
        driver.set_configuration(configuration);
        driver.build();
        driver.bus = this.bus;
        monitor = new("i2c_monitor",this);
        monitor.set_configuration(configuration);
        monitor.set_agent(this);
        monitor.enable_transaction_view = 1'b1;
        monitor.build();
        monitor.bus = this.bus;
    endfunction

    virtual task run();
        fork monitor.run(); join_none
    endtask

    virtual function void nb_put(T trans);
        foreach (subscribers[i]) subscribers[i].nb_put(trans);
    endfunction

    virtual task bl_put(T trans);
        driver.bl_put(trans);
    endtask

    virtual function void connect_subscriber(ncsu_component#(T) subscriber);
        subscribers.push_back(subscriber);
    endfunction

endclass
