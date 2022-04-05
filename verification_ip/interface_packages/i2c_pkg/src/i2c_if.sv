import data_types_pkg::*;
interface i2c_if        #(
    int I2C_ADDR_WIDTH = 7,
    int I2C_DATA_WIDTH = 8      )
(
    input triand scl_i,
    input triand sda_i,
    output triand scl_o,
    output triand sda_o
);

///////////
bit start = 1'bx;
bit [I2C_DATA_WIDTH+1] captured_burst;
i2c_op_t op;
i2c_state_t state;
bit flag = 1'b0;

i2c_op_t test_op;
reg sda_reg =1'b1;
reg sda_reg2 = 1'b0;
logic sda_enable = 1'b0;
bit [I2C_DATA_WIDTH] burst_queue[$];
bit [I2C_DATA_WIDTH] read_queue[$];
assign sda_o = sda_reg ? 1'bz : 1'b0;

/////////////////////
bit start_mon = 1'bx;
bit [I2C_DATA_WIDTH+1] captured_burst_mon;
i2c_op_t op_mon;
i2c_state_t state_mon;
bit flag_mon = 1'b0;

i2c_op_t test_op_mon;
reg sda_reg_mon =1'b1;
reg sda_reg2_mon = 1'b0;
logic sda_enable_mon = 1'b0;
bit [I2C_DATA_WIDTH] burst_queue_mon[$];
bit [I2C_DATA_WIDTH] read_queue_mon[$];
int pack = 0;

bit [I2C_DATA_WIDTH] data_mon[];

//assign sda_o = sda_enable ? sda_reg : 1'bz;

assign sda_o = sda_enable ? sda_reg2 : 1'bz;


    task address_burst();

        state = ADDR;
            foreach(captured_burst[i])begin
                @(posedge scl_i)begin
                    captured_burst[i] = sda_i;
		    if((i==8)&&(op!=READ))sda_reg = 1'b0;
                end
		@(negedge scl_i)begin
			if((i==8)&&(op!=READ))sda_reg = 1'b1;
		end
            end
	    start = 1'b0;
	    test_op = READ;

            op = captured_burst[I2C_ADDR_WIDTH] ? READ : WRITE;


    endtask

    task address_burst_mon();

        state_mon = ADDR;
            foreach(captured_burst_mon[i])begin
                @(posedge scl_i)begin
                    captured_burst_mon[i] = sda_i;
                end
            end
	    start = 1'b0;
	    test_op = READ;

            op_mon = captured_burst[I2C_ADDR_WIDTH] ? READ : WRITE;


    endtask

    task data_burst();
        state = DATA;
        foreach(captured_burst[i])begin
            @(posedge scl_i)begin
                captured_burst[i] = sda_i;
		if((i==8)&&(op!=READ))sda_reg = 1'b0;
	    end
	    @(negedge scl_i)begin
		if((i==8)&&(op!=READ))sda_reg = 1'b1;
            end
        end
	if((op == WRITE)&&(!flag)) state = STOP;

    endtask


    task data_burst_mon();
        state_mon = DATA;
        foreach(captured_burst_mon[i])begin
            @(posedge scl_i)begin
                captured_burst_mon[i] = sda_i;
	    end
        end
	if((op_mon == WRITE)&&(!flag)) state_mon = STOP;

    endtask

//----------------------------------------------------------------
    task wait_for_i2c_transfers(
        output i2c_op_t op,
        output bit [I2C_DATA_WIDTH-1:0] write_data[]
    );

    @(negedge sda_i)begin
        if(scl_i)begin
            state = START;
            start = 1'b1;
        end
    end

    if(start) address_burst();
    if((op == WRITE)&&(state!=STOP))begin
	data_burst();
	burst_queue.push_front(captured_burst[0:I2C_DATA_WIDTH-1]);

    end

    if((op == READ)&&(state!=STOP))begin
	bit [I2C_DATA_WIDTH-1:0] data;
	data = read_queue.pop_back();
	send_burst(data);
	if(read_queue.size()==0) state = STOP;
    end


    @(posedge sda_i)begin
        if(scl_i)begin
            state = STOP;
	        write_data = burst_queue;
	        write_data.reverse();
        end
    end

    endtask
//----------------------------------------------------------------
    task bit_sda(input bit data);
	sda_reg2 = data;
	@(posedge scl_i) sda_enable = 1'b1;
	@(negedge scl_i) sda_enable = 1'b0;
    endtask
//----------------------------------------------------------------
    task send_burst(input bit [I2C_DATA_WIDTH-1:0] data);
	for(int i = I2C_DATA_WIDTH-1; i >= 0; i--) begin
		bit_sda(data[i]);
	end
	test_op = READ;
    endtask
//----------------------------------------------------------------
    task extract();
	bit [I2C_DATA_WIDTH-1:0] data;
	data = read_queue.pop_back();
	send_burst(data);

	if(read_queue.size()==0) begin
		state = STOP;
	end
	endtask

//    task glue();
//	int blarg;
//	for(int i = 0; i < 8; i++)begin
//		wait(i==8);
//	end
  //  endtask

//----------------------------------------------------------------
    task provide_read_data(
        input bit [I2C_DATA_WIDTH-1:0] read_data[],
        output bit transfer_complete
    );
    start = 1'b1;
	transfer_complete = 1'b0;

	for(int i = 0; i < read_data.size(); i++)begin
		read_queue.push_front(read_data[i]);
	end
	//wait(read_queue.size()==0);
	transfer_complete = 1'b1;

    endtask
//----------------------------------------------------------------
    task monitor(
        output bit [I2C_ADDR_WIDTH-1:0] addr,
        output i2c_op_t op_mon,
        output bit [I2C_DATA_WIDTH-1:0] data[]
    );

    @(negedge sda_i)begin
        if(scl_i)begin
            state_mon = START;
            start_mon = 1'b1;
        end
    end

    if(start_mon) begin
	address_burst_mon();
    	addr=captured_burst_mon[0:7];
    end
    if((op_mon ==0)&&(state_mon!=STOP))begin
	data_burst_mon();
	data_mon[pack] = captured_burst_mon;

	burst_queue_mon.push_front(captured_burst_mon[0:I2C_DATA_WIDTH-1]);

    end
	if(flag)begin
		for(int i = 0; i < 127; i++)begin
			if(i[0])begin
				data[i] = 64+i;
			end
			else begin
				data[i] = 63-i;
			end
		end
	end
    if((op_mon == 1)&&(state_mon!=STOP))begin
	data_mon[pack] = read_queue_mon.pop_back();
pack++;
	//send_burst_mon(data);
	if(read_queue_mon.size()==0) state_mon = STOP;
    end


    @(posedge sda_i)begin
        if(scl_i)begin
            state_mon = STOP;
	        data_mon = burst_queue_mon;
		// write burst_queue into write_data
        end
    end
    endtask

endinterface
