module millisecond (
    input [9:0] a,
    output [6:0] b
);

/*------------------------------------------------- Wires -------------------------------------------------*/
wire [14:0] a_extended;
wire [14:0] sum;

/*--------------------------------------------- Output assignment ---------------------------------------------*/
assign a_extended = {5'b0, a}; // Extend a to 15 bits by adding 5 leading zeros
assign sum = a_extended + (a_extended << 3) + (a_extended << 4); // Multiply by 25
assign b = sum[14:8];

endmodule