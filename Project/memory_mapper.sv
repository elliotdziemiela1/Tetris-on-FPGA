parameter
	PPU_regs = 0x2000,
	APU_IO_regs = 0x4000,
	Cartridge_space = 0x4020;

module memory_mapper (
	input [15:0] addr,
	input [7:0] Data_to_SDRAM,
	input [7:0] D_out,
	output [7:0] Data_from_SDRAM,
	output [7:0] D_in
);

always_comb begin
	if (addr >= PPU_regs)
		D_out = 
end

endmodule 