// ----------------------------------------------------------------
// sopc_system_jtag_master_tb.v
//
// 10/28/2011 D. W. Hawkins (dwh@caltech.edu)
//
// JTAG-to-Avalon-MM tutorial SOPC System testbench.
//
// The testbench generates Avalon-MM bus transactions using the
// undocumented tasks located in the JTAG-to-Avalon-ST component
// used to implement the JTAG-to-Avalon-MM bridge.
//
// ----------------------------------------------------------------

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

// Path to the JTAG Virtual TAP model
//
// * this path was determined from the default simulation model for
//   sopc_system.v, i.e., test_bench, by;
//   - running the setup_sim.do file
//   - using 's' to build and load the simulation.
//   - navigating the test_bench heirarchy until reaching the
//     SLD node (altera_jtag_sld_node) containing the Verilog tasks
//     used in the master_read_32 and write tasks below in the
//     testbench.
//   - you can highlight the path in Modelsim's hierarchy view
//     and then copy-and-paste it into a text file. The path
//     separators can then be changed from slashes to dots.
//
//   eg., test_bench.DUT.the_jtag_master.jtag_master_inst.jtag_phy_embedded_in_jtag_master.normal.jtag_dc_streaming.jtag_streaming.node
//
// * This testbench instantiates the dut directly, so the path is
//   one level shorter, i.e.,
//
// Quartus 11.1sp1
// ---------------
`define VTAP dut.the_jtag_master.jtag_master_inst.jtag_phy_embedded_in_jtag_master.normal.jtag_dc_streaming.jtag_streaming.node

// Quartus 10.0
// ------------
// The component hierarchy is slightly different for Quartus versions
// earlier than 11.1sp1. The sopc_system_jtag_master_tb.do script
// JTAG master nodes also change names.
//`define VTAP dut.the_jtag_master.jtag_master.normal.altera_jtag_avalon_master_pli_off_inst.the_altera_jtag_avalon_master_jtag_interface_pli_off.altera_jtag_avalon_master_jtag_interface_pli_off.normal.jtag_dc_streaming.jtag_streaming.node

//-----------------------------------------------------------------
// The testbench
//-----------------------------------------------------------------
//
module sopc_system_jtag_master_tb();

	// ------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------
	//
	// Clock period
	localparam time CLK_PERIOD = 20ns;

	// ------------------------------------------------------------
	// Local variables and signals
	// ------------------------------------------------------------
	//
	// SOPC Signals
	logic        clk;
	logic        reset_n;
	logic [7:0]  led;
	logic [7:0]  button;

	// Testbench variables
	integer test_number = 0;
	logic [31:0] rddata, wrdata;
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
	sopc_system dut (
		.clk,
		.reset_n,
		.out_port_from_the_led_pio(led),
		.in_port_to_the_button_pio(button)
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
		$display("JTAG-to-Avalon-MM SOPC System Testbench (using the JTAG master)");
		$display("===============================================================");
		$display("");

		// --------------------------------------------------------
		// Signal defaults
		// --------------------------------------------------------
		//
		reset_n = 0;
		button  = 'h55;

		// --------------------------------------------------------
		// JTAG reset
		// --------------------------------------------------------
		//
		$display(" * Reset the JTAG controller");
		`VTAP.reset_jtag_state;

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
		$display("%1d: Test the JTAG protocol special character codes.", test_number);
		$display("-----------------------------------------------");
		// --------------------------------------------------------
		//
		// Check the codes can be sent as data. This checks that the
		// escaping and parsing code correctly handles the special
		// character codes.
		//
		// Use the first location in RAM for the test
		wrdata = 'h4a4d;
		$display(" * Check the JTAG-to-Avalon-ST special codes encode/decode as data: %.4Xh", wrdata);
		master_write_32('h1000, wrdata);
		master_read_32('h1000, rddata);
		assert (rddata == wrdata) else
			$error("   - read %X, expected %X", rddata, wrdata);

		wrdata = 'h7a7b7c7d;
		$display(" * Check the bytes-to-packets special codes encode/decode as data: %.4Xh", wrdata);
		master_write_32('h1000, wrdata);
		master_read_32('h1000, rddata);
		assert (rddata == wrdata) else
			$error("   - read %X, expected %X", rddata, wrdata);

		// Delay between tests
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
		master_write_32(0, wrdata);
		master_read_32(0,  rddata);
		$display("   - LED register value = %.2Xh", rddata);
		$display("   - LED port value = %.2Xh", led);
		assert (rddata == wrdata) else
			$error("   - read %X, expected %X", rddata, wrdata);

		$display(" * Walking 1's test");
		for (int i = 0; i < 8; i++)
		begin
			wrdata  = 1 << i;
			master_write_32(0, wrdata);
			master_read_32(0,  rddata);
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
		master_read_32('h10, rddata);
		$display(" * Push button value = %.2Xh", rddata);

		$display(" * Walking 1's test");
		for (int i = 0; i < 8; i++)
		begin
			wrdata  = 1 << i;
			button  = wrdata;
			master_read_32('h10, rddata);
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
		// The JTAG-to-Avalon-MM bridge transactions are slow, so
		// reduce the number of RAM locations tested to speed
		// up the simulation.
		//
//		ram_bytelen = 'h1000;
		ram_bytelen = 'h80;
		$display(" * Fill %1d locations of RAM with an incrementing count", ram_bytelen/4);
		for (int i = 0; i < ram_bytelen/4; i++)
		begin
			master_write_32('h1000 + 4*i, i);
		end;

		$display(" * Read and check the RAM");
		for (int i = 0; i < ram_bytelen/4; i++)
		begin
			master_read_32('h1000 + 4*i, rddata);
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
	// Avalon-MM read and write procedures.
	//
	// ------------------------------------------------------------
	task master_write_32 (
	// ------------------------------------------------------------
		input [31:0] addr,
		input [31:0] data
	);
		// Local variables
		logic [7:0] txbytes[12];
		logic [7:0] pkbytes[256];
		logic [7:0] wrbytes[256];
		logic [7:0] rdbytes[256];
		int pkindex;
		int wrindex;
		int rdindex;
		int byteindex;

	begin
		// Put the JTAG-to-Avalon-ST bridge in data mode
		@(posedge `VTAP.tck);
		`VTAP.enter_data_mode;

		// Virtual JTAG capture-DR state
		`VTAP.enter_cdr_state;

		// Avalon-MM transaction bytes format
		//
		//  Byte   Value  Description
		// ------  -----  -----------
		//    [0]  0x00   Transaction code = write, no increment
		//    [1]  0x00   Reserved
		//  [3:2]  0x0004 16-bit size (big-endian byte order)
		//  [7:4]  32-bit address (big-endian byte order)
		// [11:8]  32-bit data (little-endian byte order)
		//
		txbytes[0]  = 0;           // Write, no increment
		txbytes[1]  = 0;           // Reserved
		txbytes[2]  = 0;           // 16-bit size (big-endian)
		txbytes[3]  = 4;
		txbytes[4]  = addr[31:24]; // Address (big-endian)
		txbytes[5]  = addr[23:16];
		txbytes[6]  = addr[15: 8];
		txbytes[7]  = addr[ 7: 0];
		txbytes[8]  = data[ 7: 0]; // Data (little-endian)
		txbytes[9]  = data[15: 8];
		txbytes[10] = data[23:16];
		txbytes[11] = data[31:24];

		// Encode the transaction to packet bytes format
		//
		// Byte    Value  Description
		// -----   -----  ----------
		//  [0]    0x00   Channel number
		//  [1]    0x7A   Start-of-packet
		//  [X:2]         Transaction bytes with escape codes
		//         0x7B   End-of-packet
		//  [Y]           Last transaction byte (or escape code plus byte)
		//
		pkbytes[0]  = 'h7C;  // Channel
		pkbytes[1]  = 'h00;
		pkbytes[2]  = 'h7A;  // SOP

		// Insert the transaction bytes, escaping as needed
		pkindex = 3;
		for (int i = 0; i < 12; i++)
		begin
			// Insert the end-of-packet (before the last data/escaped data)
			if (i == 11)
			begin
				pkbytes[pkindex++] = 'h7B;
			end

			// Escape code required?
			if ((txbytes[i] >= 'h7A) && (txbytes[i] <= 'h7D))
			begin
				// Insert the escape code and modified byte
				pkbytes[pkindex++] = 'h7D;
				pkbytes[pkindex++] = txbytes[i] ^ 'h20;
			end
			else
			begin
				pkbytes[pkindex++] = txbytes[i];
			end
		end

		// Encode the packet bytes in JTAG-to-Avalon-ST format
		//
		// Byte    Value  Description
		// -----   -----  ----------
		//  [1:0]  0xFC00 JTAG-to-Avalon-ST packet header (256-bytes)
		// [X-1:2]        Transaction bytes with escape codes
		// [255:X]        JTAG-to-Avalon-ST IDLE codes
		//
		wrbytes[0]  = 'h00;  // FC00h header
		wrbytes[1]  = 'hFC;

		// Insert the transaction bytes, escaping as needed
		wrindex = 2;
		for (int i = 0; i < pkindex; i++)
		begin
			// Escape code required?
			if ((pkbytes[i] == 'h4A) || (pkbytes[i] == 'h4D))
			begin
				// Insert the escape code and modified byte
				wrbytes[wrindex++] = 'h4D;
				wrbytes[wrindex++] = pkbytes[i] ^ 'h20;
			end
			else
			begin
				wrbytes[wrindex++] = pkbytes[i];
			end
		end

		// Fill the remainder of the transaction with JTAG IDLE codes
		for (int i = wrindex; i < 256; i++)
			wrbytes[i] = 'h4A;

		// Send the bytes
		for (int i = 0; i < 256; i++)
		begin
			`VTAP.shift_one_byte(wrbytes[i],  rdbytes[i]);
		end

		// Parse and check the response data
		//
		// Bytes  Value  Description
		// -----  -----  -----------
		//  [0]    0x7C  Channel
		//  [1]    0x00  Channel number
		//  [2]    0x7A  Start-of-packet
		//  [3]    0x80  Transaction code with MSB set
		//  [4]    0x00  Reserved
		//  [5]    0x00  Size[15:8]
		//  [6]    0x7B  End-of-packet
		//  [7]    0x04  Size[7:0]
		//
		// Since the response data does not contain encoded
		// characters for this write command, they are not
		// checked (see the master_read_32 task for how its done).
		//
		// Find the channel code
		rdindex = 0;
		while ((rdindex < 256) && (rdbytes[rdindex++] != 'h7C));
		assert (rdindex < 256) else $error("Channel code not detected!");

		// Check all the response bytes
		assert (rdbytes[rdindex++] == 0)    else $error("Channel number error!");
		assert (rdbytes[rdindex++] == 'h7A) else $error("Start-of-packet code error!");
		assert (rdbytes[rdindex++] == 'h80) else $error("Transaction code error!");
		assert (rdbytes[rdindex++] == 'h00) else $error("Reserved code error!");
		assert (rdbytes[rdindex++] == 'h00) else $error("Size MSBs error!");
		assert (rdbytes[rdindex++] == 'h7B) else $error("End-of-packet code error!");
		assert (rdbytes[rdindex++] == 'h04) else $error("Size LSBs error!");

		// Virtual JTAG Exit1-DR and then Update-DR state
		`VTAP.enter_e1dr_state;
		`VTAP.enter_udr_state;
	end
	endtask

	// ------------------------------------------------------------
	task master_read_32 (
	// ------------------------------------------------------------
		input  [31:0] addr,
		output [31:0] data
	);
		// Local variables
		logic [7:0] txbytes[8];
		logic [7:0] pkbytes[256];
		logic [7:0] wrbytes[256];
		logic [7:0] rdbytes[256];
		int pkindex;
		int wrindex;
		int rdindex;
		int byteindex;

	begin

		// Put the JTAG-to-Avalon-ST bridge in data mode
		@(posedge `VTAP.tck);
		`VTAP.enter_data_mode;

		// Virtual JTAG capture-DR state
		`VTAP.enter_cdr_state;

		// Avalon-MM transaction bytes format
		//
		//  Byte   Value  Description
		// ------  -----  -----------
		//    [0]  0x10   Transaction code = read, no increment
		//    [1]  0x00   Reserved
		//  [3:2]  0x0004 16-bit size (big-endian byte order)
		//  [7:4]  32-bit address (big-endian byte order)
		//
		txbytes[0]  = 'h10;        // Read, no increment
		txbytes[1]  = 0;           // Reserved
		txbytes[2]  = 0;           // 16-bit size (big-endian)
		txbytes[3]  = 4;
		txbytes[4]  = addr[31:24]; // Address (big-endian)
		txbytes[5]  = addr[23:16];
		txbytes[6]  = addr[15: 8];
		txbytes[7]  = addr[ 7: 0];

		// Encode the transaction to packet bytes format
		//
		// Byte    Value  Description
		// -----   -----  ----------
		//  [0]    0x00   Channel number
		//  [1]    0x7A   Start-of-packet
		//  [X:2]         Transaction bytes with escape codes
		//         0x7B   End-of-packet
		//  [Y]           Last transaction byte (or escape code plus byte)
		//
		pkbytes[0]  = 'h7C;  // Channel
		pkbytes[1]  = 'h00;
		pkbytes[2]  = 'h7A;  // SOP

		// Insert the transaction bytes, escaping as needed
		pkindex = 3;
		for (int i = 0; i < 8; i++)
		begin
			// Insert the end-of-packet (before the last data/escaped data)
			if (i == 7)
			begin
				pkbytes[pkindex++] = 'h7B;
			end

			// Escape code required?
			if ((txbytes[i] >= 'h7A) && (txbytes[i] <= 'h7D))
			begin
				// Insert the escape code and modified byte
				pkbytes[pkindex++] = 'h7D;
				pkbytes[pkindex++] = txbytes[i] ^ 'h20;
			end
			else
			begin
				pkbytes[pkindex++] = txbytes[i];
			end
		end

		// Encode the packet bytes in JTAG-to-Avalon-ST format
		//
		// Byte    Value  Description
		// -----   -----  ----------
		//  [1:0]  0xFC00 JTAG-to-Avalon-ST packet header (256-bytes)
		// [X-1:2]        Transaction bytes with escape codes
		// [255:X]        JTAG-to-Avalon-ST IDLE codes
		//
		wrbytes[0]  = 'h00;  // FC00h header
		wrbytes[1]  = 'hFC;

		// Insert the transaction bytes, escaping as needed
		wrindex = 2;
		for (int i = 0; i < pkindex; i++)
		begin
			// Escape code required?
			if ((pkbytes[i] == 'h4A) || (pkbytes[i] == 'h4D))
			begin
				// Insert the escape code and modified byte
				wrbytes[wrindex++] = 'h4D;
				wrbytes[wrindex++] = pkbytes[i] ^ 'h20;
			end
			else
			begin
				wrbytes[wrindex++] = pkbytes[i];
			end
		end

		// Fill the remainder of the transaction with JTAG IDLE codes
		for (int i = wrindex; i < 256; i++)
			wrbytes[i] = 'h4A;

		// Send the byte stream
		for (int i = 0; i < 256; i++)
		begin
			`VTAP.shift_one_byte(wrbytes[i],  rdbytes[i]);
		end

		// Virtual JTAG Exit1-DR and then Update-DR state
		`VTAP.enter_e1dr_state;
		`VTAP.enter_udr_state;

		// Parse and extract the read data
		//
		// The read byte stream consists of;
		// * the 16-bit read data header (the LSB indicates
		//   whether read-data is available, which it will not
		//   be, so the first two bytes are zeros
		//
		// * JTAG-to-Avalon-ST IDLE codes (4Ah)

		// * the JTAG-to-Avalon-ST encoded bytes-to-packets
		//   response data, i.e., nominally
		//
		// Bytes  Value  Description
		// -----  -----  -----------
		//  [0]    0x7C  Channel
		//  [1]    0x00  Channel number
		//  [2]    0x7A  Start-of-packet
		//  [3]          Read-data[7:0]
		//  [4]          Read-data[15:8]
		//  [5]          Read-data[23:16]
		//  [6]    0x7B  End-of-packet
		//  [7]          Read-data[31:24]
		//
		// But if any of the data bytes use a special code used in either
		// the JTAG-to-Avalon-ST or by the bytes-to-packet protocol, then they
		// are escaped and the byte-stream contains the ESCAPE code followed
		// by the character XORed with the escape mask.
		//
		// Find the channel code
		rdindex = 0;
		while ((rdindex < 256) && (rdbytes[rdindex++] != 'h7C));
		assert (rdindex < 256) else $error("Channel code not detected!");

		// Check the first couple of bytes are correct
		assert (rdbytes[rdindex++] == 0)    else $error("Channel number error!");
		assert (rdbytes[rdindex++] == 'h7A) else $error("Start-of-packet code error!");

		// Parse the data bytes
		byteindex = 0;
		data = 0;
		while (byteindex < 4)
		begin

			// JTAG protocol escape code?
			if (rdbytes[rdindex] == 'h4D)
			begin
				rdindex++;
				data = data | ((rdbytes[rdindex++] ^ 'h20) << 8*byteindex);
			end

			// Packet protocol escape code?
			else if (rdbytes[rdindex] == 'h7D)
			begin
				rdindex++;
				data = data | ((rdbytes[rdindex++] ^ 'h20) << 8*byteindex);
			end

			// Just data
			else
			begin
				data = data | (rdbytes[rdindex++] << 8*byteindex);
			end
			byteindex++;

			// Check the end-of-packet
			if (byteindex == 3)
			begin
				assert (rdbytes[rdindex++] == 'h7B) else $error("End-of-packet code error!");
			end
		end
	end
	endtask

endmodule
