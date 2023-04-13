// Ricoh 2A03 cpu

module CPU (
				input         Clk,
            input         reset,
            input [7:0]   Data_from_RAM,
            output        write,
            output [7:0]  Data_to_RAM,
            output [15:0] addr
);


// general purpose registers
logic [7:0] A; // Accumulator
logic [7:0] X; // Index register X
logic [7:0] Y; // Index register Y
logic [7:0] S; // Stack pointer
logic [7:0] P; // Processor status
logic [7:0] PC; // Program Counter


control ctrl ();
datapath dpth ();

	




endmodule 