class i2c_driver extends ncsu_component#(.T(ncsu_transaction));
    i2c_configuration configuration;
    i2c_transaction transaction;
    virtual i2c_if bus;
    int blah =0;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    virtual task bl_put(T trans);
        bit transfer_complete;
        $cast(transaction, trans);
        if(!transaction.op)
        fork
          begin
            bus.provide_read_data(transaction.data, transfer_complete);   
          end
          begin
            bus.wait_for_i2c_transfers(transaction.op, transaction.data);
          end
        join
        else bus.wait_for_i2c_transfers(transaction.op, transaction.data);
    endtask

endclass
