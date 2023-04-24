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
					 input logic [9:0] DrawX, DrawY,
					 input wr_full, rd_empty,
					 input [15:0] readdata,
					 output write, read,
					 output [15:0] writeaddr, readaddr,
					 output [15:0] writedata,
					 output logic [7:0] Red, Green, Blue,
					 output logic [3:0] hex0, hex1, hex2, hex3
					 );

// Local Declarations					 
logic [15:0] read_reg1;
logic [15:0] read_reg2;
					 
// State machine for writing to VRAM					 
enum logic [15:0] {Hold, PR1,PR2, WA, WAF, WB, WBF, WC, WCF, WD, WDF, RA, RB, RC, RD} state, next_state;

// Move to next state on clk
always_ff @(posedge clk)
begin
	state <= next_state;
	unique case (state)
		RA: read_reg1 <= readdata;
		RB: read_reg2 <= readdata;
	endcase
		
end

// Next state transition for the state machine	
always_comb
begin
	next_state = state;
	read = 1'b0;
	readaddr = 16'b0;
	write = 1'b0;
	writeaddr = 16'b0;
	writedata = 16'b0;
	unique case (state)
		Hold: if(vs)
					next_state = WA;
				else if (DrawX == 10'b0 && DrawY == 10'b0)
					next_state = RA;
		// Waits for DQM before going through four write states that occur on consecutive clock cycles		
		WA: begin
				 write = 1'b1; // Write request
				 writeaddr = 16'h00; // Write address
				 writedata = 16'h00;
				 next_state = WAF;
			 end
		WAF: begin
			    write = 1'b0;
				 if(!wr_full)
						next_state = WB;
			  end
		WB: begin
				 write = 1'b1; // Write request
				 writeaddr = 16'h01; // Write address
				 writedata = 16'h01;
				 next_state = WBF;
			 end
		WBF: begin
			    write = 1'b0;
				 if(!wr_full)
						next_state = WC;
			  end
		WC: begin
				 write = 1'b1; // Write request
				 writeaddr = 16'h02; // Write address
				 writedata = 16'h02;
				 next_state = WCF;
			 end
		WCF: begin
			    write = 1'b0;
				 if(!wr_full)
						next_state = WD;
			  end
		WD: begin
				 write = 1'b1; // Write request
				 writeaddr = 16'h03; // Write address
				 writedata = 16'h03;
				 next_state = WDF;
			 end
		WDF: begin
			    write = 1'b0;
				 if(!wr_full)
						next_state = Hold;
			 end
		PR1: begin
			  read = 1'b1;
			  readaddr = 16'h03;
			  next_state = RA;
			  end
		RA:  begin
		     read = 1'b0;
			  if(!rd_empty)
					next_state = PR2;
			  end
		PR2: begin
			  read = 1'b1;
			  readaddr = 16'h04;
			  next_state = RB;
			  end
		RB:  begin
		     read = 1'b0;
			  if(!rd_empty)
		         next_state = Hold;
			  end
	endcase
end
					 

always_comb
begin
	if(read_reg1 == 16'h03)
		begin
		hex0 = 4'h3;
		end
	else
		begin
		hex0 = 4'h5;
		end

end

// BlockX and BlockY assumed to be position of block		 
// Color mapper will decide when to write colors of block to vram					 
//color_mapper colormap (.towrite(writeld), .color(writedata) );



endmodule
