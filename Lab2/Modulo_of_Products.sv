module Module_of_product (
    input wire clk,               // Clock signal
    input wire rst,               // Reset signal
    input wire start,             // Signal to start computation
    input wire [31:0] Y,          // Input Y (assuming 32-bit)
    input wire [31:0] N,          // Input N (assuming 32-bit)
    output reg [31:0] T,          // Output T (assuming 32-bit)
    output reg done               // Signal indicating computation is complete
);

    // Internal registers
    reg [31:0] current;           // Holds the current value being computed
    reg [8:0] counter;            // Counter for tracking iterations (9 bits to count to 256)
    
    // State machine states
    localparam IDLE = 2'b00;
    localparam COMPUTING = 2'b01;
    localparam FINISHED = 2'b10;
    
    // State registers
    reg [1:0] state;
    reg [1:0] state_nxt;
    
    // Control signals from FSM to datapath
    reg init_computation;
    reg update_current;
    reg update_counter;
    reg set_output;
    
    // FSM: Next state logic
    always @(*) begin
        // Default assignments
        state_nxt = state;
        init_computation = 0;
        update_current = 0;
        update_counter = 0;
        set_output = 0;
        
        case (state)
            IDLE: begin
                if (start) begin
                    state_nxt = COMPUTING;
                    init_computation = 1;
                end
            end
            
            COMPUTING: begin
                update_current = 1;
                update_counter = 1;
                
                if (counter == 255) begin
                    state_nxt = FINISHED;
                end
            end
            
            FINISHED: begin
                set_output = 1;
                state_nxt = IDLE;
            end
            
            default: state_nxt = IDLE;
        endcase
    end
    
    // Datapath: Sequential computation logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all datapath registers
            current <= 0;
            counter <= 0;
            T <= 0;
            done <= 0;
            state <= IDLE;

        end else begin
            // Control signals from FSM determine what operations to perform
            state <= state_nxt;

            if (init_computation) begin
                current <= Y % N;    // Start with Y modulo N
                counter <= 0;
                done <= 0;
            end
            
            if (update_current) begin
                current <= (current + current) % N;  // Double the current value modulo N
            end
            
            if (update_counter) begin
                counter <= counter + 1;
            end
            
            if (set_output) begin
                T <= current;
                done <= 1;
            end else if (state == IDLE && !init_computation) begin
                // Clear done signal when not computing and not just starting
                done <= 0;
            end
        end
    end
endmodule