class i2c_driver extends ncsu_component#(.T(ncsu_transaction));
    virtual i2c_if bus;
    i2c_configuration configuration;
    i2c_transaction transaction;

    function new(string name = "", ncsu_component #(T) parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    virtual task bl_put(T trans);
        bit transfer_complete;
        $cast(transaction, trans);
        $display({get_full_name(), transaction.convert2string()});

        bus.provide_read_data(transaction.data, transfer_complete);
    endtask

endclass
