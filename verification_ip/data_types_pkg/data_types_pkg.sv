package data_types_pkg;

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

   typedef enum bit [3:0] {
           ROUTING_TABLE=4'h1,
           STATISTICS=4'h2,
           PAYLOAD=4'h4,
           SECURE_PAYLOAD=4'h8
   } header_type_t;

   typedef enum bit [1:0] {
           STARTER = 2'b00,
           READER = 2'b01,
           WRITER = 2'b10,
           RUNNER = 2'b11
   } state_t;

endpackage
