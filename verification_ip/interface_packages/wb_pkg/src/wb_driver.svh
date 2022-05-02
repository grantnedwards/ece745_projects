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

    task write(
    input bit [I2C_ADDR_WIDTH-1:0] addr,
    input bit [I2C_DATA_WIDTH-1:0] data []
    );
    reg [WB_DATA_WIDTH-1:0] temp;
    bus.master_write(CMDR, cmd_start);
    bus.wait_for_interrupt();
    bus.master_read(CMDR, temp);
    bus.master_write(DPR, addr << 1);
    bus.master_write(CMDR, cmd_write);
    bus.wait_for_interrupt();
    bus.master_read(CMDR, temp);
    foreach(data[i])begin
            bus.master_write(DPR, data[i]);
        bus.master_write(CMDR, cmd_write);
        bus.wait_for_interrupt();
        bus.master_read(CMDR, temp);
    end
        bus.master_write(CMDR, cmd_stop);
    bus.wait_for_interrupt();
    bus.master_read(CMDR, temp);
    endtask

    task read(
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
