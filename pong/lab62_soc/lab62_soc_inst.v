	lab62_soc u0 (
		.clk_clk                        (<connected-to-clk_clk>),                        //                     clk.clk
		.hex_digits_export              (<connected-to-hex_digits_export>),              //              hex_digits.export
		.key_external_connection_export (<connected-to-key_external_connection_export>), // key_external_connection.export
		.keycode_export                 (<connected-to-keycode_export>),                 //                 keycode.export
		.keys_wire_export               (<connected-to-keys_wire_export>),               //               keys_wire.export
		.leds_export                    (<connected-to-leds_export>),                    //                    leds.export
		.reset_reset_n                  (<connected-to-reset_reset_n>),                  //                   reset.reset_n
		.spi0_MISO                      (<connected-to-spi0_MISO>),                      //                    spi0.MISO
		.spi0_MOSI                      (<connected-to-spi0_MOSI>),                      //                        .MOSI
		.spi0_SCLK                      (<connected-to-spi0_SCLK>),                      //                        .SCLK
		.spi0_SS_n                      (<connected-to-spi0_SS_n>),                      //                        .SS_n
		.usb_gpx_export                 (<connected-to-usb_gpx_export>),                 //                 usb_gpx.export
		.usb_irq_export                 (<connected-to-usb_irq_export>),                 //                 usb_irq.export
		.usb_rst_export                 (<connected-to-usb_rst_export>)                  //                 usb_rst.export
	);

