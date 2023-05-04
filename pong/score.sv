module score(input clk,
				 input reset,
				 input [4:0] score_to_add [4],
				 output [4:0] digits [4] 
				);
				
logic [4:0] scoreboard [4];
logic [4:0] compute [4];
logic carrybit [3];
assign digits = scoreboard;

always_ff @(posedge clk)
begin
if(reset)
	begin
	scoreboard <= 4'b0;
	end
else
	begin 
	scoreboard <= compute;
	end
end

always_comb
begin
	compute[0] = (scoreboard[0] + score_to_add[0]) % 4'd10;
	compute[1] = (scoreboard[1] + score_to_add[1] + carrybit[0]) % 4'd10;
	compute[2] = (scoreboard[2] + score_to_add[2] + carrybit[1]) % 4'd10;
	compute[3] = (scoreboard[3] + score_to_add[3] + carrybit[2]) % 4'd10;
	
	if(scoreboard[0] + score_to_add[0] > 4'd9)
		carrybit[0] = 1'b1;
	else
		carrybit[0] = 1'b0;
		
	if(scoreboard[1] + score_to_add[1] + carrybit[0] > 4'd9)
		carrybit[1] = 1'b1;
	else
		carrybit[1] = 1'b0;
		
	if(scoreboard[2] + score_to_add[2] + carrybit[1] > 4'd9)
		carrybit[2] = 1'b1;
	else
		carrybit[2] = 1'b0;
	
	if(scoreboard[3] + score_to_add[3] + carrybit[2] > 4'd9)
		carrybit[3] = 1'b1;
	else
		carrybit[3] = 1'b0;
end
				
endmodule
