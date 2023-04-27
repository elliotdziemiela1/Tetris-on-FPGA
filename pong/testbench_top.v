`timescale 1ns/10ps

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


module testbench_top ();
   reg MAX10_CLK1_50;
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
	wire [7:0] HEX0;
	wire [7:0] HEX1;
	wire [7:0] HEX2;
	wire [7:0] HEX3;
	wire [7:0] HEX4;
	wire [7:0] HEX5;
	reg [1:0] KEY;
	wire [9:0] LEDR;
	reg [9:0] SW;
	wire [7:0] VGA_R;
	wire [7:0] VGA_G;
	wire [7:0] VGA_B;
	wire VGA_HS;
	wire VGA_VS;
 
  // DUT instantiation
  lab62 dut (
        .MAX10_CLK1_50(MAX10_CLK1_50),
        .DRAM_ADDR(DRAM_ADDR),
        .DRAM_BA(DRAM_BA),
        .DRAM_CAS_N(DRAM_CAS_N),
        .DRAM_CKE(DRAM_CKE),
        .DRAM_CLK(DRAM_CLK),
        .DRAM_CS_N(DRAM_CS_N),
        .DRAM_DQ(DRAM_DQ),
        .DRAM_LDQM(DRAM_LDQM),
        .DRAM_RAS_N(DRAM_RAS_N),
        .DRAM_UDQM(DRAM_UDQM),
        .DRAM_WE_N(DRAM_WE_N),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .KEY(KEY),
        .LEDR(LEDR),
        .SW(SW),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
  );
 
  // generate the clock
  always #1 MAX10_CLK1_50 = ~MAX10_CLK1_50;

  
  //Test signals
  initial begin
  KEY[1] = 1'b1;
  #5 KEY[1] = 1'b0;
  #5 KEY[1] = 1'b1;
  end
 
endmodule
