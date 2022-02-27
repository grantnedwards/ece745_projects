`timescale 1ns / 10ps

module top();
import globals::*;
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
// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

initial
    begin : wb_monitoring
    wb_bus.master_monitor(mon_addr, mon_data, mon_we);
    $display ("mon_addr : %x", mon_addr);
    $display ("mon_data : %x", mon_data);
    $display ("mon_we : %x", mon_we);
end
// ****************************************************************************
// Define the flow of the simulation
initial
    begin : test_flow
	bit [I2C_DATA_WIDTH-1: 0] write_in [];
	bit [I2C_DATA_WIDTH-1: 0] write_out [];
	bit [I2C_DATA_WIDTH-1: 0] read_in [];
	bit [I2C_DATA_WIDTH-1: 0] read_out [];
	
	while (rst) @(clk);
	#1000; //Match up with graph
	wb_bus.master_write(CSR, 8'b11xx_xxxx); //Enable iicmb and irq output
	set_bus(8'h5);
    $display(" Writing 32 values ");
    fork
        begin
            write_bus(8'h22, 8'h78);
        end
        begin
            i2c_bus.wait_for_i2c_transfer(op, write_out);
        end
    join
    ///

    // fork
    //     begin
    //         // write_in = new[32];
    //         // foreach(write_in[i])begin
    //         //     bit [I2C_DATA_WIDTH-1:0] line;
	// 		// 	line = i;
	// 		// 	write_in[i] = line;
    //         // end
    //         // write_bus(8'h22, write_in);
    //     end
    //     begin
    //         // i2c_bus.wait_for_i2c_transfer(op, write_out);
    //     end
    // join
//====================================================================================================
    $display(" Reading 100-131 from the I2C Bus ");


	
// $display(read_data);
end


//*******************************************************
//    Tasks
//*******************************************************
task set_bus(input bit [WB_DATA_WIDTH-1:0] bus_num);
      wb_bus.master_write(DPR, bus_num); //send bus number to DPR
      wb_bus.master_write(CMDR, cmd_set_bus); //send set_bus command
endtask
//*******************************************************


task write_bus(
    input bit [I2C_ADDR_WIDTH-1:0] addr, 
    input bit [I2C_DATA_WIDTH-1:0] data[]
);
    reg [WB_DATA_WIDTH-1:0] temp;
	wb_bus.master_write(CMDR, cmd_start);
    wait(irq);																  
    wb_bus.master_read(CMDR, temp);
    wb_bus.master_write(DPR, addr << 1);
    wb_bus.master_write(CMDR, cmd_write);
    wait(irq);																  
    wb_bus.master_read(CMDR, temp);
    for (int i = 0; i < data.size(); i++)
    	begin
			wb_bus.master_write(DPR, data[i]);
			wb_bus.master_write(CMDR, cmd_write);
			wait(irq);
			wb_bus.master_read(CMDR, temp);
    	end
	wb_bus.master_write(CMDR, cmd_stop);
    wait(irq);
    wb_bus.master_read(CMDR, temp);
endtask


task read_bus(
	input bit [I2C_ADDR_WIDTH-1:0] addr,
	output bit [I2C_DATA_WIDTH-1:0] data[],
	input int lines
);

	bit [WB_DATA_WIDTH-1:0] temp;
	data = new[lines];

	wb_bus.master_write(CMDR, cmd_start);
	wait(irq);
	wb_bus.master_read(CMDR, temp);
	temp = addr << 1;
	temp[0] = 1'b1;
	wb_bus.master_write(DPR, temp);
	wb_bus.master_write(CMDR, cmd_write);
	wait(irq);
	wb_bus.master_read(CMDR, temp);

	for(int i = 0; i < data.size(); i++)begin
		wb_bus.master_write(CMDR, cmd_read_ack);
		wait(irq);
		wb_bus.master_read(DPR, temp);
		data[i] = temp;
		wb_bus.master_read(CMDR, temp);
	end

	wb_bus.master_write(CMDR, cmd_stop);
	wait(irq);
	wb_bus.master_read(CMDR, temp);


endtask


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


endmodule
