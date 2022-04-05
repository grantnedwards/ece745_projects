`timescale 1ns / 10ps

module top();
import data_types_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;
import i2cmb_env_pkg::*;
import ncsu_pkg::*;
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

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;
//
reg [WB_ADDR_WIDTH-1:0] mon_addr;
reg [WB_DATA_WIDTH-1:0] mon_data;
bit mon_we;

reg [WB_DATA_WIDTH-1:0] interrupt_check;

bit [I2C_DATA_WIDTH-1:0] write_data[];
bit [I2C_DATA_WIDTH-1:0] read_data[];

bit [WB_DATA_WIDTH-1:0] mon_read_data;
bit [I2C_DATA_WIDTH-1:0] temp;

bit transfer_complete;
i2c_op_t op;
int line;
//
// ****************************************************************************
// Clock generator

initial
    begin : clk_gen
    clk = 0;
    forever #5 clk = ~clk;
end

// ****************************************************************************
// Reset generator

initial
    begin : rst_gen
    #113 rst = 1'b0;
end

initial 
  begin : wait_for_i2c_transfers_run
  
end

// initial 
//   begin : test_flow_1
//   bit [I2C_DATA_WIDTH-1:0] write_in [];
//   bit [I2C_DATA_WIDTH-1:0] write_out [];
//   bit [I2C_DATA_WIDTH-1:0] read_in [];
//   bit [I2C_DATA_WIDTH-1:0] read_out [];
//   bit [I2C_DATA_WIDTH-1:0] burst;
//   bit done;
//   while (rst) @(clk);
//   #1000; //Match up with graph
  
//   wb_bus.master_write(CSR, 8'b11xx_xxxx);
//   wb_bus.master_write(DPR, 3'h5);
//   wb_bus.master_write(CMDR, cmd_set_bus);
//   wait(irq);
//   //wb_bus.master_read(CMDR, data);


//   fork
//     begin
//       write_in = new[32];
//       for(int i=0; i<32; i++)begin
//         write_in[i] = i;
//       end
//       write(8'h69, write_in);
//     end
//     begin
//       while(~i2c_bus.complete) i2c_bus.wait_for_i2c_transfers(op, write_out);
//       i2c_bus.complete = 1'b0;
//     end
//   join 

// write_in.delete();
// write_out.delete();
// read_in.delete();
// read_out.delete();
//   fork
//     begin
//       read_in = new[32];
//       for(int i=0; i<32; i++)begin
//         read_in[i] = i + 100;
//       end
//     end
//     begin
//       i2c_bus.provide_read_data(read_in, done);
//     end
//     begin
//       read(8'h22, read_out, 32);
//     end

//     begin
//       while(~i2c_bus.complete) i2c_bus.wait_for_i2c_transfers(op, write_out);
//       i2c_bus.complete = 1'b0;
//     end
//   join

//   write_in.delete();
//   write_out.delete();
//   read_in.delete();
//   read_out.delete();  
//   for(int i = 0; i<64; i++)begin
//     fork
//       begin
//         write_in = new[1];
//         write_in[0] = i + 64;
//         write(8'h22, write_out);
//       end
//       begin
//         while(~i2c_bus.complete) i2c_bus.wait_for_i2c_transfers(op, write_out);
//         i2c_bus.complete = 1'b0;
//       end
//     join

//     fork
//       begin
//         read_in = new[1];
//         read_in[0] = 63 - i;
//         transfer_complete = 0;
//         i2c_bus.provide_read_data(read_in, transfer_complete);
//       end
//       begin
//         read(8'h22, read_out, 1);
//       end
//       begin
//         while(~i2c_bus.complete) i2c_bus.wait_for_i2c_transfers(op, write_out);
//         i2c_bus.complete = 1'b0;
//       end
//     join
//      write_in.delete();
//   write_out.delete();
//   read_in.delete();
//   read_out.delete();  
//   end
//   $finish;
// end

// task write(
//   input bit [I2C_ADDR_WIDTH-1:0] addr, 
//   input bit [I2C_DATA_WIDTH-1:0] data []
// );
//   reg [WB_DATA_WIDTH-1:0] temp;												
//   wb_bus.master_write(CMDR, cmd_start);
//   wait(irq);
//   wb_bus.master_read(CMDR, temp);
//   wb_bus.master_write(DPR, addr << 1);
//   wb_bus.master_write(CMDR, cmd_write);
//   wait(irq);
//   wb_bus.master_read(CMDR, temp);
//   foreach(data[i])begin
// 		wb_bus.master_write(DPR, data[i]);
//     wb_bus.master_write(CMDR, cmd_write);
//     wait(irq);
//     wb_bus.master_read(CMDR, temp);
//   end
// 	wb_bus.master_write(CMDR, cmd_stop);
//   wait(irq);
//   wb_bus.master_read(CMDR, temp);
// endtask

// task read(
// 	input bit [I2C_ADDR_WIDTH-1:0] addr,
// 	output bit [I2C_DATA_WIDTH-1:0] data[],
// 	input int line
// );
// 	bit [WB_DATA_WIDTH-1:0] temp;
// 	data = new[line];
// 	wb_bus.master_write(CMDR, cmd_start);
// 	wait(irq);
// 	wb_bus.master_read(CMDR, temp);
// 	temp = addr << 1;
// 	temp[0] = 1'b1;
// 	wb_bus.master_write(DPR, temp);
// 	wb_bus.master_write(CMDR, cmd_write);
// 	wait(irq);
// 	wb_bus.master_read(CMDR, temp);
// 	foreach(data[i])begin
// 		wb_bus.master_write(CMDR, cmd_read_ack);
// 		wait(irq);
// 		wb_bus.master_read(DPR, temp);
// 		data[i] = temp;
// 		wb_bus.master_read(CMDR, temp);
// 	end
// 	wb_bus.master_write(CMDR, cmd_stop);
// 	wait(irq);
// 	wb_bus.master_read(CMDR, temp);
// endtask


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  .irq_i(irq),
  // Shred signalssim:/top/i2c_bus/inc_addr

  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

i2c_if      #(
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH)
)
i2c_bus(
  .scl_i(scl[0]),
  .sda_i(sda[0]),
  .scl_o(scl[0]),
  .sda_o(sda[0])
);

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );



  i2cmb_test tst;

  initial begin : project_2
    ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst.env.i2c_agents", i2c_bus);
    ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst.env.wb_agents", wb_bus);
    tst = new("tst", null);
    tst.construct();
    tst.execute();
    wb_bus.wait_for_reset();
    tst.run();

    //HAVE MERCY ON MY SOUL FOR THIS PROJECT
    $display("================FINISHED================");
    $display("Mind the spaghetti code! It works though!");
    $display("=========================================");
    $finish();
  end

endmodule
