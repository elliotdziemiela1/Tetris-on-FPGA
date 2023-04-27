`timescale 10ns/10ns // 50 MHz clock has 20ns period

//module lab62 (
//
//      ///////// Clocks /////////
//      input     MAX10_CLK1_50,
//		input 	 MAX10_CLK2_50,
//
//      ///////// KEY /////////
//      input    [ 1: 0]   KEY,
//
//      ///////// SW /////////
//      input    [ 9: 0]   SW,
//
//      ///////// LEDR /////////
//      output   [ 9: 0]   LEDR,
//
//      ///////// HEX /////////
//      output   [ 7: 0]   HEX0,
//      output   [ 7: 0]   HEX1,
//      output   [ 7: 0]   HEX2,
//      output   [ 7: 0]   HEX3,
//      output   [ 7: 0]   HEX4,
//      output   [ 7: 0]   HEX5,
//
//      ///////// SDRAM /////////
//      output             DRAM_CLK,
//      output             DRAM_CKE,
//      output   [12: 0]   DRAM_ADDR,
//      output   [ 1: 0]   DRAM_BA,
//      inout    [15: 0]   DRAM_DQ,
//      output             DRAM_LDQM,
//      output             DRAM_UDQM,
//      output             DRAM_CS_N,
//      output             DRAM_WE_N,
//      output             DRAM_CAS_N,
//      output             DRAM_RAS_N,
//
//      ///////// VGA /////////
//      output             VGA_HS,
//      output             VGA_VS,
//      output   [ 3: 0]   VGA_R,
//      output   [ 3: 0]   VGA_G,
//      output   [ 3: 0]   VGA_B,
//
//
//      ///////// ARDUINO /////////
//      inout    [15: 0]   ARDUINO_IO,
//      inout              ARDUINO_RESET_N 
//
//);




module testbench_controller ();
	// Host side signals
   reg MAX10_CLK1_50;
	// SDRAM Wire Declaractions
	wire pll_clk;
	reg write_req, read_req;
	reg write_ld, read_ld;
	wire rd_empty;
	wire wr_full;
	reg [15:0] writedata;
	wire [15:0] readdata;
	wire [15:0] wr_use, rd_use;
	reg reset;
	//reg [24:0] writeaddr;
	//reg [24:0] readaddr;
	// SDRAM side signals
	wire [12:0] DRAM_ADDR;
	wire [1:0] DRAM_BA;
	wire DRAM_CAS_N;
	wire DRAM_CKE;
	wire DRAM_CLK;
	wire DRAM_CS_N;
	wire [15:0] DRAM_DQ;
	wire DRAM_LDQM;
	wire DRAM_RAS_N;
	wire DRAM_UDQM;
	wire DRAM_WE_N;
  // SDRAM Controller Instantiation
Sdram_Control sdram_controller (	//	HOST Side
						   .REF_CLK(MAX10_CLK1_50),
					      .RESET_N(reset),
							//	FIFO Write Side 
						   .WR_DATA(writedata),
							.WR(write_req),
							.WR_ADDR(25'b1),
							.WR_MAX_ADDR(25'h1ffffff),		//	65535 is max addr
							.WR_LENGTH(9'h01), // length 16
							.WR_LOAD(write_ld),
							.WR_CLK(pll_clk),
							.WR_FULL(wr_full),
							.WR_USE(wr_use),
							//	FIFO Read Side 
						   .RD_DATA(readdata),
				        	.RD(read_req),
				        	.RD_ADDR(25'b1),			
							.RD_MAX_ADDR(25'h1ffffff), // 65535 is max addr
							.RD_LENGTH(9'h01), // length 16
				        	.RD_LOAD(read_ld),
							.RD_CLK(pll_clk),
							.RD_EMPTY(rd_empty),
							.RD_USE(rd_use),
                     //	SDRAM Side
						   .SA(DRAM_ADDR),
						   .BA(DRAM_BA),
						   .CS_N(DRAM_CS_N),
						   .CKE(DRAM_CKE),
						   .RAS_N(DRAM_RAS_N),
				         .CAS_N(DRAM_CAS_N),
				         .WE_N(DRAM_WE_N),
						   .DQ(DRAM_DQ),
				         .DQM({DRAM_UDQM,DRAM_LDQM}),
							.SDR_CLK(DRAM_CLK)	);
							
sdram_pll0 pll ( .areset (),
					 .inclk0(MAX10_CLK1_50),
					 .c0(pll_clk),
	             .c1(),
	             .locked());
 
  // generate the clock
    // generate the clock
  initial begin
    MAX10_CLK1_50 = 1'b0;
    forever #1 MAX10_CLK1_50 = ~MAX10_CLK1_50;
  end
  
  //Test signals
  initial 
  begin
  // IC
  reset = 1'b0;
  write_ld = 1'b0;
  read_ld = 1'b0;
  read_req = 1'b0;
  write_req = 1'b0;
  writedata = 16'hff; // Send a write request with along with write data
  
  //#11  write_ld = 1'b1;
  //#2 write_ld = 1'b0;
  //#1 writedata = 16'hff;
  #20 write_req = 1'b1;
		reset = 1'b1;
  #20 write_req = 1'b0;
		write_ld = 1'b1;


  //#5 read_req = 1'b1;
  //#2 read_req = 1'b0;
  end
 
endmodule
