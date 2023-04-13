// Ricoh 2A03 cpu

module CPU (
				input         Clk,
            input         reset,
				input [7:0] D_in,
				output [7:0] D_out,
            output        write,
            output [15:0] addr
);


// general purpose registers
logic [7:0] A; // Accumulator
logic [7:0] X; // Index register X
logic [7:0] Y; // Index register Y
logic [7:0] S; // Stack pointer
logic [7:0] P; // Processor status
logic [7:0] PC; // Program Counter
logic [7:0] IR; // Instruction Register

logic [7:0] A_in; // Accumulator
logic [7:0] X_in; // Index register X
logic [7:0] Y_in; // Index register Y
logic [7:0] S_in; // Stack pointer
logic [7:0] P_in; // Processor status
logic [7:0] PC_in; // Program Counter
logic [7:0] IR_in; // Instruction Register

logic LD_A; // Accumulator
logic LD_X; // Index register X
logic LD_Y; // Index register Y
logic LD_S; // Stack pointer
logic LD_P; // Processor status
logic LD_PC; // Program Counter
logic LD_IR; // Instruction Register

always_ff (@posedge Clk) begin
	if (LD_PC)
		PC <= PC_in;
end


logic [15:0] address;

always_ff (@posedge Clk) begin
	addr <= address;
end

control ctrl ();
datapath dpth ();

	




endmodule 