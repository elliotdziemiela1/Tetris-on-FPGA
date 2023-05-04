module timer(input clk, // Assuming frame clk
				 input reset,
				 output [3:0] time_left [3] // Display in format X:XX, need to convert to font rom to display
				 );
logic [3:0] timer [3];
logic [7:0] frame_counter;

assign time_left = timer;

always_ff @(posedge clk)
begin
if(reset) // Initialize to 2:00
	begin
	timer[2] <= 4'd2;
	timer[1] <= 4'd0;
	timer[0] <= 4'd0;
	end
else
	if(frame_counter == 8'd60) // Counter 60 frames per second
		begin
		frame_counter <= 8'b0;
		if(timer[2] != 4'b0 && timer[1] == 0 && timer[0] == 0)
			begin
			timer[2] <= timer[2] - 1; // Ex 2:00 -> 1:59
			timer[1] <= 4'd5;
			timer[0] <= 4'd9;
			end
		else if(timer[2] == 4'b0 && timer[1] == 0 && timer[0] == 0)
				begin
				timer[2] <= 4'b0; // Lock timer at 0
				timer[1] <= 4'b0;
				timer[0] <= 4'b0;
				end
				
		else if(timer[0] == 0) 
			begin
			timer[1] <= timer[1] - 1; //  Ex 1:40 -> 1:39
			timer[0] <= 4'd9;
			end
		else
			timer[0] <= timer[0] - 1; // Ex 0:46 -> 0:45
		end
	else
		frame_counter <= frame_counter + 1'b1;
end				 				 
				 
				 
endmodule
