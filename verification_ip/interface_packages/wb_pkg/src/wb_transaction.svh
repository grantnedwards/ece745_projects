class wb_transaction extends ncsu_transaction;

    bit [WB_DATA_WIDTH-1:0] addr;
    bit [WB_DATA_WIDTH-1:0] data;
    i2c_op_t                  op;
    int burst;

    // covergroup coverage_wb_cg();
    //     option.per_instance = 1;
    //     //option.name = get_full_name();
    //     coverpoint op;
    //     coverpoint data;
    //     coverpoint burst;
    //     op_x_data_x_burst: cross op, data, burst;
    // endgroup

    function new(string                 name = "",
                bit [WB_ADDR_WIDTH-1:0] addr = 0,
                i2c_op_t                op = WRITE
                );
        super.new(name);
        this.addr = addr;
        this.op = op;
        //coverage_wb_cg = new;
    endfunction

    virtual function string convert2string();
       return {super.convert2string(),$sformatf("address: 0x%h data: 0x%h op: %s", addr, data, (op)?"READ":"WRITE")};
    endfunction
    //
    // function bit compare(wb_transaction rhs);
    //     return ((this.addr  == rhs.addr ) &&
    //         (this.data == rhs.data) &&
    //         (this.we == rhs.we) );
    // endfunction
    //
    virtual function void add_to_wave(int transaction_viewing_stream_h);
        super.add_to_wave(transaction_viewing_stream_h);
        $add_attribute(transaction_view_h, op, "op");
        $add_attribute(transaction_view_h, addr, "addr");
        $add_attribute(transaction_view_h, data, "data");
        $end_transaction(transaction_view_h, end_time);
        $free_transaction(transaction_view_h);
    endfunction
endclass
