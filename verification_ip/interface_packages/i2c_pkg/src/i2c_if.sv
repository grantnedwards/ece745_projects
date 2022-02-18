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
bit captured_addr [7:0];

//----------------------------------------------------------------
    task wait_for_i2c_transfers(
        //output i2c_op_t op, 
        //output bit [I2C_DATA_WIDTH-1:0] write_data[]
    );
    
    @(negedge sda_o)begin
        if(scl_o)begin
            start = 1'b1;
        end
    end
    if(start)begin
        foreach(captured_addr[i])begin
            @(posedge scl_o)begin
                captured_addr[i] = sda_i;
            end
        end
        start = 1'b0;
        
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