import globals::*;

interface i2c_if #(
    int I2C_ADDR_WIDTH = 7,
    int I2C_DATA_WIDTH = 8
    )
    (
        input triand scl_i,
        input triand sda_i,
        output triand scl_o,
        output triand sda_o
    );

    i2c_state_t state;
    bit [I2C_ADDR_WIDTH-1:0] address;

    logic sda_enable;
    reg sda_reg;
    assign sda_o = sda_enable ? sda_reg : 1'bz;

    bit [I2C_DATA_WIDTH-1:0] read_queue[$];
    bit [I2C_DATA_WIDTH-1:0] write_queue[$];


    initial restart :
        begin
            sda_enable <= 1'b0;
            sda_reg <= 1'b0;
        end



    task wait_for_i2c_transfer(
        output i2c_op_t op, 
        output bit [I2C_DATA_WIDTH-1:0] write_data[]
    );
        
        //bit done = 1'b0;
        

        state = WAIT;

        case(state)
            WAIT : begin
                @(negedge sda_i)begin
                    if(scl_i)begin
                        state = START;
                    end
                end

                @(posedge scl_i)begin
                    if(scl_i)begin
                        state = STOP;
                    end
                end
            end
            START : begin
                state = ADDR;
            end
            ADDR : begin
                write_queue.delete();
                read_line(write_queue);
                state = RECEIVE;

            end
            RECEIVE : begin
                foreach(write_queue[i])begin
                    write_data[i] = write_queue.pop_back();
                end

            end
            SEND : begin
                
            end
            STOP : begin
                
            end
            
        endcase

    endtask

    task write_line();
    endtask

    task read_line(
        output bit [I2C_ADDR_WIDTH-1:0] captured_burst
    );
        foreach(captured_burst[i])begin
            @(posedge scl_i)begin
                captured_burst[i] = sda_i;
            end
        end

    endtask

endinterface    