module top();

   bit clock;
   initial forever #10ns clock <= ~clock;
   bit reset;
   initial #12ns reset = 1'b1;

   ready_valid_if rv_bus(.clk(clock), .rst(reset));
   ready_valid_dut rv_dut(rv_bus);

   initial begin
      reg [31:0] data;
      repeat(1) @rv_bus.cb;
      rv_bus.drive(31'h01234567, 4'h2);
      rv_bus.drive(31'h89abcdef, 4'h1);
      rv_bus.drive(31'ha5a5c3c3, 4'h0);
      rv_bus.drive(31'hxxxxxxxx, 4'h0);
      repeat(3) @rv_bus.cb;
   end

   initial begin 
      reg [31:0] data;
      @(rv_bus.cb);
      forever begin
         rv_bus.monitor(data);
	 $display("rv data transferred: 0x%x",data);
      end
   end

endmodule
