import globals::*;
interface i2c_if        #(
    int I2C_ADDR_WIDTH = 7,                                
    int I2C_DATA_WIDTH = 8      )
(
    input wire scl_i,
    input wire sda_i,
    output wire scl_o,
    output wire sda_o
);
bit start = 1'bx;
shortint inc_addr;
bit captured_burst [I2C_DATA_WIDTH+1];
i2c_op_t op;
i2c_state_t state;

    task address_burst();
        state = ADDR;
        if(start)begin
            foreach(captured_burst[i])begin
                @(posedge scl_i)begin
                    captured_burst[i] = sda_i;
                end
            end
            start = 1'b0;
            assign op = captured_burst[I2C_ADDR_WIDTH-1] ? READ : WRITE;
        end
    endtask

    task data_burst();
        state = DATA;
        foreach(captured_burst[i])begin
            @(posedge scl_i)begin
                captured_burst[i] = sda_i;
            end
        end
        

    endtask

//----------------------------------------------------------------
    task wait_for_i2c_transfers(
        //output i2c_op_t op, 
        //output bit [I2C_DATA_WIDTH-1:0] write_data[]
    );
    @(negedge sda_i)begin
        if(scl_i)begin
            state = START;
            start = 1'b1;
        end
    end
    
    address_burst();
    data_burst();

    @(posedge sda_i)begin
        if(scl_i)begin
            state = STOP;
        end
    end

    


    endtask
//----------------------------------------------------------------
    task provide_read_data(
        input bit [I2C_DATA_WIDTH-1:0] read_data[],
        output bit transfer_complete
    );
    endtask
//----------------------------------------------------------------
    task monitor(
        output bit [I2C_ADDR_WIDTH-1:0] addr,
        output i2c_op_t op,
        output bit [I2C_DATA_WIDTH-1:0] data[]
    );
    endtask

endinterface