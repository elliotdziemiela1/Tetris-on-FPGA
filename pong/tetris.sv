//
//	// SDRAM Wire Declaractions
//	logic pll_clk;
//	logic write;
//	logic read;
//	logic [15:0] writedata;
//	logic [15:0] readdata;
//	logic [15:0] writeaddr;
//	logic [15:0] readaddr;
//	logic writeld;
//	logic readld;
module tetris ( input clk,
					 input vs, hs,
					 input key,
					 input reset,
					 input [9:0] DrawX, DrawY,
					 input [15:0] wr_buffer, rd_buffer,
					 input logic [15:0] readdata,
					 output logic write_req, read_req,
					 output logic write_ld, read_ld,
					 output logic [24:0] writeaddr, readaddr,
					 output logic [15:0] writedata,
					 output [7:0] Red, Green, Blue,
					 output [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0
					 );

// Local Declarations					 
logic [15:0] read_reg1;
logic [15:0] read_reg2;
logic [4:0] write_counter;
					 
// State machine for writing to VRAM					 
enum logic [15:0] {Hold1, Hold2, PWA, WA, FWA, PWB, WB, FWB, PWC, WC, FWC, PWD, WD, FWD, PRA, PRB, RA, RB, FRA, FRB, S1, S2} state;

// State machine logic with reset for correct default values of regs
always_ff @(posedge clk or posedge reset)
begin
	if(reset)
		begin	// Default values
		write_counter <= 5'b0;
		read_req <= 1'b0;
		read_ld <= 1'b0;
		readaddr <= 25'b0;
		write_req <= 1'b0;
		write_ld <= 1'b0;
		writeaddr <= 25'b0;
		writedata <= 16'b0;
		state <= Hold1;
		end
	else
		begin
		unique case (state)
			Hold1: if(key)
						state <= Hold2; // Perform writes on vertical sync
			Hold2: if(~key)
						state <= PWA;
//					else if (DrawX == 10'b0 && DrawY == 10'b0)
//						state <= PRA; // Perform reads at top left (For now)
			// Start of the writes
			PWA: begin // Clear buffer and load address
				  write_ld <= 1'b1;
				  writeaddr <= 25'h5653;
				  state <= WA;
				  end
			WA: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 writedata <= 16'h6293; // Send a write request with along with write data
					 state <= FWA;
				 end
			FWA: begin
					 write_req <= 1'b0; // Finish write request
					 if(wr_buffer == 16'b0000 && !write_req)
							state <= PWB; // Go to next write, takes two clock cyles after write request to capture data
				  end
			PWB: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'h81DE;
				  state <= WB;
				  end
			WB: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 writedata <= 16'h460F;
					 state <= FWB;
				 end
			FWB: begin
					 write_req <= 1'b0;
					 if(wr_buffer == 16'h0000 && !write_req)
							state <= PWC;
				  end
			PWC: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'hC0A9;
				  state <= WC;
				  end
			WC: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 writedata <= 16'h12C4;
					 state <= FWC;
				 end
			FWC: begin
					 write_req <= 1'b0;
					 if(wr_buffer == 16'h0000 && !write_req)
							state <= PWD;
				  end
			PWD: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'h0E08;
				  state <= WD;
				  end
			WD: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1; 
					 writedata <= 16'h7D59;
					 state <= FWD;
				 end
			FWD: begin
					 write_req <= 1'b0;
					 if(wr_buffer == 16'h0000 && !write_req)
							state <= PRA;
				 end
			// Start of the reads
			PRA: begin
				  if(write_counter[2])
				  begin
				  write_counter <= 5'b0;
				  read_ld <= 1'b1; // Clear fifo buffer and load read address
				  readaddr <= 25'h0E08;
				  state <= RA;
				  end
				  else
					write_counter <= write_counter + 1'b1;
					end
			RA:  begin
					read_ld <= 1'b0; // Finish read load
					if(rd_buffer == 16'h0001)
						begin
						read_req <= 1'b1; // Call read request to buffer
						state <= FRA; // Go
						end
					end

			FRA: begin
				  read_req <= 1'b0; // Finish single read
				  read_reg1 <= readdata; // Capture data
				  state <= PRB;
				  end
			PRB: begin
				  read_ld <= 1'b1; // Clear fifo buffer and load read address
				  readaddr <= 25'h81DE;
				  state <= RB;
				  end
			RB:  begin
				  read_ld <= 1'b0; // Finish read load
				  if(rd_buffer == 16'h0001)
						begin
						read_req <= 1'b1; // Call read request to buffer
						state <= FRB; // Go
						end
				  end
			FRB: begin
				  read_req <= 1'b0; // Finish single read
				  read_reg2 <= readdata; // Capture data
				  state <= Hold1;
				  end
			default: ;
			endcase
		end	
end
		 
// Read complete contents of reg1
always_comb
begin
	hex_num_0 = read_reg2[3:0];
	hex_num_1 = read_reg2[7:4];
	hex_num_3 = read_reg2[11:8];
	hex_num_4 = read_reg2[15:12];
end

// BlockX and BlockY assumed to be position of block		 
// Color mapper will decide when to write colors of block to vram					 
//color_mapper colormap (.towrite(writeld), .color(writedata) );



endmodule