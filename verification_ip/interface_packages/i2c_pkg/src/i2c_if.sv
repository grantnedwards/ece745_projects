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

///////////
bit start = 1'bx;
bit [I2C_DATA_WIDTH+1] captured_burst;
i2c_op_t op;
i2c_state_t state;

i2c_op_t test_op;
reg sda_reg =1'b1;
reg sda_reg2; 
logic sda_enable;
bit [I2C_DATA_WIDTH] burst_queue[$];
bit [I2C_DATA_WIDTH] read_queue[$];
assign sda_o = sda_reg ? 1'bz : 1'b0;

//assign sda_o = sda_enable ? sda_reg : 1'bz;

//assign sda_o = sda_enable ? sda_reg2 : 1'bz;


    task address_burst();

        state = ADDR;
	//test_op = READ;

		
            foreach(captured_burst[i])begin
                @(posedge scl_i)begin
                    captured_burst[i] = sda_i;
		    if((i==8)&&(op!=READ))sda_reg = 1'b0;
                end
		@(negedge scl_i)begin
			if((i==8)&&(op!=READ))sda_reg = 1'b1;		
		end
            end
	    //@(posedge scl_i)begin
		//sda_reg = 1'b0;
	    //end
//if(test_op == READ)begin
//    	bit [I2C_DATA_WIDTH-1:0] data_burst;
//	data_burst = read_queue.pop_back();
//	send_burst(data_burst);
   // end
	    start = 1'b0;
	    test_op = READ;

            op = captured_burst[I2C_ADDR_WIDTH] ? READ : WRITE;
	    
       
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
	//if(op == WRITE) state = STOP;
	
    endtask

//----------------------------------------------------------------
    task wait_for_i2c_transfers(
        output i2c_op_t op, 
        output bit [I2C_DATA_WIDTH-1:0] write_data[]
    );
    $display("begin");
    @(negedge sda_i)begin
        if(scl_i)begin
            state = START;
            start = 1'b1;
        end
    end
    $display("addr");
    if(start) address_burst();
    $display("data");
    if((op == WRITE)&&(state!=STOP))begin
	//$display("inside data");
	data_burst();
	burst_queue.push_front(captured_burst[0:I2C_DATA_WIDTH-1]);
		//$display(burst_queue);
    end

    if((op == READ)&&(state!=STOP))begin
	bit [I2C_DATA_WIDTH-1:0] data;
	$display("tester");
	data = read_queue.pop_back();    	
	send_burst(data);
	if(read_queue.size()==0) state = STOP;
    end

    
    $display("stopper");
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
    $display("done");

   


    endtask

    task bit_sda(input bit data);
	sda_reg = data;
	@(posedge scl_i) sda_enable = 1'b1;
	@(negedge scl_i) sda_enable = 1'b0;
    endtask

    task send_burst(input bit [I2C_DATA_WIDTH-1:0] data);
	for(int i = I2C_DATA_WIDTH-1; i >= 0; i--) begin
		bit_sda(data[i]);
		$display("burst");
		$display(i);
	end
	test_op = READ;
    endtask
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
	$display("%h", read_data);
	$display("queue");	
	display_i2c_data_array(read_queue, 32);
	wait(read_queue.size()==0);
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
