package globals;
      
   typedef enum bit {
           WRITE = 1'b0,
           READ = 1'b1
           } i2c_op_t;

   typedef enum bit [2:0]{
           WAIT,
           START,
           STOP,
           RECEIVE,
           SEND,
           ADDR
   } i2c_state_t;
endpackage

// package globals;

// 		typedef enum bit { I2C_WRITE, I2C_READ } i2c_op_t;
// 		typedef enum bit [1:0] { I2C_START_COND, I2C_STOP_COND, I2C_DATA_COND } i2c_cond_t;
// 		typedef enum bit [1:0] { I2C_IF_IDLE, I2C_IF_ADDR, I2C_IF_RECEIVE_DATA, I2C_IF_SEND_DATA} i2c_slave_state_t;
// 		typedef enum bit { FALSE, TRUE } bool_t;

// endpackage
