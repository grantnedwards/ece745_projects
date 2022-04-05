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
bit complete;
bit start = 1'bx;
bit [I2C_DATA_WIDTH+1] captured_burst;
i2c_op_t op;
//i2c_state_t state;
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
//i2c_state_t state_mon;
bit flag_mon = 1'b0;

i2c_op_t test_op_mon;
reg sda_reg_mon =1'b1;
reg sda_reg2_mon = 1'b0;
logic sda_enable_mon = 1'b0;
bit [I2C_DATA_WIDTH] burst_queue_mon[$];
bit [I2C_DATA_WIDTH] read_queue_mon[$];
int pack = 0;
int count;

bit [I2C_DATA_WIDTH] data_mon[];

//assign sda_o = sda_enable ? sda_reg : 1'bz;

assign sda_o = sda_enable ? sda_reg2 : 1'bz;


//----------------------------------------------------------------
    task wait_for_i2c_transfers(
        output i2c_op_t op,
        output bit [I2C_DATA_WIDTH-1:0] write_data[]
    );
    bit temp;
    timer_t dir; 
    bit [I2C_ADDR_WIDTH-1:0] addr;
    bit [I2C_DATA_WIDTH-1:0] burst;
    int size;
    bit [I2C_DATA_WIDTH-1:0] in_data[$];
    bit [I2C_DATA_WIDTH-1:0] out_data[$];
    stately_t state;
        
        case(state)
            INIT :  begin

                    selection(dir, temp);
                    if(dir == START)    state = ADDR;
                    else                state = INIT;

                    end
            ADDR :  begin

                    for(int i = 6; i>= 0; i--)begin
                        selection(dir, temp);
                        addr[i] = temp;
                    end
                    selection(dir, temp);
                    if(temp)    op = READ;
                    else        op = WRITE;

                    bit_sda(0);

                    if(op)      state = OUT;
                    else        state = IN;

                    end
            IN :    begin
                    bit [I2C_DATA_WIDTH-1:0] burst;
                    for(int i = 7; i>=0; i--)begin
                        selection(dir, temp);
                        if(dir != DATA) break;
                        burst[i] = temp;
                    end
                    if(dir == START) state = ADDR;
                    else if (dir == STOP)begin
                            size = in_data.size();
                            write_data = new[size];
                            for(int i=0; i<size; i++) write_data[i] = in_data.pop_back();
                            complete = 1'b1;
                            state = INIT;
                        end
                    else
                        begin
                            in_data.push_front(burst);
                            bit_sda(0);
                        end
                    end
            OUT :   begin
                    bit [I2C_DATA_WIDTH-1:0] burst;
                    burst = read_queue.pop_back();
                    for(int i = 7; i>=0; i--)begin
                        bit_sda(burst[i]);
                    end
                    selection(dir, temp);
		            if(read_queue.size()==0)begin
                        state = INIT;
                        complete = 1'b1;
                    end
                    else state = OUT;
                    end
            default: state = INIT;
        endcase
    endtask

    task selection(output timer_t state, output bit data);
        bit start;
		bit ender;

		wait(scl_i);
        start = sda_i;
        wait((~scl_i)||((~start)&&(sda_i)));
        ender = sda_i;
		if(start)
			begin
				if(ender)state=DATA;
				else state=START;
            end
		else
			begin
				if(~ender)state=DATA;
				else state=STOP;
			end
		data = start;		
    endtask
//----------------------------------------------------------------
//     task detect_state(output i2c_op_t);
//     endtask
    task bit_sda(input bit data);
        sda_reg2 = data;
        @(posedge scl_i) sda_enable = 1'b1;
        @(negedge scl_i) sda_enable = 1'b0;
    endtask
// //----------------------------------------------------------------
//     task send_burst(input bit [I2C_DATA_WIDTH-1:0] data);
// 	for(int i = I2C_DATA_WIDTH-1; i >= 0; i--) begin
// 		bit_sda(data[i]);
// 	end
// 	test_op = READ;
//     endtask
//----------------------------------------------------------------
    // task extract();
	// bit [I2C_DATA_WIDTH-1:0] data;
	// data = read_queue.pop_back();
	// send_burst(data);

	// if(read_queue.size()==0) begin
	// 	state = STOP;
	// end
	// endtask

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
	transfer_complete = 1'b0;
	for(int i = 0; i < read_data.size(); i++)read_queue.push_front(read_data[i]);
    wait(read_queue.size()==0);
	transfer_complete = 1'b1;

    endtask
//----------------------------------------------------------------
    task monitor(
        output bit [I2C_ADDR_WIDTH-1:0] addr,
        output i2c_op_t op_mon,
        output bit [I2C_DATA_WIDTH-1:0] data[]
    );
    endtask

endinterface
