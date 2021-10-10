module sync
(
	input in,
	input clk,
	output reg out = 0
);
reg tmp = 0;
always @ (posedge clk) begin
	tmp <= in;
	out <= tmp;
	end
endmodule
