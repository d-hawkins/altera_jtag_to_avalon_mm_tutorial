// ----------------------------------------------------------------
// de2.sv
//
// 2/21/2012 D. W. Hawkins (dwh@caltech.edu)
//
// SOPC System Example.
//
// The DE2 board hex displays are connected to a counter to show
// the design is loaded and running.
//
// The push-button nearest the right corner of the board,
// key(0), is used as the reset button.
//
// ----------------------------------------------------------------
//

module de2
	(
		// --------------------------------------------------------
		// Input clocks
		// --------------------------------------------------------
		//
		input  logic  clk_50MHz,
		input  logic  clk_27MHz,
		input  logic  clk_sma,

		// --------------------------------------------------------
        // Push-buttons
		// --------------------------------------------------------
		//
        input  logic [3:0] key,

		// --------------------------------------------------------
        // Switches
		// --------------------------------------------------------
		//
        input  logic [17:0] sw,

		// --------------------------------------------------------
        // Red and Green LEDs
		// --------------------------------------------------------
		//
        output logic [17:0] led_r,
        output logic  [8:0] led_g,

		// --------------------------------------------------------
        // Hex displays
		// --------------------------------------------------------
		//
        output logic  [6:0] hex_a,
        output logic  [6:0] hex_b,
        output logic  [6:0] hex_c,
        output logic  [6:0] hex_d,
        output logic  [6:0] hex_e,
        output logic  [6:0] hex_f,
        output logic  [6:0] hex_g,
        output logic  [6:0] hex_h,

		// --------------------------------------------------------
        // Character LCD
		// --------------------------------------------------------
		//
        output logic        lcd_on,
        output logic        lcd_blon,
        output logic        lcd_rs,
        output logic        lcd_en,
        output logic        lcd_rw,
        output logic  [7:0] lcd_d,

		// --------------------------------------------------------
        // USB OTG Controller
		// --------------------------------------------------------
		//
        output logic        otg_resetN,
        output logic        otg_csN,
        output logic        otg_rdN,
        output logic        otg_wrN,
        output logic        otg_fspeed,
        output logic        otg_lspeed,
        input  logic  [1:0] otg_irq,
        input  logic  [1:0] otg_dreq,
        output logic  [1:0] otg_dackN,
        output logic  [1:0] otg_addr,
        inout  logic [15:0] otg_dq,

		// --------------------------------------------------------
        // Audio interface
		// --------------------------------------------------------
		//
        output logic        aud_adclrck,
        output logic        aud_daclrck,
        output logic        aud_dacdat,
        output logic        aud_bclk,
        output logic        aud_xck,
        input  logic        aud_adcdat,

		// --------------------------------------------------------
        // I2C bus (audio interface and TV decoder control)
		// --------------------------------------------------------
		//
        output logic        i2c_sclk,
        inout  logic        i2c_sdat,

		// --------------------------------------------------------
        // TV Decoder
		// --------------------------------------------------------
		//
        output logic        td_resetN,
        input  logic        td_hs,
        input  logic        td_vs,
        input  logic  [7:0] td_d,

		// --------------------------------------------------------
        // VGA
		// --------------------------------------------------------
		//
        output logic        vga_blankN,
        output logic        vga_syncN,
        output logic        vga_hs,
        output logic        vga_vs,
        output logic        vga_clock,
        output logic  [9:0] vga_r,
        output logic  [9:0] vga_g,
        output logic  [9:0] vga_b,

		// --------------------------------------------------------
        // USB Blaster interface
		// --------------------------------------------------------
		//
        input  logic  [2:0] link_in,
        output logic        link_out,

		// --------------------------------------------------------
        // Ethernet controller
		// --------------------------------------------------------
		//
        output logic        enet_clk,
        output logic        enet_resetN,
        output logic        enet_csN,
        output logic        enet_cmd,
        output logic        enet_iowN,
        output logic        enet_iorN,
        input  logic        enet_irqN,
        inout  logic [15:0] enet_dq,

		// --------------------------------------------------------
        // RS232
		// --------------------------------------------------------
		//
        output logic        uart_txd,
        input  logic        uart_rxd,

		// --------------------------------------------------------
        // PS/2
		// --------------------------------------------------------
		//
        output logic        ps2_clk,
        inout  logic        ps2_dat,

		// --------------------------------------------------------
        // SD Card interface
		// --------------------------------------------------------
		//
        output logic        sd_cmd,
        output logic        sd_clk,
        output logic        sd_dat3,
        inout  logic        sd_dat,

		// --------------------------------------------------------
        // IrDA interface
		// --------------------------------------------------------
		//
        output logic        irda_txd,
        input  logic        irda_rxd,

		// --------------------------------------------------------
        // SDRAM
		// --------------------------------------------------------
		//
        output logic        sdram_clk,
        output logic        sdram_cke,
        output logic        sdram_csN,
        output logic        sdram_rasN,
        output logic        sdram_casN,
        output logic        sdram_weN,
        output logic  [1:0] sdram_ba,
        output logic [11:0] sdram_addr,
        output logic  [1:0] sdram_dqm,
        inout  logic [15:0] sdram_dq,

		// --------------------------------------------------------
        // Flash
		// --------------------------------------------------------
		//
        output logic        flash_resetN,
        output logic        flash_ceN,
        output logic        flash_weN,
        output logic        flash_oeN,
        output logic [21:0] flash_addr,
        inout  logic  [7:0] flash_dq,

		// --------------------------------------------------------
        // SRAM
		// --------------------------------------------------------
		//
        output logic        sram_ceN,
        output logic        sram_weN,
        output logic        sram_oeN,
        output logic  [1:0] sram_beN,
        output logic [17:0] sram_addr,
        inout  logic [15:0] sram_dq,

		// --------------------------------------------------------
        // GPIO (expansion headers)
		// --------------------------------------------------------
		//
        inout  logic [35:0] gpio_a,
        inout  logic [35:0] gpio_b
	);

	// ============================================================
	// Local parameters
	// ============================================================
	//
	// Clock frequency
	localparam real CLK_FREQ     = 50.0e6;

	// LED LSB blink period
	localparam real BLINK_PERIOD = 0.5;

	// Counter width
	localparam integer COUNT = CLK_FREQ*BLINK_PERIOD;
	localparam integer WIDTH = $clog2(COUNT) + 3;

	// ============================================================
	// Signals
	// ============================================================
	//
	logic             clk;
	logic             rstN;
	logic [7:0]       led_pio;
	logic [7:0]       button_pio;
	logic [WIDTH-1:0] count;

	// ------------------------------------------------------------
	// Clock and reset
	// ------------------------------------------------------------
	//
	// 50MHz system clock
	assign clk = clk_50MHz;

	// External reset
	// * the SOPC system contains a reset synchronizer
	assign rstN = key[0];

	// ============================================================
	// SOPC System
	// ============================================================
	//
	sopc_system u1 (
      .reset_n                   (rstN),
      .clk                       (clk),
      .out_port_from_the_led_pio (led_pio),
      .in_port_to_the_button_pio (button_pio)
    );

    // Connect to 8-bits of the red and green LEDs
	assign led_r[7:0] = led_pio;
	assign led_g[7:0] = led_pio;

	// Connect to 8-bits of the switches
	assign button_pio = sw[7:0];

	// Connect the remaining LEDs to switches
    assign led_r[17:8] = sw[17:8];
    assign led_g[   8] = sw[   8];

	// ============================================================
	// Hex displays
	// ============================================================
	//
	// ------------------------------------------------------------
	// Counter
	// ------------------------------------------------------------
	//
	always_ff @ (posedge clk, negedge rstN)
	if (~rstN)
		count <= '0;
	else
		count <= count + 1'b1;

	// ------------------------------------------------------------
	// Segment decoders
	// ------------------------------------------------------------
	//
	hex_display u2 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_a)
    );

	hex_display u3 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_b)
    );

	hex_display u4 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_c)
    );

	hex_display u5 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_d)
    );

	hex_display u6 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_e)
    );

	hex_display u7 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_f)
    );

	hex_display u8 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_g)
    );

	hex_display u9 (
        .hex(count[WIDTH-1:WIDTH-4]),
        .display(hex_h)
    );

	// ============================================================
	// Unused outputs and bidirectional signals
	// ============================================================
	//
	// SDRAM
    assign sdram_clk  = 0;
    assign sdram_cke  = 0;
    assign sdram_csN  = 1;
    assign sdram_rasN = 1;
    assign sdram_casN = 1;
    assign sdram_weN  = 1;
    assign sdram_ba   = '0;
    assign sdram_addr = '0;
    assign sdram_dqm  = '0;
    assign sdram_dq   = 'Z;

    // LCD
    assign lcd_on   = 0; // Power supply off
    assign lcd_blon = 0; // Backlight off
    assign lcd_rs   = 0;
    assign lcd_en   = 0;
    assign lcd_rw   = 0;
    assign lcd_d    = '0;

    // USB OTG Controller
    assign otg_resetN = 0; // Reset
    assign otg_csN    = 1;
    assign otg_rdN    = 1;
    assign otg_wrN    = 1;
    assign otg_fspeed = 'Z;
    assign otg_lspeed = 'Z;
    assign otg_dackN  = '1;
    assign otg_addr   = '0;
    assign otg_dq     = 'Z;

    // Audio interface
    assign aud_adclrck = 0;
    assign aud_daclrck = 0;
    assign aud_dacdat  = 0;
    assign aud_bclk    = 0;
    assign aud_xck     = 0;

    // I2C bus (audio interface and TV decoder control)
    assign i2c_sclk = 'Z; // I2C signals are open-drain
    assign i2c_sdat = 'Z;

    // TV Decoder
    assign td_resetN = 0; // Reset

    // VGA
    assign vga_blankN = 1;
    assign vga_syncN  = 1;
    assign vga_hs     = 0;
    assign vga_vs     = 0;
    assign vga_clock  = 0;
    assign vga_r      = '0;
    assign vga_g      = '0;
    assign vga_b      = '0;

    // USB Blaster interface
    assign link_out = 0;

    // Ethernet controller
    assign enet_clk    = 0;
    assign enet_resetN = 0;
    assign enet_csN    = 1;
    assign enet_cmd    = 0;
    assign enet_iowN   = 1;
    assign enet_iorN   = 1;
    assign enet_dq     = 'Z;

    // RS232
    assign uart_txd = 0;

    // PS/2
    assign ps2_clk = 0;
    assign ps2_dat = 'Z;

    // GPIO (expansion headers)
    assign gpio_a = 'Z;
    assign gpio_b = 'Z;

    // SD Card interface
    assign sd_cmd  = 0;
    assign sd_clk  = 0;
    assign sd_dat3 = 0;
    assign sd_dat  = 'Z;

    // IrDA interface
    assign irda_txd = 0;

    // Flash
    assign flash_resetN = 0;
    assign flash_ceN    = 1;
    assign flash_weN    = 1;
    assign flash_oeN    = 1;
    assign flash_addr   = '0;
    assign flash_dq     = 'Z;

    // SRAM
    assign sram_ceN  = 1;
    assign sram_weN  = 1;
    assign sram_oeN  = 1;
    assign sram_beN  = '1;
    assign sram_addr = '0;
    assign sram_dq   = 'Z;

endmodule