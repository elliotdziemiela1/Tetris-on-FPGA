// Top level module 

module NES (

);

PPU ppu();
CPU cpu (
	.Clk (Clk),
	.reset (reset),
	.D_in (d_in),
	.D_out (d_out),
	.write (write),
	.addr (addr)
);
memory_mapper mmap(
	.D_in (d_in),
	.D_out (d_out),
	.addr(addr),
	.Data_to_SDRAM(),
	Data_from_SDRAM()
	);
// SDRAM controller initialization
	
	
logic [7:0] d_in, d_out;
logic [15:0] addr;



endmodule 