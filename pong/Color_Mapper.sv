

// VGA = 640*480

module  color_mapper (  input Clk, hs, reset, frame_clk,
								input [3:0] gameClock [3], // From timer
								input logic [15:0] Row [10],
								input logic rowReady,
								input logic [9:0] DrawX, DrawY,
								output logic [7:0] rowNum,
							   output logic LD_Row,
								output logic [7:0]  Red, Green, Blue );
    
	 
	 parameter squareSize = (left_edge)/(board_width+1); // half of the screen is the board, and divide that by
	 // the # of squares in a row of the board
	 parameter [6:0] board_width =9; // number of squares in each row (starting at 0)
	 parameter [6:0] board_height =19;
	 parameter [9:0] left_edge = 640/3;
	 parameter [9:0] right_edge = (640/3) + (10*squareSize);
	 
	 logic [7:0] currentRow;
	 
	 logic [7:0] load_counter;
	 
	 // Compute time to display
	 logic [10:0] the_matrix[3]; 
	 assign the_matrix[2] = {7'b0, gameClock[2]} + 11'h30;
	 assign the_matrix[1] = {7'b0, gameClock[1]} + 11'h30;
	 assign the_matrix[0] = {7'b0, gameClock[0]} + 11'h30;
	 
	 // For indexing font rom 
	 logic [10:0] sprite_addr;
	 logic [7:0] sprite_data;
	 
	 font_rom font(.addr(sprite_addr), .data(sprite_data));
	 
	 // Logic for some cool points
	 enum logic [15:0] {A, B, C, D, E, F, G, H} cool_points;
	 logic [10:0] pointer;
	 logic [7:0] fade;
	 logic [4:0] counter;
	 
	 always_ff @(posedge frame_clk)
	 begin
		if(reset)
			cool_points <= A;
		else
		begin
			unique case(cool_points)
			A: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= 8'b0;
					pointer <= 11'b0;
					cool_points <= B;
				end
				else
					counter <= counter + 1'b1;
				end
			B: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= C;
				end
				else
					counter <= counter + 1'b1;
				end
			C: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= D;
				end
				else
					counter <= counter + 1'b1;
				end
			D: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= E;
				end
				else
					counter <= counter + 1'b1;
				end
			E:begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= F;
				end
				else
					counter <= counter + 1'b1;
				end
			F: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= G;
				end
				else
					counter <= counter + 1'b1;
				end
			G: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= H;
				end
				else
					counter <= counter + 1'b1;
				end
			H: begin
				if(counter[4])
				begin
					counter <= 5'b0;
					fade <= fade + 8'h04;
					pointer <= pointer + 1'b1;
					cool_points <= A;
				end
				else
					counter <= counter + 1'b1;
				end
			endcase
		end
	 end
       
    always_comb
    begin:RGB_Display
		  sprite_addr = 11'b0; // Default font address
        if ((DrawX >= (left_edge)) && (DrawX < (right_edge) && (DrawY < (squareSize*20))))  // if drawing in board
        begin
				if(((DrawX-(left_edge))%(squareSize) == 0 || (DrawX-(left_edge))%(squareSize) == (squareSize - 1) ||
					DrawY%squareSize == 0 || DrawY%squareSize == (squareSize - 1)) && (Row[(DrawX-(left_edge))/(squareSize)][11:4] != 0))
					begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
					end
				else
					begin
					Red = {Row[(DrawX-(left_edge))/(squareSize)][11:8], 4'b0};
					Green = {Row[(DrawX-(left_edge))/(squareSize)][7:4], 4'b0};
					Blue = {Row[(DrawX-(left_edge))/(squareSize)][3:0], 4'b0};
					end
        end
		  // Code added by ya boi
		  // In Game Score
			else if(DrawX >= (right_edge) && DrawX < ((right_edge)+8*4) && DrawY < 16) // Drawing IBM chars (8x16)
				begin
					if(DrawX < ((right_edge)+8*1))
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(11'h30)); // Code for 0 is x30
					else if(DrawX < ((right_edge)+8*2))
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(11'h31)); // Code for 1 is x31
					else if(DrawX < ((right_edge)+8*3))
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(11'h32)); // Code for 2 is x32
					else
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(11'h33)); // Code for 3 is x33
					
					if(sprite_data[3'd7 - (((DrawX - (right_edge)) % 8))] == 1'b1)
						begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;
						end
					else
						begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
						end
				end
			// In Game Timer
			else if(DrawX >= (left_edge - 8*4) && DrawX < left_edge && DrawY < 16)
				begin
					if(DrawX < ((left_edge) - 8*3))
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(the_matrix[2])); // Code for 0 is x30
					else if(DrawX < ((left_edge)- 8*2))
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(11'h3A)); // Code for :
					else if(DrawX < ((left_edge) - 8*1))
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(the_matrix[1])); // Code for 2 is x32
					else
						sprite_addr = (({1'b0, DrawY} - 11'b0) + 16*(the_matrix[0])); // Code for 3 is x33
					
					if(sprite_data[(((left_edge - DrawX) % 8))] == 1'b1)
						begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;
						end
					else
						begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
						end
				end
		  // Pointer adder +5
		  else if(DrawX >= (right_edge) && DrawX < ((right_edge)+8*3) && DrawY >= (16 + pointer) && DrawY < (16 + pointer + 8'h08))
		  begin
				if(DrawX < ((right_edge)+8*1))
						sprite_addr = (({1'b0, DrawY} - (16 + pointer)) + 16*(11'h2b)); // Code for 0 is x30
				else if(DrawX < ((right_edge)+8*2))
						sprite_addr = (({1'b0, DrawY} - (pointer - 16)) + 16*(11'h31)); // Code for 1 is x31
				else if(DrawX < ((right_edge)+8*3))
						sprite_addr = (({1'b0, DrawY} - (pointer - 16)) + 16*(11'h30)); // Code for 1 is x31
		  
		  		if(sprite_data[3'd7 - (((DrawX - (right_edge)) % 8))] == 1'b1)
						begin
						Red = 8'hff - fade;
						Green = 8'hff - fade;
						Blue = 8'hff - fade;
						end
					else
						begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
						end
		  
		  end
        else 
        begin // draw side bars
            Red = 8'h00; 
            Green = 8'hfc;
            Blue = 8'h39;
        end   
    end 
    
	 
	 enum logic [15:0] {S1, S2, Wait} state;

	// State machine logic with reset for correct default values of regs
	always_ff @(posedge Clk) begin
		if(reset) begin	// Default values
			state <= Wait;
			end
		else begin
			unique case (state)
				Wait: begin
					if (hs == 1'b1 && (((DrawY+1) % squareSize) == 0)) begin // at the end of a block row fetch the next row
						if (load_counter == 20) begin
							state <= S1;
							load_counter <= 0;
						end
						else begin
							load_counter <= load_counter + 1;
						end
					end
					end 
				S1: begin
					if (hs == 1'b0)
						state <= Wait;
					end 
	//			S2: begin
	//				
	//				state <= Wait
	//				end 
				default: ;
			endcase
		end
	end
	
	
	always_comb 
	begin
		if(reset) begin	// Default values
			rowNum = 1'b0;
			LD_Row = 1'b0;
		end
		else begin
			rowNum = 0;
			LD_Row = 1'b0;
			unique case (state)
				Wait: begin
					if (hs == 1'b1 && DrawY >= 479) begin  // if at the end of the last block row
						rowNum = 0;
						LD_Row = 1'b1;
					end
					else if (hs == 1'b1 && (((DrawY+1) % squareSize) == 0)) begin  // else if at the end at a block row
						rowNum = (DrawY+1) / squareSize; // get the next block row
						LD_Row = 1'b1;
					end
				end
				S1: begin  
					LD_Row = 1'b0;
					end 
	//			S2: begin
	//				LD_Row = 1'b0;
	//				end 
				default: ;
			endcase
		end
	end
endmodule

// VGA = 640*480

//module  color_mapper ( input        [9:0] blockx1, blocky1, blockx2, blocky2, blockx3, blocky3, blockx4, blocky4, DrawX, DrawY, Ball_size,
//                       output logic [7:0]  Red, Green, Blue );
//    
//	 
//    logic ball_on;
//	 
//
//	 parameter squareSize = (left_edge)/10; // half of the screen is the board, and divide that by
//	 // the # of squares in a row of the board
//	 logic [9:0] BallX [4]; 
//	 logic [9:0] BallY [4];
//	 
//	 assign BallX[0] = (blockx1 * squareSize) + (left_edge); // start at second third of screen
//	 assign BallY[0] = blocky1 * squareSize;
//	 assign BallX[1] = (blockx2 * squareSize) + (left_edge); // start at second third of screen
//	 assign BallY[1] = blocky2 * squareSize;
//	 assign BallX[2] = (blockx3 * squareSize) + (left_edge); // start at second third of screen
//	 assign BallY[2] = blocky3 * squareSize;
//	 assign BallX[3] = (blockx4 * squareSize) + (left_edge); // start at second third of screen
//	 assign BallY[3] = blocky4 * squareSize;
////	 assign BallX = ballx; // start at second quarter of screen
////	 assign BallY = bally;
//    int DistX1, DistY1, DistX2, DistY2, DistX3, DistY3, DistX4, DistY4;
//	 int Size;
//	 assign DistX1 = DrawX - BallX[0]; 
//    assign DistY1 = DrawY - BallY[0]; 
//	 assign DistX2 = DrawX - BallX[1]; 
//    assign DistY2 = DrawY - BallY[1]; 
//	 assign DistX3 = DrawX - BallX[2]; 
//    assign DistY3 = DrawY - BallY[2]; 
//	 assign DistX4 = DrawX - BallX[3]; 
//    assign DistY4 = DrawY - BallY[3]; 
////    assign Size = Ball_size;
//	assign Size = squareSize/2;
//	  
//    always_comb
//    begin:Ball_on_proc
//        if ( 
//		  (DistX1*DistX1+DistY1*DistY1)<=(Size*Size) || (DistX2*DistX2+DistY2*DistY2)<=(Size*Size) || 
//		  (DistX3*DistX3+DistY3*DistY3)<=(Size*Size) || (DistX4*DistX4+DistY4*DistY4)<=(Size*Size) || 
//		  (DrawX <= (left_edge) - (squareSize/2)) || (DrawX >= (right_edge) + (squareSize/2)) || DrawY >=(squareSize*20)
//		  ) 
//            ball_on = 1'b1;
//        else 
//            ball_on = 1'b0;
//     end 
//       
//    always_comb
//    begin:RGB_Display
//        if ((ball_on == 1'b1)) 
//        begin 
//            Red = 8'hff;
//            Green = 8'h55;
//            Blue = 8'h00;
//        end  
//        else 
//        begin 
//            Red = 8'h00; 
//            Green = 8'h00;
//            Blue = 8'h7f - DrawX[9:3];
//        end   
//
//    end 
//    
//endmodule