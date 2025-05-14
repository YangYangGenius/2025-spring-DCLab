module Top (
    input        i_clk,
    input        i_rst_n,
    input        i_start,
	input 	  	 i_cheat,
    output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE = 2'b00;
parameter S_PROC = 2'b01;
parameter S_DONE = 2'b10; // State after 15 numbers are shown

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic [1:0] state_r, state_w;
logic [7:0] random_count_r, random_count_w; // Track the number of random numbers generated
logic [63:0] clk_period_r, clk_period_w; // 64-bit counter to specify how many cycles to generate a new random number
logic [63:0] clk_count_r, clk_count_w; // 64-bit counter to track 10 million cycles

logic is_cheating_r, is_cheating_w; // Flag to indicate if the user is cheating
logic [3:0] cheat_count_r, cheat_count_w; // Track the number of cheat numbers generated

// ===== LFSR (Linear Feedback Shift Register) =====
logic [15:0] lfsr_reg, lfsr_next;  // 16-bit LFSR register

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== LFSR Logic for Random Number Generation =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        lfsr_reg <= 16'habcd;  // Initial value of the LFSR, could be any non-zero value.
    else
        lfsr_reg <= lfsr_next;
end

// LFSR Feedback Logic (simple 16-bit LFSR example)
always_comb begin
    lfsr_next = {lfsr_reg[13:0], lfsr_reg[13] ^ lfsr_reg[12], lfsr_reg[5] ^ lfsr_reg[3]};  // Feedback polynomial: x^16 + x^15 + 1

end

always_comb begin
	if(i_cheat) begin
    	is_cheating_w = 1; // Set the cheating flag
		cheat_count_w = cheat_count_r + 1; // Increment the cheat count
	end
	else begin
		is_cheating_w = is_cheating_r; // Reset the cheating flag
		cheat_count_w = cheat_count_r; // Keep the cheat count the same
	end
end

always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	state_w        = state_r;
	random_count_w = random_count_r;
	clk_period_w   = clk_period_r;
	clk_count_w    = clk_count_r;

	case(state_r)
	S_IDLE: begin
		if (i_start) begin
			state_w = S_PROC;
			random_count_w = 0;   // Reset the random count
			clk_period_w = 3000000; // 3 million cycles to generate a new random number
			clk_count_w = 0;    // Reset the clock cycle counter
		end
	end

	S_PROC: begin
		// Increment the clock cycle counter
		clk_count_w = clk_count_r + 1;

		// When we reach 10 million cycles (clk_count == 10 million), generate a new random number
		if (clk_count_r == clk_period_r) begin
			o_random_out_w = lfsr_reg[3:0];  // Set the random number to LFSR value
			clk_count_w = 0;  // Reset the cycle counter
			clk_period_w = clk_period_r + 1000000; // Double the period for the next random number
			random_count_w = random_count_r + 1; // Increment the random count
			
			
		end
		// After generating 15 random numbers, go to DONE state
		if (random_count_r == 15) begin
			state_w = S_DONE;
		end
	end

	S_DONE: begin
		// After 15 random numbers, stay in the DONE state
		o_random_out_w = (is_cheating_r) ? cheat_count_r : o_random_out_r;  // Can output 0 or hold the last random number
		state_w = S_IDLE;
	end
	endcase
end

// ===== Sequential Logic for FSM and Counter =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
    // reset
    if (!i_rst_n) begin
        o_random_out_r <= 4'd0;
        state_r        <= S_IDLE;
        random_count_r   <= 0;
		clk_period_r     <= 3000000;
        clk_count_r    <= 0;
		is_cheating_r	   <= 0;
		cheat_count_r	   <= 0;
    end
    else begin
        o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		random_count_r <= random_count_w;
		clk_period_r   <= clk_period_w;
		clk_count_r  <= clk_count_w;
		is_cheating_r    <= is_cheating_w;
		cheat_count_r    <= cheat_count_w;
    end
end

endmodule
