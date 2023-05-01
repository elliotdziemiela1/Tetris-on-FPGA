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
					 input row_ld, // When to load row
					 input [7:0] row,
					 input [6:0] preX [4],
					 input [6:0] preY [4],
					 input [6:0] postX [4],
					 input [6:0] postY [4],
					 input [9:0] DrawX, DrawY,
					 input [15:0] wr_buffer, rd_buffer,
					 input [15:0] readdata,
					 output logic row_ready, // Send ready signal when done processing row
					 output logic write_req, read_req,
					 output logic write_ld, read_ld,
					 output logic [24:0] writeaddr, readaddr,
					 output logic [15:0] writedata,
					 output [7:0] Red, Green, Blue,
	       output [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0,
	       output [15:0] read_reg [10]
					 );

// Local Declarations					 
//logic [15:0] read_reg [10]; // data for an entire row
logic [4:0] write_counter;
logic [4:0] read_counter;
logic [24:0] pre_block_addr [4];
logic [24:0] post_block_addr [4];
logic [24:0] row_addr;
logic clear_flag;
logic [15:0] bckgrd_clr;
logic [15:0] blck_clr;
logic [15:0] readdata_reg [10];
logic update_flag;
					 
// State machine for writing to VRAM					 
enum logic [15:0] {Hold1, Hold2, Intermediate, PulseRead1, PulseRead2,
						 PWA, WA, FWA, PWB, WB, FWB, PWC, WC, FWC, PWD, WD, FWD,
						PRA, PRB, RA, RB, FRA, FRB, RAI, QWA, QWB, QWC, QWD} state;

// State machine logic with reset for correct default values of regs
always_ff @(posedge clk or posedge reset)
begin
	if(reset)
		begin	// Default values
		clear_flag <= 1'b0;
		update_flag <= 1'b0;
		row_ready <= 1'b0;
		write_counter <= 5'b0;
		read_counter <= 5'b0;
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
			Hold1:   begin 
							row_ready <= 1'b0;
							if(vs && !update_flag) // First clear previous locations
								begin
								update_flag <= 1'b1;
								state <= PWA;
								clear_flag <= 1'b1;
								end
							else if(row_ld)
								state <= PRA;
							else if(~vs)
								update_flag <= 1'b0;
						end
//			Intermediate: begin
//								if(~key)
//									state <= PRA;
//							  end
			Hold2:   begin // Second write new locations
						state <= PWA;
						clear_flag <= 1'b0;
						end
			// 4 consecutive random writes 
			PWA: begin // Clear buffer and load address
				  write_ld <= 1'b1;
				  if(clear_flag)
						writeaddr <= pre_block_addr[0];
				  else
						writeaddr <= post_block_addr[0];
				  state <= WA;
				  end
			WA: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 if(clear_flag)
							writedata <= bckgrd_clr; // Send a write request with along with write data
					 else
							writedata <= blck_clr;
					 state <= QWA;
				 end
			QWA: begin
					write_req <= 1'b0; // Finish write request
					if(write_counter[1])
						begin
						write_counter <= 5'b0;
						state <= FWA;
						end
					else 
						write_counter <= write_counter + 1'b1;
					end
			FWA: begin
					 if(wr_buffer == 16'b0000)
							state <= PWB; // Go to next write, takes two clock cyles after write request to capture data
				  end
			PWB: begin
			     write_ld <= 1'b1;
				  if(clear_flag)
						writeaddr <= pre_block_addr[1];
				  else
						writeaddr <= post_block_addr[1];
				  state <= WB;
				  end
			WB: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 if(clear_flag)
							writedata <= bckgrd_clr; // Send a write request with along with write data
					 else
							writedata <= blck_clr;
					 state <= QWB;
				 end
			QWB: begin
					write_req <= 1'b0; // Finish write request
					if(write_counter[1])
						begin
						write_counter <= 5'b0;
						state <= FWB;
						end
					else 
						write_counter <= write_counter + 1'b1;
					end
			FWB: begin
					 write_req <= 1'b0;
					 if(wr_buffer == 16'h0000 && !write_req)
							state <= PWC;
				  end
			PWC: begin
			     write_ld <= 1'b1;
				  if(clear_flag)
						writeaddr <= pre_block_addr[2];
				  else
						writeaddr <= post_block_addr[2];
				  state <= WC;
				  end
			WC: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1;
					 if(clear_flag)
							writedata <= bckgrd_clr; // Send a write request with along with write data
					 else
							writedata <= blck_clr;
					 state <= QWC;
				 end
			QWC: begin
					write_req <= 1'b0; // Finish write request
					if(write_counter[1])
						begin
						write_counter <= 5'b0;
						state <= FWC;
						end
					else 
						write_counter <= write_counter + 1'b1;
					end
			FWC: begin
					 write_req <= 1'b0;
					 if(wr_buffer == 16'h0000 && !write_req)
							state <= PWD;
				  end
			PWD: begin
			     write_ld <= 1'b1;
				  if(clear_flag)
						writeaddr <= pre_block_addr[3];
				  else
						writeaddr <= post_block_addr[3];
				  state <= WD;
				  end
			WD: begin
					 write_ld <= 1'b0;
					 write_req <= 1'b1; 
					 if(clear_flag)
							writedata <= bckgrd_clr; // Send a write request with along with write data
					 else
							writedata <= blck_clr;
					 state <= QWD;
				 end
			QWD: begin
					write_req <= 1'b0; // Finish write request
					if(write_counter[1])
						begin
						write_counter <= 5'b0;
						state <= FWD;
						end
					else 
						write_counter <= write_counter + 1'b1;
					end
			FWD: begin
					 write_req <= 1'b0;
					 if(wr_buffer == 16'h0000 && !write_req)
						begin	
							if(clear_flag)
								state <= Hold2;
							else
								state<= Hold1;
						end
				 end
				 
				 
			// Burst read an entire row
			PRA: begin
				  if(write_counter[2])
				  begin
				  write_counter <= 5'b0;
				  read_ld <= 1'b1; // Clear fifo buffer and load read address
				  readaddr <= row_addr;
				  state <= RA;
				  end
				  else
					write_counter <= write_counter + 1'b1;
					end
			RA:  begin
					read_ld <= 1'b0; // Finish read load
						if(rd_buffer == 16'h0A) // read buffer is of size 10
							begin
							read_req <= 1'b1; // Call read request to buffer
							state <= RAI; // Go
							end
					end
			RAI: begin
				  readdata_reg[write_counter] <= readdata; // Capture data in burst
				  state <= FRA;
				  end
			FRA: begin
				  if(rd_buffer == 16'b0) // If count to 8 in order to read 20 words
						begin
						row_ready <= 1'b1;
						write_counter <= 5'b0;
						read_req <= 1'b0;
						state <= Hold1;
						end
					else
						begin
						readdata_reg[write_counter] <= readdata; // Capture data in burst
						write_counter <= write_counter + 1'b1;
						end
				  end
				  
//			PulseRead1: begin
////							if(write_counter == 5'b0)
//								readdata_reg[0] <= readdata; // Capture data in burst
//							state <= PulseRead2;
//							end
//			PulseRead2: begin
//							//read_reg[write_counter] <= readdata_reg[write_counter];
//							state <= FRA;
//							end
//			PRB: begin
//				  read_ld <= 1'b1; // Clear fifo buffer and load read address
//				  readaddr <= 25'h81DE;
//				  state <= RB;
//				  end
//			RB:  begin
//				  read_ld <= 1'b0; // Finish read load
//				  if(rd_buffer == 16'h0001)
//						begin
//						read_req <= 1'b1; // Call read request to buffer
//						state <= FRB; // Go
//						end
//				  end
//			FRB: begin
//				  read_req <= 1'b0; // Finish single read
//				  read_reg2 <= readdata; // Capture data
//				  state <= Hold1;
//				  end
			default: ;
			endcase
		end	
end
	

//logic [6:0] blockXPos [4];
//logic [6:0] blockYPos [4];
//logic [6:0] blockXPrev [4];
//logic [6:0] blockYPrev [4];
//logic [3:0] blockColor;

// Address computation for blocks
always_comb
begin
// Previous blocks
pre_block_addr[0] = {18'b0,((10*preY[0])+preX[0])};
pre_block_addr[1] = {18'b0,((10*preY[1])+preX[1])};
pre_block_addr[2] = {18'b0,((10*preY[2])+preX[2])};
pre_block_addr[3] = {18'b0,((10*preY[3])+preX[3])};
// Next blocks
post_block_addr[0] = {18'b0,((10*postY[0])+postX[0])};
post_block_addr[1] = {18'b0,((10*postY[1])+postX[1])};
post_block_addr[2] = {18'b0,((10*postY[2])+postX[2])};
post_block_addr[3] = {18'b0,((10*postY[3])+postX[3])};
// Address of row
row_addr = {17'b0,(10*row)};
// Colors
bckgrd_clr = 16'h0f05; // White
blck_clr = 16'h005f; // Black
// Assign outputs combinationally to ensure correct reads
read_reg[0] = readdata_reg[0];
read_reg[1] = readdata_reg[1];
read_reg[2] = readdata_reg[2];
read_reg[3] = readdata_reg[3];
read_reg[4] = readdata_reg[4];
read_reg[5] = readdata_reg[5];
read_reg[6] = readdata_reg[6];
read_reg[7] = readdata_reg[7];
read_reg[8] = readdata_reg[8];
read_reg[9] = readdata_reg[9];
end


		 
// Read complete contents of reg2
//always_comb
//begin
//	hex_num_0 = read_reg2[3:0];
//	hex_num_1 = read_reg2[7:4];
//	hex_num_3 = read_reg2[11:8];
//	hex_num_4 = read_reg2[15:12];
//end

// BlockX and BlockY assumed to be position of block		 
// Color mapper will decide when to write colors of block to vram					 
//color_mapper colormap (.towrite(writeld), .color(writedata) );



endmodule
