import globals::*;
interface i2c_if        #(
    int I2C_ADDR_WIDTH = 7,                                
    int I2C_DATA_WIDTH = 8      )
(
    input triand scl_i,
    input triand sda_i,
    output triand scl_o,
    output triand sda_o
);
bit start = 1'bx;
bit [I2C_DATA_WIDTH+1] captured_burst;
i2c_op_t op;
i2c_state_t state;
reg sda_reg = 1'b1;
bit [I2C_DATA_WIDTH] burst_queue[$];
bit [I2C_DATA_WIDTH] read_queue[$];
assign sda_o = sda_reg ? 1'bz : 1'b0;

    task is_valid_data();
    	
    endtask

    task address_burst();

        state = ADDR;
        if(start)begin
		
            foreach(captured_burst[i])begin
                @(posedge scl_i)begin
                    captured_burst[i] = sda_i;
		 //   if(i==8)sda_reg = 1'b0;
                end
		@(negedge scl_i)begin
		//	if(i == 8)sda_reg = 1'b1;		
		end
            end
	    //@(posedge scl_i)begin
		//sda_reg = 1'b0;
	    //end

	    start = 1'b0;

            op = captured_burst[I2C_ADDR_WIDTH-1] ? READ : WRITE;
	    
        end
    endtask

    task data_burst();
        state = DATA;
        foreach(captured_burst[i])begin
            @(posedge scl_i)begin
                captured_burst[i] = sda_i;
		if(i==8)sda_reg = 1'b0;
	    end
	    @(negedge scl_i)begin
		if(i == 8)sda_reg = 1'b1;	
            end
        end
	state = STOP;
	
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
	//$display("inside data");
	data_burst();
	burst_queue.push_front(captured_burst[0:I2C_DATA_WIDTH-1]);
		//$display(burst_queue);
    end

    @(posedge sda_i)begin
	//$display("here!");
        if(scl_i)begin
	    //$display("stop!");
            state = STOP;
	    write_data = burst_queue;
	    write_data.reverse();
		// write burst_queue into write_data
        end
    end

    


    endtask
//----------------------------------------------------------------
    task provide_read_data(
        input bit [I2C_DATA_WIDTH-1:0] read_data[],
        output bit transfer_complete
    );

	transfer_complete = 1'b0;

	foreach(read_data[i]) read_queue.push_front(read_data[i]);
	wait(!read_queue.size());
	transfer_complete = 1'b1;

    endtask
//----------------------------------------------------------------
    task monitor(
        output bit [I2C_ADDR_WIDTH-1:0] addr,
        output i2c_op_t op,
        output bit [I2C_DATA_WIDTH-1:0] data[]
    );
    endtask

endinterface
