
module lab62_soc (
	clk_clk,
	hex_digits_export,
	key_external_connection_export,
	keycode_export,
	keys_wire_export,
	leds_export,
	reset_reset_n,
	spi0_MISO,
	spi0_MOSI,
	spi0_SCLK,
	spi0_SS_n,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export);	

	input		clk_clk;
	output	[15:0]	hex_digits_export;
	input	[1:0]	key_external_connection_export;
	output	[7:0]	keycode_export;
	input	[1:0]	keys_wire_export;
	output	[13:0]	leds_export;
	input		reset_reset_n;
	input		spi0_MISO;
	output		spi0_MOSI;
	output		spi0_SCLK;
	output		spi0_SS_n;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
endmodule
