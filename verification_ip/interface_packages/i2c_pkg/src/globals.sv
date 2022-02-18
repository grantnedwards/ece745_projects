package globals;
      
   typedef enum bit {
           WRITE = 1'b0,
           READ = 1'b1
           } i2c_op_t;

   typedef enum bit [1:0]{
           START = 2'b00,
           STOP = 2'b01,
           DATA = 2'b10,
           ADDR = 2'b11
   } i2c_state_t;
endpackage