class wb_transaction extends ncsu_transaction;
    bit [I2C_ADDR_WIDTH-1:0] addr;
    bit [I2C_DATA_WIDTH-1:0] data [];
    i2c_op_t op;
    int bus;
    int burst;

    function new(string name="",
                 int                        bus = 0,
                 bit [I2C_ADDR_WIDTH-1:0]   addr = 0,
                 int                        burst = 0,
                 i2c_op_t                   op = WRITE
                );
        super.new(name);
        this.addr = addr;
        this.burst = burst;
        this.bus = bus;
        this.op = op;
    endfunction

    virtual function string convert2string();
       return {super.convert2string(),$sformatf("bus: %d address: 0x%h data: 0x%h op: %s", bus, addr, data, (op)?"READ":"WRITE")};
    endfunction

    function void set(bit [I2C_DATA_WIDTH-1:0] data []);
        this.data = data;
        burst = data.size();
    endfunction
endclass