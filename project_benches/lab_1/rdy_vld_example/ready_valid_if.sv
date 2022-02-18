interface ready_valid_if ( input wire clk, input wire rst);

   wire       ready;
   bit        valid;
   reg [31:0] data;

   clocking cb @(posedge clk);
      default input #1ns output #2ns;
      inout ready, valid, data;
   endclocking

   modport dut (input clk, rst, output ready, input valid, data );

   task drive(input reg [31:0] data_in, input bit [3:0] delay_in);
      while (cb.ready == 1'b0) @(cb);
      repeat(delay_in) @(cb);
      cb.valid <= 1'b1;
      cb.data <= data_in;
      @(cb) cb.valid <= 1'b0;
      @(cb);
   endtask

   task monitor(output reg [31:0] data_out);
      while ((cb.ready === 1'b0)||(cb.valid == 1'b0)) @(cb);
      data_out = cb.data;
      @(cb);
   endtask

endinterface
