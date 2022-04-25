var g_data = {"tp":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"testplan","-",0,"0",2],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"i2cmb Registers",100.00,1,"1",2],"usr_attr":[{"Description":""}],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Test default values in registers",100.00,2,"1.1",2],"usr_attr":[{"Description":"Enable bit has a value of \"0\" after reset, verify registers are the correct defaults at start"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Test address values for registers",100.00,2,"1.2",2],"usr_attr":[{"Description":"Corresponding CSR, DPR, CMDR, FSMR registers accessed - 0x00 - 0x03"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Test read and write operations access on all registers",100.00,2,"1.3",2],"usr_attr":[{"Description":"FSM Registers are read only. Verify reading is accomplished and attempt to write. CSR, DPR, and CMDR tried writing"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Test if write values can be read simultaneously with same values",100.00,2,"1.4",2],"usr_attr":[{"Description":"After writing to CSR, DPR, and CMDR reading should result in what was actually written"}],"children":[]}]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"i2cmb Code Coverage",100.00,1,"2",2],"usr_attr":[{"Description":""}],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Code Coverage for i2cmb",100.00,2,"2.1",2],"usr_attr":[{"Description":"All Design Units have 100% statement coverage and branch coverage"}],"children":[]}]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"i2cmb FSM Testing",100.00,1,"3",2],"usr_attr":[{"Description":""}],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Two consecutive Starts",100.00,2,"3.1",2],"usr_attr":[{"Description":"Checks two consecutive start scenarios"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Two consecutive Stops",100.00,2,"3.2",2],"usr_attr":[{"Description":"Checks two consecutive stop scenarios"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Write command before providing your data",100.00,2,"3.3",2],"usr_attr":[{"Description":"A byte transmitted has written to the DPR before executing write"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Covergroup for testing fsm",100.00,2,"3.4",2],"usr_attr":[{"Description":"Testing the dut with a range of writes, waits, and setting of the bus"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Write command command parameter",100.00,2,"3.5",2],"usr_attr":[{"Description":"Coverpoint to check if write command was given a full set of data"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Wait coverpoint",100.00,2,"3.6",2],"usr_attr":[{"Description":"Coverpoint to check if waits occur within the specified time"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Bus set coverpoint",100.00,2,"3.7",2],"usr_attr":[{"Description":"Set bus can handle all of the bus ranges"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Command Responses",100.00,2,"3.8",2],"usr_attr":[{"Description":"Assertion if arbitration is lost or Done. Validate for all command responses that fall outside requirements"}],"children":[]}]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"wishbone Function Converage",100.00,1,"4",2],"usr_attr":[{"Description":""}],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Covergroup for wishbone operations",100.00,2,"4.1",2],"usr_attr":[{"Description":"Range of coverpoints that track reads, writes, addresses, and data"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Reads and Writes in Wishbone",100.00,2,"4.2",2],"usr_attr":[{"Description":"Covers write and read oprations within the wishbone side of things"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Data in wishbone transactions",100.00,2,"4.3",2],"usr_attr":[{"Description":"Covers data values written, any possible data values within the acceptible range 0x00 to 0xFF"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Offsets of Registers",100.00,2,"4.4",2],"usr_attr":[{"Description":"Coverpoint tracking the i2cmb registers corresponding to the wb master BFM that were actually written to"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Cross for operations, offsets, and data",100.00,2,"4.5",2],"usr_attr":[{"Description":"Segments of data correspond to the 3 registers of read/write access. Non-possible bins need to be available for the FSM Registers. Read only!"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Assert for rst_i function",100.00,2,"4.6",2],"usr_attr":[{"Description":"rst_i needs to be synchronously active high and we can check and make sure it does this"}],"children":[]}]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"i2c Function Coverage",100.00,1,"5",2],"usr_attr":[{"Description":""}],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Covergroup for i2c operations",100.00,2,"5.1",2],"usr_attr":[{"Description":"Covergroup for testing all operations, addresses, and data"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Coverpoint for operations",100.00,2,"5.2",2],"usr_attr":[{"Description":"Coverpoint for read or write operations happening correctly"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Coverpoint for data",100.00,2,"5.3",2],"usr_attr":[{"Description":"Coverpoint for values that are possible within 0x00 and 0xFF"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Coverpoint for address",100.00,2,"5.4",2],"usr_attr":[{"Description":"Coverpoint that trakcs the address between 0x00 and 0x7F"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Cross for address, data, and operations",100.00,2,"5.5",2],"usr_attr":[{"Description":"Cross that trakcs all of thesee sections combined testing for different combinations possible. Works specifically for write operations only"}],"children":[]}]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Generation Transfer Testing",100.00,1,"6",2],"usr_attr":[{"Description":""}],"children":[{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Reads and Writes Standard Predefined",100.00,2,"6.1",2],"usr_attr":[{"Description":"32 Writes, 32 Reads, Alternating descending and ascending writes and reads"}],"children":[]},{"fixed_attr_val":[0,0,0.00,0.00,"testplan",1,"Randomized Transfers",100.00,2,"6.2",2],"usr_attr":[{"Description":"Randomized reads and writes of varying values within the ranges needed to be tested. Can also include changes between stops and starts missing or repeated conditions"}],"children":[]}]}]}],"head":["Description"]};
processTpLinks(g_data);