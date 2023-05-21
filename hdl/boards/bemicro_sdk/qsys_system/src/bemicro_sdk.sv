// ----------------------------------------------------------------
// bemicro_sdk.sv
//
// 5/21/2011 D. W. Hawkins (dwh@caltech.edu)
//
// Qsys System Example.
//
// The LED MSB is connected to a blinking counter to show
// the design is loaded and running.
//
// ----------------------------------------------------------------
//
module bemicro_sdk
	(
		// --------------------------------------------------------
		// Clock
		// --------------------------------------------------------
		//
		// 50MHz oscillator
		input  logic       clkin_50MHz,

		// --------------------------------------------------------
		// User I/O
		// --------------------------------------------------------
		//
		// Push buttons
		input  logic       cpu_rstN,
		input  logic       pb,

		// Switches (the PCB has the switch numbers)
		input  logic [2:1] sw,

		// LEDs
		output logic [7:0] led,

		// --------------------------------------------------------
		// SPI temperature sensor
		// --------------------------------------------------------
		//
		output logic       spi_sck,
		output logic       spi_csN,
		output logic       spi_mosi,
		input  logic       spi_miso,

		// --------------------------------------------------------
		// Ethernet PHY
		// --------------------------------------------------------
		//
		// I2C interface
		output logic       eth_mdc,
		inout  logic       eth_mdio,

		// PHY interface
		input  logic       eth_tx_clk,
		input  logic       eth_rx_clk,
		output logic       eth_rstN,
		input  logic       eth_col,
		input  logic       eth_crs,
		input  logic       eth_rx_er,
		input  logic       eth_rx_dv,
		output logic       eth_tx_en,
		output logic [3:0] eth_txd,
		input  logic [3:0] eth_rxd,

		// --------------------------------------------------------
		// MicroSD card slot
		// --------------------------------------------------------
		//
		output logic       sd_clk,
		output logic       sd_cmd,
		inout  logic [3:0] sd_dat,

		// --------------------------------------------------------
		// Mobile DDR memory
		// --------------------------------------------------------
		//
		// Differential clock
		output logic        ddr_ck_p,
		output logic        ddr_ck_n,

		// Controls
		output logic        ddr_csN,
		output logic        ddr_rasN,
		output logic        ddr_casN,
		output logic        ddr_weN,
		output logic        ddr_cke,

		// Data mask (write byte-enable)
		output logic [1:0]  ddr_dqm,

		// Data strobe
		inout  logic [1:0]  ddr_dqs,

		// Address outputs
		output logic [13:0] ddr_a,
		output logic  [1:0] ddr_ba,

		// Bidirectional 16-bit data bus
		inout  logic [15:0] ddr_dq,

		// --------------------------------------------------------
		// GPIO (expansion connector)
		// --------------------------------------------------------
		//
		// Reset from the expansion board
		input  logic        exp_rstN,

		// Expansion board present (when high)
		input  logic        exp_present,

		// GPINs (with external pull-downs)
		input  logic  [3:0] exp_gpin,

		// GPIOs
		inout  logic [54:4] exp_gpio

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
	localparam integer WIDTH = $clog2(COUNT);

	// ============================================================
	// Signals
	// ============================================================
	//
	logic             clk;
	logic             rstN;
	logic [7:0]       led_pio;
	logic [7:0]       button_pio;
	logic             resetrequest;
	logic [WIDTH-1:0] count;

	// ------------------------------------------------------------
	// Clock and reset
	// ------------------------------------------------------------
	//
	// 50MHz system clock
	assign clk = clkin_50MHz;

	// External reset
	// * the SOPC system contains a reset synchronizer
	assign rstN = cpu_rstN;

	// ============================================================
	// SOPC System
	// ============================================================
	//
	qsys_system u1 (
		.clk_clk(clk),
		.reset_reset_n(rstN),
		.led_export(led_pio),
		.button_export(button_pio),
		.resetrequest_reset(resetrequest)
	);

    // Connect to the LEDs
    // * a low on the pin turns the LED on, so invert the
    //   control register value
	assign led[5:0] = ~led_pio[5:0];

	// Route the resetrequest line to an LED too
	assign led[6] = ~resetrequest;

	// Connect the button and switches
	// * the push button input is normally high (not pressed),
	//   invert the pb input so that the register bit is high
	//   when the button is pressed
	assign button_pio = {5'b0, ~pb, sw};

	// ============================================================
	// Blinking LED
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
	// LED MSB output
	// ------------------------------------------------------------
	//
	// The BeMicro-SDK LEDs are on for a low-voltage.
	assign led[7] = ~count[WIDTH-1];

	// ============================================================
	// Unused outputs and bidirectional signals
	// ============================================================
	//
	// SPI temperature sensor
	assign spi_sck  = 0;
	assign spi_csN  = 1;
	assign spi_mosi = 'Z;

	// Ethernet PHY
	assign eth_mdc   = 0;
	assign eth_mdio  = 'Z;
	assign eth_rstN  = 0;
	assign eth_tx_en = 0;
	assign eth_txd   = '0;

	// MicroSD card slot
	assign sd_clk = 0;
	assign sd_cmd = 1;
	assign sd_dat = '1;

	// Mobile DDR memory
	assign ddr_ck_p = 0;
	assign ddr_ck_n = 1;
	assign ddr_csN  = 1;
	assign ddr_rasN = 1;
	assign ddr_casN = 1;
	assign ddr_weN  = 1;
	assign ddr_cke  = 0;
	assign ddr_dqm  = '1;
	assign ddr_dqs  = 'Z;
	assign ddr_a    = '0;
	assign ddr_ba   = '0;
	assign ddr_dq   = '0;

	// GPIOs
	assign exp_gpio = 'Z;

endmodule