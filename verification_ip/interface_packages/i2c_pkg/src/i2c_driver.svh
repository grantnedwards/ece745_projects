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
            bus.wait_for_i2c_transfers(transaction.op, transaction.data);
          end
          begin
            bus.provide_read_data(transaction.data, transfer_complete);
          end
          begin

              for(int i = 0; i<33; i++)begin
                bus.address_burst();
              end

              bus.flag=1'b1;
              bus.address_burst();
              for(int i = 0; i<32; i++)begin
                bus.extract();
                wait(bus.scl_i);
              end
              bus.address_burst();
              wait(bus.scl_i);
              bus.address_burst();
              wait(bus.scl_i);
              // bus.extract();
              // wait(bus.scl_i);

              // wait(bus.scl_i);
              // for(int i = 0; i<64; i++)begin
              //   bus.flag=1'b0;
              //   bus.address_burst();
              //   bus.flag=1'b1;
              //   bus.address_burst();
              //   bus.extract();
              //   wait(bus.scl_i);
              // end

              // /bus.extract();
              // bus.flag=1'b1;






            end

        join
        else bus.wait_for_i2c_transfers(transaction.op, transaction.data);
    endtask

endclass
