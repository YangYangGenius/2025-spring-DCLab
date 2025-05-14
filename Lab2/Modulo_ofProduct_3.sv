module Module_of_product (
    input wire clk,               // Clock signal
    input wire rst,               // Reset signal
    input wire start,             // Signal to start computation
    input wire [256:0] Y,          // Input Y (assuming 32-bit)
    input wire [256:0] N,          // Input N (assuming 32-bit)
    output wire [256:0] o_result,          // Output T (assuming 32-bit)
    output reg done               // Signal indicating computation is complete
);

    // Internal registers and their next state values
    reg [256:0] current;           // Current value for computation
    reg [256:0] current_nxt;       // Next value for current
    
    reg [8:0] counter;            // Iteration counter
    reg [8:0] counter_nxt;        // Next value for counter
    
    reg done_nxt;                 // Next value for done signal
    
    // State machine states
    localparam IDLE = 2'b00;
    localparam COMPUTING = 2'b01;
    localparam FINISHED = 2'b10;
    
    // State registers and next state value
    reg [1:0] state;
    reg [1:0] next_state;
    
    // Control signals and their next values
    reg init_computation;         // Control signal for initialization
    reg init_computation_nxt;     // Next value for initialization control
    
    reg update_current;           
    reg update_current_nxt;       
    
    assign o_result = current;

    // PART 1: Combinational logic for FSM next state and control signals
    always @(*) begin
        // Default assignments for next state and next control signals
        next_state = state;
        init_computation_nxt = 0;
        update_current_nxt = 0;
        done_nxt = 0;

        
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = COMPUTING;
                    init_computation_nxt = 1;
                end
            end
            
            COMPUTING: begin
                update_current_nxt = 1;
                
                if (counter == 255) begin
                    next_state = FINISHED;
                    done_nxt = 1;
                end
            end
            
            FINISHED: begin
                next_state = IDLE;
                done_nxt = 0;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // PART 2: Combinational logic for datapath computations
    always @(*) begin
        // Default assignments - maintain current values
        current_nxt = current;
        counter_nxt = counter;
        
        // Compute next values based on control signals
        if (init_computation) begin
            //current_nxt = Y % N;    // Start with Y modulo N
            current_nxt = Y;
            counter_nxt = 0;
        end
        
        if (update_current) begin
            if(current + current > N) begin
                current_nxt = (current + current) - N;  // Double the current value modulo N
            end
            else begin
                current_nxt = current + current;  // Double the current value
            end
            counter_nxt = counter + 1;
        end
    end
    
    // PART 3: Sequential logic for all registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers
            state <= IDLE;
            init_computation <= 0;
            update_current <= 0;
            current <= 0;
            counter <= 0;
            done <= 0;
        end else begin
            // Update all registers with their next values
            state <= next_state;
            
            // Update control signals
            init_computation <= init_computation_nxt;
            update_current <= update_current_nxt;
            
            // Update datapath registers
            current <= current_nxt;
            counter <= counter_nxt;
            done <= done_nxt;
        end
    end
    
endmodule