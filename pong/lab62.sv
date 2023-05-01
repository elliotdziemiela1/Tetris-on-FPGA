//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50,
		input 	 MAX10_CLK2_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, blockx1sig, blocky1sig, blockx2sig, blocky2sig, blockx3sig, blocky3sig, blockx4sig, blocky4sig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;
	
	// SDRAM Wire Declaractions
	logic pll_clk;
	logic write_req, read_req;
	logic write_ld, read_ld;
	logic [15:0] rd_buffer;
	logic [15:0] wr_buffer;
	logic [15:0] writedata;
	logic [15:0] readdata;
	logic [24:0] writeaddr;
	logic [24:0] readaddr;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	// Key 1 for testing sdram	
	logic key;
	assign {key}=~ (KEY[1]);
	
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		// PLL NOT IN USE!!
//		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
//		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
//		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM NOT IN USE!!
//		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
//		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
//		.sdram_wire_ba(DRAM_BA),                             //.ba
//		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
//		.sdram_wire_cke(DRAM_CKE),                           //.cke
//		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
//		.sdram_wire_dq(DRAM_DQ),                             //.dq
//		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
//		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
//		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		//.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}), //Hex currently wired to tetris
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode)
		
	 );


//instantiate a vga_controller, ball, and color_mapper here with the ports.

sdram_pll0 pll ( .areset (),
					 .inclk0(MAX10_CLK2_50),
					 .c0(pll_clk),
	             .c1(),
	             .locked());

Sdram_Control sdram_controller (	//	HOST Side
						   .REF_CLK(MAX10_CLK1_50),
					      .RESET_N(1'b1),
							//.CLK(pll_clk),
							//	FIFO Write Side 
						   .WR_DATA(writedata),
							.WR(write_req),
							.WR_ADDR(writeaddr),
							.WR_MAX_ADDR(25'h1ffffff),		
							.WR_LENGTH(9'h01), // write one word (CHECK THIS FIRST!!)
							.WR_LOAD(write_ld),
							.WR_CLK(pll_clk),
							.WR_USE(wr_buffer),
							//	FIFO Read Side 
						   .RD_DATA(readdata),
				        	.RD(read_req),
				        	.RD_ADDR(readaddr),			
							.RD_MAX_ADDR(25'h1ffffff), 
							.RD_LENGTH(9'h0A), // read ten words
				        	.RD_LOAD(read_ld),
							.RD_CLK(pll_clk),
							.RD_USE(rd_buffer),
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

//module tetris ( input clk,
//					 inout vs,
//					 input [15:0] readdata,
//					 output write, read,
//					 output [15:0] writeaddr, readaddr,
//					 output [15:0] writedata,
//					 output [7:0] Red, Green, Blue
//					 );							
							
logic [6:0] blockXPos [4];
logic [6:0] blockYPos [4];
logic [6:0] blockXPrev [4];
logic [6:0] blockYPrev [4];
logic [3:0] blockColor;
logic LD_Row, rowReady;

logic [15:0] Row [10];
logic [7:0] rowNum;
							
tetris tet (.*, .read_reg(Row), .clk(MAX10_CLK1_50), .vs(~VGA_VS), .hs(~VGA_HS), .reset(Reset_h), .DrawX(drawxsig), .DrawY(drawysig), .row(rowNum), .row_ready(rowReady), .row_ld(LD_Row), .preX(blockXPrev), .preY(blockYPrev), .postX(blockXPos), .postY(blockYPos), .Red(), .Green(), .Blue()); // Tetris instantiation
	
Game_Logic game (.Reset(Reset_h), .frame_clk(~VGA_VS), .keycode(keycode), .blockXPos(blockXPos), .blockYPos(blockYPos), .blockXPrev(blockXPrev), .blockYPrev(blockYPrev), .blockColor(blockColor));

//color_mapper colormap (.blockx1(blockXPos[0]), .blocky1(blockYPos[0]), .blockx2(blockXPos[1]), .blocky2(blockYPos[1]), .blockx3(blockXPos[2]), 
//	.blocky3(blockYPos[2]), .blockx4(blockXPos[3]), .blocky4(blockYPos[3]), .DrawX(drawxsig), .DrawY(drawysig), .Ball_size(ballsizesig), .Red(Red), .Green(Green), .Blue(Blue));

color_mapper colormap (.reset(Reset_h), .Clk(Clk), .hs(~VGA_HS), .LD_Row(LD_Row), .rowReady(rowReady), .Row(Row), .rowNum(rowNum), .DrawX(drawxsig), .DrawY(drawysig), .Red(Red), .Green(Green), .Blue(Blue));

vga_controller vga_ctrl (.Clk(MAX10_CLK1_50), .Reset(1'b0), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(), .blank(), .sync(), .DrawX(drawxsig), .DrawY(drawysig));



endmodule
