// ----------------------------------------------------------------
// bemicro.sv
//
// 5/21/2011 D. W. Hawkins (dwh@caltech.edu)
//
// SOPC System Example.
//
// The LED MSB is connected to a blinking counter to show
// the design is loaded and running.
//
// ----------------------------------------------------------------
//
module bemicro
	(
		// --------------------------------------------------------
		// Clock
		// --------------------------------------------------------
		//
		// 16MHz oscillator
		input  logic        clk_16MHz,

		// --------------------------------------------------------
		// LEDs
		// --------------------------------------------------------
		//
		output logic  [7:0] led,

		// --------------------------------------------------------
		// SRAM
		// --------------------------------------------------------
		//
		output logic        sram_csN,
		output logic        sram_cs,
		output logic        sram_oeN,
		output logic        sram_weN,
		output logic  [1:0] sram_beN,
		output logic [17:0] sram_addr,
		inout  logic [15:0] sram_dq,

		// --------------------------------------------------------
		// USB Serial
		// --------------------------------------------------------
		//
		input  logic        rxd,
		output logic        txd,

		// --------------------------------------------------------
		// 80-pin edge connector
		// --------------------------------------------------------
		//
		// Reset input
		input  logic        ext_rstN,

		// Expansion board present (when high)
		input  logic        exp,

		// GPIO
		inout  logic [63:0] gpio
	);

	// ============================================================
	// Local parameters
	// ============================================================
	//
	// Clock frequency
	localparam real CLK_FREQ     = 16.0e6;

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
	logic [WIDTH-1:0] count;

	// ------------------------------------------------------------
	// Clock and reset
	// ------------------------------------------------------------
	//
	// 16MHz system clock
	assign clk = clk_16MHz;

	// External reset
	// * the SOPC system contains a reset synchronizer
	assign rstN = ext_rstN;

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

    // Connect to the LEDs
    // * a low on the pin turns the LED on, so invert the
    //   control register value
	assign led[6:0] = ~led_pio[6:0];

	// There are no buttons, so connect to the GPIO
	assign button_pio = gpio[7:0];

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
	// The BeMicro LEDs are on for a low-voltage.
	assign led[7] = ~count[WIDTH-1];

	// ============================================================
	// USB Serial loop-back
	// ============================================================
	//
	assign txd = rxd;

	// ============================================================
	// Unused outputs and bidirectional signals
	// ============================================================
	//
	// Deassert SRAM controls
	assign sram_csN  = 1;
	assign sram_cs   = 0;
	assign sram_oeN  = 1;
	assign sram_weN  = 1;
	assign sram_beN  = '1;
	assign sram_addr = '0;
	assign sram_dq   = 'Z;

	// Tri-state GPIO
	assign gpio = 'Z;

endmodule