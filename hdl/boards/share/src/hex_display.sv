// ----------------------------------------------------------------
// hex_display.sv
//
// 10/10/2011 D. W. Hawkins (dwh@caltech.edu)
//
// Hexidecimal (7-segment) display decoder.
//
// The bit assignments for the hexadecimal display are as per
// the Altera DE2 board documentation:
//
//       0
//     -----
//    |     |
//  5 |     | 1
//    |  6  |
//     -----
//    |     |
//  4 |     | 2
//    |     |
//     -----
//       3
//
// The segments are active low, i.e., each numbered segment is
// illuminated when the bit in the display signal is low.
//
// ----------------------------------------------------------------

module hex_display (
        input  logic [3:0] hex,
        output logic [6:0] display
    );

	always_comb
        case (hex)
            4'h0:    display = 7'b1000000;
            4'h1:    display = 7'b1111001;
            4'h2:    display = 7'b0100100;
            4'h3:    display = 7'b0110000;
            4'h4:    display = 7'b0011001;
            4'h5:    display = 7'b0010010;
            4'h6:    display = 7'b0000010;
            4'h7:    display = 7'b1111000;
            4'h8:    display = 7'b0000000;
            4'h9:    display = 7'b0011000;
            4'hA:    display = 7'b0001000;
            4'hB:    display = 7'b0000011;
            4'hC:    display = 7'b1000110;
            4'hD:    display = 7'b0100001;
            4'hE:    display = 7'b0000110;
            default: display = 7'b0001110;
        endcase
endmodule
