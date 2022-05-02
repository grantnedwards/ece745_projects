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

// This section initializes all required tests for the test plan
// test plan names are selected from script that laucnhes class tests
  i2cmb_test tst;
  test_i2cmb_two_stops tst2;
  test_i2cmb_two_starts tst3;
  test_i2cmb_reads tst4;
  test_i2cmb_reg_inits tst5;
  test_i2cmb_reg_addrs tst6;
  test_i2cmb_write_before_data tst7;
  test_i2cmb_writes tst8;
  i2cmb_test_random tst9;

  initial begin : project_4
    string test_name;
    $value$plusargs("GEN_TRANS_TYPE=%s", test_name);
    case(test_name)
      "i2cmb_test":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst.env.wb_agents", wb_bus);
        tst = new("tst", null);
        tst.construct();
        tst.execute();

        $display("================FINISHED================");
        $display(" Project 2 + 3 Testflow of reads and writes");
        $display("=========================================");
        $finish;
      end
      "test_i2cmb_two_starts":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst3.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst3.env.wb_agents", wb_bus);
        tst3 = new("tst3", null);
        tst3.construct();
        tst3.execute();

        $display("================FINISHED================");
        $display(" Two Consecutive Starts for FSM          ");
        $display("=========================================");
        $finish;
      end
      "test_i2cmb_two_stops":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst2.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst2.env.wb_agents", wb_bus);
        tst2 = new("tst2", null);
        tst2.construct();
        tst2.execute();

        $display("================FINISHED================");
        $display(" Two Consecutive Stops for FSM          ");
        $display("=========================================");
        $finish;

      end
      "test_i2cmb_reads":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst4.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst4.env.wb_agents", wb_bus);
        tst4 = new("tst4", null);
        tst4.construct();
        tst4.execute();

        $display("================FINISHED================");
        $display(" FSM Register tested verifying          ");
        $display("=========================================");
        $finish;

      end
      "test_i2cmb_reg_inits":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst5.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst5.env.wb_agents", wb_bus);
        tst5 = new("tst5", null);
        tst5.construct();
        tst5.execute();

        $display("================FINISHED================");
        $display(" Register Intialization Testing defaults ");
        $display("=========================================");
        $finish;

      end
      "test_i2cmb_reg_addrs":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst6.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst6.env.wb_agents", wb_bus);
        tst6 = new("tst6", null);
        tst6.construct();
        tst6.execute();

        $display("================FINISHED================");
        $display(" Testing defaults for addresses          ");
        $display("=========================================");
        $finish;

      end
      "test_i2cmb_write_before_data":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst7.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst7.env.wb_agents", wb_bus);
        tst7 = new("tst7", null);
        tst7.construct();
        tst7.execute();

        $display("================FINISHED================");
        $display(" Writing to DPR before execution of write ");
        $display("=========================================");
        $finish;

      end
      "test_i2cmb_writes":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst8.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst8.env.wb_agents", wb_bus);
        tst8 = new("tst8", null);
        tst8.construct();
        tst8.execute();

        $display("================FINISHED================");
        $display(" Testing simultaneous value writes       ");
        $display("=========================================");
        $finish;

      end
      "i2cmb_test_random":begin
        ncsu_config_db#(virtual i2c_if#(I2C_ADDR_WIDTH, I2C_DATA_WIDTH))::set("tst9.env.i2c_agents", i2c_bus);
        ncsu_config_db#(virtual wb_if#(WB_ADDR_WIDTH, WB_DATA_WIDTH))::set("tst9.env.wb_agents", wb_bus);
        tst9 = new("tst9", null);
        tst9.construct();
        tst9.execute();

        $display("================FINISHED================");
        $display(" Random Transactions for coverage       ");
        $display("=========================================");
        $finish;
      end
      default: $display("not found, check your spelling ya dingus!");

    endcase
    $display("================//////////\\\\\\\\\\================");
    $display("================..SCRIPT COMPLETE..=================");
    $display("================.....IT WORKS!.....=================");
    $display("================\\\\\\\\\\//////////================");

  end

endmodule
