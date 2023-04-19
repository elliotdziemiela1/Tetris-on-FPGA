	component lab62_soc is
		port (
			clk_clk                        : in  std_logic                     := 'X';             -- clk
			hex_digits_export              : out std_logic_vector(15 downto 0);                    -- export
			key_external_connection_export : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			keycode_export                 : out std_logic_vector(7 downto 0);                     -- export
			keys_wire_export               : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			leds_export                    : out std_logic_vector(13 downto 0);                    -- export
			reset_reset_n                  : in  std_logic                     := 'X';             -- reset_n
			spi0_MISO                      : in  std_logic                     := 'X';             -- MISO
			spi0_MOSI                      : out std_logic;                                        -- MOSI
			spi0_SCLK                      : out std_logic;                                        -- SCLK
			spi0_SS_n                      : out std_logic;                                        -- SS_n
			usb_gpx_export                 : in  std_logic                     := 'X';             -- export
			usb_irq_export                 : in  std_logic                     := 'X';             -- export
			usb_rst_export                 : out std_logic                                         -- export
		);
	end component lab62_soc;

	u0 : component lab62_soc
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                     clk.clk
			hex_digits_export              => CONNECTED_TO_hex_digits_export,              --              hex_digits.export
			key_external_connection_export => CONNECTED_TO_key_external_connection_export, -- key_external_connection.export
			keycode_export                 => CONNECTED_TO_keycode_export,                 --                 keycode.export
			keys_wire_export               => CONNECTED_TO_keys_wire_export,               --               keys_wire.export
			leds_export                    => CONNECTED_TO_leds_export,                    --                    leds.export
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                   reset.reset_n
			spi0_MISO                      => CONNECTED_TO_spi0_MISO,                      --                    spi0.MISO
			spi0_MOSI                      => CONNECTED_TO_spi0_MOSI,                      --                        .MOSI
			spi0_SCLK                      => CONNECTED_TO_spi0_SCLK,                      --                        .SCLK
			spi0_SS_n                      => CONNECTED_TO_spi0_SS_n,                      --                        .SS_n
			usb_gpx_export                 => CONNECTED_TO_usb_gpx_export,                 --                 usb_gpx.export
			usb_irq_export                 => CONNECTED_TO_usb_irq_export,                 --                 usb_irq.export
			usb_rst_export                 => CONNECTED_TO_usb_rst_export                  --                 usb_rst.export
		);

