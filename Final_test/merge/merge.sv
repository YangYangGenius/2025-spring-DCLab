module Merge(
    input i_clk,
    input i_rst_n,
    input i_mode,
    input  [15:0] i_data,
    output [15:0] o_data
);

logic [15:0] data_r, data_w;

assign o_data = data_r;

always_comb begin
    data_w = data_r;
    if (i_data != 16'b0) begin
        data_w = i_data + data_r;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        data_r <= 16'b0;
    end else begin
        data_r <= data_w;
    end
end

endmodule