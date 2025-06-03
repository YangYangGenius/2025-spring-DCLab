module SevenHexDecoder (
	input        [6:0] i_hex,
	output logic [6:0] o_seven_ten,
	output logic [6:0] o_seven_one
);

/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */
parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;
always @(*) begin
	case(i_hex)
		7'h0: begin o_seven_ten = D0; o_seven_one = D0; end
		7'h1: begin o_seven_ten = D0; o_seven_one = D1; end
		7'h2: begin o_seven_ten = D0; o_seven_one = D2; end
		7'h3: begin o_seven_ten = D0; o_seven_one = D3; end
		7'h4: begin o_seven_ten = D0; o_seven_one = D4; end
		7'h5: begin o_seven_ten = D0; o_seven_one = D5; end
		7'h6: begin o_seven_ten = D0; o_seven_one = D6; end
		7'h7: begin o_seven_ten = D0; o_seven_one = D7; end
		7'h8: begin o_seven_ten = D0; o_seven_one = D8; end
		7'h9: begin o_seven_ten = D0; o_seven_one = D9; end
		7'ha: begin o_seven_ten = D1; o_seven_one = D0; end
		7'hb: begin o_seven_ten = D1; o_seven_one = D1; end
		7'hc: begin o_seven_ten = D1; o_seven_one = D2; end
		7'hd: begin o_seven_ten = D1; o_seven_one = D3; end
		7'he: begin o_seven_ten = D1; o_seven_one = D4; end
		7'hf: begin o_seven_ten = D1; o_seven_one = D5; end
		7'h10: begin o_seven_ten = D1; o_seven_one = D6; end
		7'h11: begin o_seven_ten = D1; o_seven_one = D7; end
		7'h12: begin o_seven_ten = D1; o_seven_one = D8; end
		7'h13: begin o_seven_ten = D1; o_seven_one = D9; end
		7'h14: begin o_seven_ten = D2; o_seven_one = D0; end
		7'h15: begin o_seven_ten = D2; o_seven_one = D1; end
		7'h16: begin o_seven_ten = D2; o_seven_one = D2; end
		7'h17: begin o_seven_ten = D2; o_seven_one = D3; end
		7'h18: begin o_seven_ten = D2; o_seven_one = D4; end
		7'h19: begin o_seven_ten = D2; o_seven_one = D5; end
		7'h1a: begin o_seven_ten = D2; o_seven_one = D6; end
		7'h1b: begin o_seven_ten = D2; o_seven_one = D7; end
		7'h1c: begin o_seven_ten = D2; o_seven_one = D8; end
		7'h1d: begin o_seven_ten = D2; o_seven_one = D9; end
		7'h1e: begin o_seven_ten = D3; o_seven_one = D0; end
		7'h1f: begin o_seven_ten = D3; o_seven_one = D1; end
		7'h20: begin o_seven_ten = D3; o_seven_one = D2; end
		7'h21: begin o_seven_ten = D3; o_seven_one = D3; end
		7'h22: begin o_seven_ten = D3; o_seven_one = D4; end
		7'h23: begin o_seven_ten = D3; o_seven_one = D5; end
		7'h24: begin o_seven_ten = D3; o_seven_one = D6; end
		7'h25: begin o_seven_ten = D3; o_seven_one = D7; end
		7'h26: begin o_seven_ten = D3; o_seven_one = D8; end
		7'h27: begin o_seven_ten = D3; o_seven_one = D9; end
		7'h28: begin o_seven_ten = D4; o_seven_one = D0; end
		7'h29: begin o_seven_ten = D4; o_seven_one = D1; end
		7'h2a: begin o_seven_ten = D4; o_seven_one = D2; end
		7'h2b: begin o_seven_ten = D4; o_seven_one = D3; end
		7'h2c: begin o_seven_ten = D4; o_seven_one = D4; end
		7'h2d: begin o_seven_ten = D4; o_seven_one = D5; end
		7'h2e: begin o_seven_ten = D4; o_seven_one = D6; end
		7'h2f: begin o_seven_ten = D4; o_seven_one = D7; end
		7'h30: begin o_seven_ten = D4; o_seven_one = D8; end
		7'h31: begin o_seven_ten = D4; o_seven_one = D9; end
		7'h32: begin o_seven_ten = D5; o_seven_one = D0; end
		7'h33: begin o_seven_ten = D5; o_seven_one = D1; end
		7'h34: begin o_seven_ten = D5; o_seven_one = D2; end
		7'h35: begin o_seven_ten = D5; o_seven_one = D3; end
		7'h36: begin o_seven_ten = D5; o_seven_one = D4; end
		7'h37: begin o_seven_ten = D5; o_seven_one = D5; end
		7'h38: begin o_seven_ten = D5; o_seven_one = D6; end
		7'h39: begin o_seven_ten = D5; o_seven_one = D7; end
		7'h3a: begin o_seven_ten = D5; o_seven_one = D8; end
		7'h3b: begin o_seven_ten = D5; o_seven_one = D9; end
		7'h3c: begin o_seven_ten = D6; o_seven_one = D0; end
		7'h3d: begin o_seven_ten = D6; o_seven_one = D1; end
		7'h3e: begin o_seven_ten = D6; o_seven_one = D2; end
		7'h3f: begin o_seven_ten = D6; o_seven_one = D3; end
		7'h40: begin o_seven_ten = D6; o_seven_one = D4; end
		7'h41: begin o_seven_ten = D6; o_seven_one = D5; end
		7'h42: begin o_seven_ten = D6; o_seven_one = D6; end
		7'h43: begin o_seven_ten = D6; o_seven_one = D7; end
		7'h44: begin o_seven_ten = D6; o_seven_one = D8; end
		7'h45: begin o_seven_ten = D6; o_seven_one = D9; end
		7'h46: begin o_seven_ten = D7; o_seven_one = D0; end
		7'h47: begin o_seven_ten = D7; o_seven_one = D1; end
		7'h48: begin o_seven_ten = D7; o_seven_one = D2; end
		7'h49: begin o_seven_ten = D7; o_seven_one = D3; end
		7'h4a: begin o_seven_ten = D7; o_seven_one = D4; end
		7'h4b: begin o_seven_ten = D7; o_seven_one = D5; end
		7'h4c: begin o_seven_ten = D7; o_seven_one = D6; end
		7'h4d: begin o_seven_ten = D7; o_seven_one = D7; end
		7'h4e: begin o_seven_ten = D7; o_seven_one = D8; end
		7'h4f: begin o_seven_ten = D7; o_seven_one = D9; end
		7'h50: begin o_seven_ten = D8; o_seven_one = D0; end
		7'h51: begin o_seven_ten = D8; o_seven_one = D1; end
		7'h52: begin o_seven_ten = D8; o_seven_one = D2; end
		7'h53: begin o_seven_ten = D8; o_seven_one = D3; end
		7'h54: begin o_seven_ten = D8; o_seven_one = D4; end
		7'h55: begin o_seven_ten = D8; o_seven_one = D5; end
		7'h56: begin o_seven_ten = D8; o_seven_one = D6; end
		7'h57: begin o_seven_ten = D8; o_seven_one = D7; end
		7'h58: begin o_seven_ten = D8; o_seven_one = D8; end
		7'h59: begin o_seven_ten = D8; o_seven_one = D9; end
		7'h5a: begin o_seven_ten = D9; o_seven_one = D0; end
		7'h5b: begin o_seven_ten = D9; o_seven_one = D1; end
		7'h5c: begin o_seven_ten = D9; o_seven_one = D2; end
		7'h5d: begin o_seven_ten = D9; o_seven_one = D3; end
		7'h5e: begin o_seven_ten = D9; o_seven_one = D4; end
		7'h5f: begin o_seven_ten = D9; o_seven_one = D5; end
		7'h60: begin o_seven_ten = D9; o_seven_one = D6; end
		7'h61: begin o_seven_ten = D9; o_seven_one = D7; end
		7'h62: begin o_seven_ten = D9; o_seven_one = D8; end
		7'h63: begin o_seven_ten = D9; o_seven_one = D9; end //99
		default: begin o_seven_ten = 7'b0000110; o_seven_one = 7'b0000110; end //EE
	endcase
end

endmodule
