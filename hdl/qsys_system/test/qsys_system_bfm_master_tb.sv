// ----------------------------------------------------------------
// qsys_system_bfm_master_tb.v
//
// 10/28/2011 D. W. Hawkins (dwh@caltech.edu)
//
// JTAG-to-Avalon-MM tutorial Qsys System testbench.
//
// The testbench generates Avalon-MM bus transactions using the
// Avalon-MM BFM.
//
// ----------------------------------------------------------------

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

// Console messaging level
`define VERBOSITY VERBOSITY_INFO

// Path to the BFM
`define BFM dut.bfm_master

// BFM related parameters
// (look at the parameters in bfm_master.v)
`define AV_ADDRESS_W 32
`define AV_SYMBOL_W   8
`define AV_NUMSYMBOLS 4

// Derived parameters
`define AV_DATA_W (`AV_SYMBOL_W * `AV_NUMSYMBOLS)

//-----------------------------------------------------------------
// The testbench
//-----------------------------------------------------------------
//
module qsys_system_bfm_master_tb();

	// ------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------
	//
	// Clock period
	localparam time CLK_PERIOD = 20ns;

	// ------------------------------------------------------------
	// Packages
	// ------------------------------------------------------------
	//
	import verbosity_pkg::*;
	import avalon_mm_pkg::*;

	// ------------------------------------------------------------
	// Local variables and signals
	// ------------------------------------------------------------
	//
	// SOPC Signals
	logic        clk;
	logic        reset_n;
	logic [7:0]  led;
	logic [7:0]  button;
	logic        resetrequest;

	// Testbench variables
	integer test_number = 0;
	logic [`AV_DATA_W-1:0] rddata, wrdata;
	integer ram_bytelen;

	// ------------------------------------------------------------
	// Clock generator
	// ------------------------------------------------------------
	//
	initial
		clk = 1'b0;
	always
		#(CLK_PERIOD/2) clk <= ~clk;

	// ------------------------------------------------------------
	// Device under test
	// ------------------------------------------------------------
	//
	qsys_system dut (
		.clk_clk(clk),
		.reset_reset_n(reset_n),
		.led_export(led),
		.button_export(button),
		.resetrequest_reset(resetrequest)
	);

	// ------------------------------------------------------------
	// Test stimulus
	// ------------------------------------------------------------
	initial
	begin
		// --------------------------------------------------------
		// Start message
		// --------------------------------------------------------
		//
		$display("");
		$display("===============================================================");
		$display("JTAG-to-Avalon-MM SOPC System Testbench (using the BFM master)");
		$display("===============================================================");
		$display("");

		// --------------------------------------------------------
		// Signal defaults
		// --------------------------------------------------------
		//
		reset_n = 0;
		button  = 'h55;

		// --------------------------------------------------------
		// Initialize the master BFM
		// --------------------------------------------------------
		//
		set_verbosity(`VERBOSITY);
		`BFM.init();

		// --------------------------------------------------------
		// Deassert reset
		// --------------------------------------------------------
		//
		$display(" * Deassert reset");
		#100ns reset_n = 1;

		// Give the SOPC system reset synchronizers a few clocks
		#(10*CLK_PERIOD);

		// --------------------------------------------------------
		$display("");
		test_number = test_number + 1;
		$display("-----------------------------------------------");
		$display("%1d: Test the LEDs.", test_number);
		$display("-----------------------------------------------");
		// --------------------------------------------------------
		//
		$display(" * Write 0xAA to the LEDs");
		wrdata = 'hAA;
		avalon_write(0, wrdata);
		avalon_read(0,  rddata);
		$display("   - LED register value = %.2Xh", rddata);
		$display("   - LED port value = %.2Xh", led);
		assert (rddata == wrdata) else
			$error("   - read %X, expected %X", rddata, wrdata);

		$display(" * Walking 1's test");
		for (int i = 0; i < 8; i++)
		begin
			wrdata  = 1 << i;
			avalon_write(0, wrdata);
			avalon_read(0,  rddata);
			$display("   - LED port value = %.2Xh", led);
			assert (rddata == wrdata) else
				$error("   - read %X, expected %X", rddata, wrdata);
		end;

		// Delay between tests
		#(10*CLK_PERIOD);

		// --------------------------------------------------------
		$display("");
		test_number = test_number + 1;
		$display("-----------------------------------------------");
		$display("%1d: Test the push buttons.", test_number);
		$display("-----------------------------------------------");
		// --------------------------------------------------------
		//
		avalon_read('h10, rddata);
		$display(" * Push button value = %.2Xh", rddata);

		$display(" * Walking 1's test");
		for (int i = 0; i < 8; i++)
		begin
			wrdata  = 1 << i;
			button  = wrdata;
			avalon_read('h10, rddata);
			$display("   - Push button value = %.2Xh", rddata);
			assert (rddata == wrdata) else
				$error("   - read %X, expected %X", rddata, wrdata);
		end;

		// Delay between tests
		#(10*CLK_PERIOD);

		// --------------------------------------------------------
		$display("");
		test_number = test_number + 1;
		$display("-----------------------------------------------");
		$display("%1d: Test the on-chip RAM.", test_number);
		$display("-----------------------------------------------");
		// --------------------------------------------------------
		//
		ram_bytelen = 'h1000;
		$display(" * Fill %1d locations of RAM with an incrementing count", ram_bytelen/4);
		for (int i = 0; i < ram_bytelen/4; i++)
		begin
			avalon_write('h1000 + 4*i, i);
		end;

		$display(" * Read and check the RAM");
		for (int i = 0; i < ram_bytelen/4; i++)
		begin
			avalon_read('h1000 + 4*i, rddata);
			assert (rddata == i) else
				$error("   - read %X, expected %X", rddata, i);
		end;

		// Delay between tests
		#(10*CLK_PERIOD);

		// --------------------------------------------------------
		$display("");
		$display("===============================================");
		$display("Simulation complete.");
		$display("===============================================");
		$display("");
		// --------------------------------------------------------
		$stop;
	end

	// ============================================================
	// Tasks
	// ============================================================
	//
	// Avalon-MM single-transaction read and write procedures.
	//
	// ------------------------------------------------------------
	task avalon_write (
	// ------------------------------------------------------------
		input [`AV_ADDRESS_W-1:0] addr,
		input [`AV_DATA_W-1:0]    data
	);
	begin
		// Construct the BFM request
		`BFM.set_command_request(REQ_WRITE);
		`BFM.set_command_idle(0, 0);
		`BFM.set_command_init_latency(0);
		`BFM.set_command_address(addr);
		`BFM.set_command_byte_enable('1,0);
		`BFM.set_command_data(data, 0);

		// Queue the command
		`BFM.push_command();

		// Wait until the transaction has completed
		while (`BFM.get_response_queue_size() != 1)
			@(posedge clk);

		// Dequeue the response and discard
		`BFM.pop_response();
	end
	endtask

	// ------------------------------------------------------------
	task avalon_read (
	// ------------------------------------------------------------
		input  [`AV_ADDRESS_W-1:0] addr,
		output [`AV_DATA_W-1:0]    data
	);
	begin
		// Construct the BFM request
		`BFM.set_command_request(REQ_READ);
		`BFM.set_command_idle(0, 0);
		`BFM.set_command_init_latency(0);
		`BFM.set_command_address(addr);
		`BFM.set_command_byte_enable('1,0);
		`BFM.set_command_data(0, 0);

		// Queue the command
		`BFM.push_command();

		// Wait until the transaction has completed
		while (`BFM.get_response_queue_size() != 1)
			@(posedge clk);

		// Dequeue the response and return the data
		`BFM.pop_response();
		data = `BFM.get_response_data(0);
	end
	endtask



endmodule
