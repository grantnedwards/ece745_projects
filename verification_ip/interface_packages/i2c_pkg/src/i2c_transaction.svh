class i2c_transaction extends ncsu_transaction;
    bit [I2C_ADDR_WIDTH-1:0] addr;
    bit [I2C_DATA_WIDTH-1:0] data [];
    i2c_op_t op;
    int bus;
    int burst;
    bit transfer_complete;

    function new(string name="",
                 i2c_op_t                        op = WRITE,
                 bit [I2C_ADDR_WIDTH-1:0]   addr = 0,
                 int                           bus = 0
                );
        super.new(name);
        this.addr = addr;
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

    function bit compare(i2c_transaction rhs);
        if (this.burst != rhs.burst) return 0;
        if (this.addr != rhs.addr) return 0;
        for (int i = 0; i < this.burst; i++) if (this.data[i] != rhs.data[i]) return 0;
        if (this.op != rhs.op) return 0;
        if (this.bus != rhs.bus) return 0;
        return 1;
    endfunction

endclass
