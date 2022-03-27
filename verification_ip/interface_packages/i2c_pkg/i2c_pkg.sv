package i2c_pkg;
  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;
  parameter int I2C_ADDR_WIDTH = 7;
  parameter int I2C_DATA_WIDTH = 8;
  parameter int NUM_I2C_BUSSES = 1;
  parameter CSR = 8'h0;
  parameter DPR = 8'h1;
  parameter CMDR = 8'h2;
  parameter FSMR = 8'h3;
  parameter cmd_set_bus = 8'bxxxx_x110;
  parameter cmd_start = 8'bxxxx_x100;
  parameter cmd_write = 8'bxxxx_x001;
  parameter cmd_stop = 8'bxxxx_x101;
  parameter cmd_read_ack = 8'bxxxx_x010;
  parameter cmd_read_nack = 8'bxxxx_x011;
    import ncsu_pkg::*;
    import data_types_pkg::*;
    `include "src/i2c_configuration.svh"
    `include "src/i2c_transaction.svh"
    `include "src/i2c_driver.svh"
    `include "src/i2c_monitor.svh"
    `include "src/i2c_agent.svh"
endpackage
