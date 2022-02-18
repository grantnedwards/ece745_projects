module ready_valid_dut(ready_valid_if.dut bus);

   bit ready;
   initial begin
      // Delay ready for two clocks
      repeat (2) @(posedge bus.clk);
      @(posedge bus.clk) ready <= 1'b1;
      // Deassert ready after valid for three clocks
      forever begin 
         while (bus.valid == 1'b0) @(posedge bus.clk);
         ready <= 1'b0;
         repeat (3) @(posedge bus.clk);
         @(posedge bus.clk) ready <= 1'b1;
      end
   end

   assign bus.ready = ready;

endmodule
