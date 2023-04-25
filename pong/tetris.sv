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
					 input reset,
					 input [9:0] DrawX, DrawY,
					 input wr_full, rd_empty,
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
enum logic [15:0] {Hold, PWA, WA, FWA, PWB, WB, FWB, PWC, WC, FWC, PWD, WD, FWD, PRA, PRB, RA, RB, FRA, FRB} state;

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
		state <= Hold;
		end
	else
		begin
		unique case (state)
			Hold: if(vs)
						state <= PWA; // Perform writes on vertical sync
					else if (DrawX == 10'b0 && DrawY == 10'b0)
						state <= PRA; // Perform reads at top left (For now)
			// Start of the writes
			PWA: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'h00; // Clear fifo buffer and load write address
				  state <= WA;
				  end
			WA: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 writedata <= 16'hff; // Send a write request with along with write data
					 state <= FWA;
				 end
			FWA: begin
					 write_req <= 1'b0; // Finish write request
					 state <= PWB; // Go to next write, takes two clock cyles after write request to capture data
				  end
			PWB: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'h01;
				  state <= WB;
				  end
			WB: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 writedata <= 16'hff;
					 state <= FWB;
				 end
			FWB: begin
					 write_req <= 1'b0;
					 state <= PWC;
				  end
			PWC: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'h02;
				  state <= WC;
				  end
			WC: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 writedata <= 16'hff;
					 state <= FWC;
				 end
			FWC: begin
					 write_req <= 1'b0;
					 state <= PWD;
				  end
			PWD: begin
			     write_ld <= 1'b1;
				  writeaddr <= 25'h03;
				  state <= WD;
				  end
			WD: begin
					 write_ld <= 1'b0;
					 if(write_counter[3])
						begin
							write_counter <= 5'b0;
							write_req <= 1'b1; 
							writedata <= 16'hff;
							state <= FWD;
						end
					  else
					   begin
						write_counter <= write_counter + 1'b1;
						end
				 end
			FWD: begin
					 write_req <= 1'b0;
					 state <= Hold;
				 end
			// Start of the reads
			PRA: begin
				  read_ld <= 1'b1; // Clear fifo buffer and load read address
				  readaddr <= 25'h03;
				  state <= RA;
				  end
			RA:  begin
				  read_ld <= 1'b0; // Finish read load
				  if(write_counter[3])
					begin
				    if(!rd_empty)
						begin
						write_counter <= 5'b0;
						read_req <= 1'b1; // Call read request to buffer
						state <= FRA; // Go
						end
					 end
					else
					 begin
					 write_counter <= write_counter + 1'b1;
					 end
					end

			FRA: begin
				  read_req <= 1'b0; // Finish single read
				  read_reg1 <= readdata; // Capture data
				  state <= PRB;
				  end
			PRB: begin
				  read_ld <= 1'b1; // Clear fifo buffer and load read address
				  readaddr <= 25'h00;
				  state <= RB;
				  end
			RB:  begin
				  read_ld <= 1'b0; // Finish read load
				  if(!rd_empty)
						begin
						read_req <= 1'b1; // Call read request to buffer
						state <= FRB; // Go
						end
				  end
			FRB: begin
				  read_req <= 1'b0; // Finish single read
				  read_reg2 <= readdata; // Capture data
				  state <= Hold;
				  end
			default: ;
			endcase
		end	
end
		 
// Output read registers to the hex displays
always_comb
begin
	hex_num_0 = read_reg1[3:0];
	hex_num_3 = read_reg2[3:0];
end

// BlockX and BlockY assumed to be position of block		 
// Color mapper will decide when to write colors of block to vram					 
//color_mapper colormap (.towrite(writeld), .color(writedata) );



endmodule
