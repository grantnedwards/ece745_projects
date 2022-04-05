class wb_driver extends ncsu_component#(.T(ncsu_transaction));
    virtual wb_if bus;
    wb_transaction transaction;
    wb_configuration configuration;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction
    //POTENTIAL ISSUES
    virtual task bl_put(T trans);
        $cast(transaction, trans);
        if(transaction.op) bus.master_read(transaction.addr, transaction.data);
        else begin
          bus.master_write(transaction.addr, transaction.data);
          if(transaction.addr == CMDR)begin
            bit [WB_DATA_WIDTH-1:0] tip;
            bus.wait_for_interrupt();
            bus.master_read(CMDR, tip);
          end
        end
    endtask

    reg [WB_DATA_WIDTH-1:0] mon_data;
    //*******************************************************
    //    Tasks - Defunct for debugging
    //*******************************************************
    task set_bus(input bit [WB_DATA_WIDTH-1:0] bus_num);
        bus.master_write(DPR, bus_num); //send bus number to DPR
        bus.master_write(CMDR, cmd_set_bus); //send set_bus command
    endtask
    //*******************************************************
    task start();
        wait_to_write(); // wait until irq is high
        bus.master_write(CMDR, cmd_start); // send command start
    endtask
    //*******************************************************
    task stop();
        wait_to_write(); // wait until irq is high
        bus.master_write(CMDR, cmd_stop); // send command stop
    endtask
    //*******************************************************
    task write(
                input bit [WB_DATA_WIDTH-1:0] address
            );
        wait_to_write();  // wait until irq is high
        bus.master_write(DPR, address); // send byte address to DPR
        bus.master_write(CMDR, cmd_write); // send write command
    endtask
    //*******************************************************
    task wait_to_write();
        bus.wait_for_interrupt();  // waiting until irq is high
        bus.master_read(CMDR, mon_data); // read the written data after waiting
    endtask


    task write_to_address(
    input bit [WB_DATA_WIDTH-1:0] address,input bit [WB_DATA_WIDTH-1:0] bus_num,
    input bit [WB_DATA_WIDTH-1:0] data

    );
          set_bus(bus_num);    //set bus
          start();          // enable start command

          write(address);     // write in byte 0x44
          write(data);     // write in byte 0x78
          stop();           // enable stop command
          //wait_to_write();  // iterates until irq is high, reads value

    endtask


    task read_to_address(
        input bit [I2C_ADDR_WIDTH-1:0] addr,
        output bit [I2C_DATA_WIDTH-1:0] data[],
        input int line
    );

        bit [WB_DATA_WIDTH-1:0] temp;
        data = new[line];
        bus.master_write(CMDR, cmd_start);
        bus.wait_for_interrupt();
        bus.master_read(CMDR, temp);
        temp = addr << 1;
        temp[0] = 1'b1;
        bus.master_write(DPR, temp);
        bus.master_write(CMDR, cmd_write);
        bus.wait_for_interrupt();
        bus.master_read(CMDR, temp);
        foreach(data[i])begin
            bus.master_write(CMDR, cmd_read_ack);
            bus.wait_for_interrupt();
            bus.master_read(DPR, temp);
            data[i] = temp;
            bus.master_read(CMDR, temp);
        end
        bus.master_write(CMDR, cmd_stop);
        bus.wait_for_interrupt();
        bus.master_read(CMDR, temp);


    endtask

endclass
