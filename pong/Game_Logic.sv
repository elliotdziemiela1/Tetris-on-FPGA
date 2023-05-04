// will output the moving block's X and Y position

module Game_Logic (
		input Reset, frame_clk, Clk,
		input [7:0] keycode,
		output logic [6:0] blockXPos [4], 
		output logic [6:0] blockYPos [4],
		output logic [6:0] blockXPrev [4], 
		output logic [6:0] blockYPrev [4],
		output logic [15:0] blockColor,
		output logic Clear_row,
		output logic [3:0] Num_rows_to_clear,
		output logic [6:0] Row_to_clear

	);
	
	parameter [6:0] board_width =9; // number of squares in each row (starting at 0)
	parameter [6:0] board_height =19; // number of rows (starting at 0)
	parameter [7:0] frames_per_move_X = 5;
//	parameter [7:0] frames_per_move_Y = 13;
	parameter [4:0] number_of_colors = 3; // 1 indexed
	parameter [49:0] keystroke_sample_period = 50'h10000;
	parameter [4:0] number_of_pieces = 5'd4; // 1 indexed
	
	parameter [7:0] default_frames_per_move_Y = 13;
	logic [7:0] frames_per_move_Y;
	
	logic frame_clk_flag;
	
	logic [49:0] keystroke_counter; // counter to wait after sampling a keystroke to sample the next
	
	logic [6:0] row_to_clear;
	logic [3:0] num_rows_to_clear;
	logic clear_row;
	
	logic [9:0] Board[board_height+1]; // each bit represents the presence of a block in that square of the screen
	logic [6:0] blockX1, blockX2, blockX3, blockX4; // zero indexed
	logic [6:0] blockY1, blockY2, blockY3, blockY4; // zero indexed
	
	logic [6:0] blockXPrevious [4];
	logic [6:0] blockYPrevious [4];
	
	logic [6:0] blockXMotion;
	logic [7:0] blockYMotion;
	logic [4:0] color;
	
	logic [15:0] palette [number_of_colors];
	assign palette = '{16'h0f00, 16'h05f0, 16'h00a8};
	
	logic [5:0] Pieces[number_of_pieces][2][4]; // each peice's block positions for two rotations
	assign Pieces = '{ // Format is for the last block to have the largest Y value to compare for clearing rows
		'{'{6'b000000,6'b001000,6'b001001,6'b010001},'{6'b001000,6'b001001,6'b000001,6'b000010}}, // piece 1
		'{'{6'b000000,6'b000001,6'b000010,6'b000011},'{6'b000000,6'b000001,6'b000010,6'b000011}}, // piece 2
		'{'{6'b000000,6'b000001,6'b001000,6'b001001},'{6'b000000,6'b000001,6'b001000,6'b001001}}, // piece 3
		'{'{6'b000000,6'b000001,6'b001001,6'b010001},'{6'b000000,6'b000001,6'b001001,6'b010001}}  // piece 4
	}; // array of 3 different peices. each register in the array contains the coordinates
	// for a block of the peice in the format [5:3]=Y [2:0]=X, relative to (0,0)
	logic [2:0] piece_count;
	logic piece_rotation;
	
	logic move_clk_X, move_clk_Y;
	logic [5:0] frame_count_move_X, frame_count_move_Y;
	
	
	
		always_ff @ (posedge Clk )
		 begin: Input_Block
			blockXMotion <= 0;
			blockYMotion <= 1;
			frames_per_move_Y <= default_frames_per_move_Y;
			case (keycode)
				8'h04 : begin
						  blockXMotion <= -1;//A
//							if ((blockX1>0)&&(blockX2>0)&&(blockX3>0)&&(blockX4>0))
//								blockXMotion <= -1;//A
						  end
						  
				8'h07 : begin
						  blockXMotion <= 1;//D
//						  if ((blockX1<board_width)&&
//							  (blockX2<board_width)&&
//							  (blockX3<board_width)&&
//							  (blockX4<board_width))
//								blockXMotion <= 1;//D
						  end

						  
				8'h16 : begin
							if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height)) begin
//								blockYMotion <= 2;//S
								frames_per_move_Y <= default_frames_per_move_Y / 2;
							end
						 end
//				8'hd44 : begin // space
//							if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
//								blockYMotion <= 2;//S
//						 end
						  
	//					8'h1A : begin //W
				default: ;
			endcase
			
			if (Reset) begin
					frame_count_move_X <= 0;
					frame_count_move_Y <= 0;
					blockXPrevious[0] <= 7'b0;
					blockXPrevious[1] <= 7'b0;
					blockXPrevious[2] <= 7'b0;
					blockXPrevious[3] <= 7'b0;
				
					blockX1 <= Pieces[0][0][0][2:0] + (board_width>>1); // divided by 2
					blockX2 <= Pieces[0][0][1][2:0] + (board_width>>1);
					blockX3 <= Pieces[0][0][2][2:0] + (board_width>>1);
					blockX4 <= Pieces[0][0][3][2:0] + (board_width>>1);
					
					blockY1 <= Pieces[0][0][0][5:3];
					blockY2 <= Pieces[0][0][1][5:3];
					blockY3 <= Pieces[0][0][2][5:3];
					blockY4 <= Pieces[0][0][3][5:3];
					
					blockYPrevious[0] <= 7'b0;
					blockYPrevious[1] <= 7'b0;
					blockYPrevious[2] <= 7'b0;
					blockYPrevious[3] <= 7'b0;
					
					piece_count <= 1;
					piece_rotation <= 0;
					color <= 0;
					Board <= '{default: 16'h0};
					
					frame_clk_flag <= 1'b0;
					
		  end
			
			
			
			if (frame_clk == 1'b0) begin
				frame_clk_flag <= 1'b0;
				clear_row <= 1'b0;
			end
// THIS HAPPENS ON FRAME CLOCK
			if (frame_clk == 1'b1 && frame_clk_flag == 1'b0) begin
					frame_clk_flag <= 1'b1;
					// 
					// clear row logic
					//
					
		//			if ((Board[blockYPrevious[3]]==10'b1111111111) && (blockYPrevious[3] >= 1)) begin // determines if there's a row to clear, then
		//			// looks at rows above it to see how many to clear (num_rows_to_clear referes to rows above the row_to_clear)
		//				clear_row <= 1'b1;
		//				row_to_clear <= blockYPrevious[3];
		//				num_rows_to_clear <= 1;
		//				Board[blockYPrevious[3]] <= Board[blockYPrevious[3]-1];
		//				Board[blockYPrevious[3]-1] <= 10'b0;
		//				if (Board[blockYPrevious[3]-1]==10'b1111111111) begin
		//					num_rows_to_clear <= 2;
		//					if (blockYPrevious[3] >= 2 && Board[blockYPrevious[3]-2]==10'b1111111111) begin
		//						num_rows_to_clear <= 3;
		//						if (blockYPrevious[3] >= 3 && Board[blockYPrevious[3]-3]==10'b1111111111) begin
		//							num_rows_to_clear <= 4;
		//						end
		//					end
		//				end
		//			end
		//			else if () begin
		//
		//			end
				 
				 
					 //
					 // move_clk_X logic
					 //
					 if (frame_count_move_X >= frames_per_move_X) begin: MoveX_Block
						frame_count_move_X <= 0;
						
						blockXPrevious[0] <= blockX1;
						blockXPrevious[1] <= blockX2;
						blockXPrevious[2] <= blockX3;
						blockXPrevious[3] <= blockX4;
						
						if (((blockX1+blockXMotion)<board_width+1)&&((blockX1+blockXMotion)>=0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)&&
							  ((blockX2+blockXMotion)<board_width+1)&&((blockX2+blockXMotion)>=0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)&&
							  ((blockX3+blockXMotion)<board_width+1)&&((blockX3+blockXMotion)>=0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)&&
							  ((blockX4+blockXMotion)<board_width+1)&&((blockX4+blockXMotion)>=0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)) begin
							blockX1 <= blockX1 + blockXMotion;
							blockX2 <= blockX2 + blockXMotion;
							blockX3 <= blockX3 + blockXMotion;
							blockX4 <= blockX4 + blockXMotion;
						end
					 end
					 else
						frame_count_move_X <= frame_count_move_X + 1;
						
					 //
					 // move_clk_Y logic
					 //
					 if (frame_count_move_Y >= frames_per_move_Y) begin: MoveY_Block
						frame_count_move_Y <= 0;
						
						
						if (
						Board[blockY1+blockYMotion][blockX1]==1'b1 || (blockY1+blockYMotion>board_height) ||
						Board[blockY2+blockYMotion][blockX2]==1'b1 || (blockY2+blockYMotion>board_height) ||
						Board[blockY3+blockYMotion][blockX3]==1'b1 || (blockY3+blockYMotion>board_height) ||
						Board[blockY4+blockYMotion][blockX4]==1'b1 || (blockY4+blockYMotion>board_height)
						) begin // collision with other block or bottom of screen
							// new block generated
							blockYPrevious[0] <= 7'b0;
							blockYPrevious[1] <= 7'b0;
							blockYPrevious[2] <= 7'b0;
							blockYPrevious[3] <= 7'b0;
							
							Board[blockY1][blockX1] <= 1'b1;
							Board[blockY2][blockX2] <= 1'b1;
							Board[blockY3][blockX3] <= 1'b1;
							Board[blockY4][blockX4] <= 1'b1;
							blockY1 <= Pieces[piece_count][0][0][5:3];
							blockY2 <= Pieces[piece_count][0][1][5:3];
							blockY3 <= Pieces[piece_count][0][2][5:3];
							blockY4 <= Pieces[piece_count][0][3][5:3];
							blockX1 <= Pieces[piece_count][0][0][2:0] + (board_width>>1); // divided by 2
							blockX2 <= Pieces[piece_count][0][1][2:0] + (board_width>>1);
							blockX3 <= Pieces[piece_count][0][2][2:0] + (board_width>>1);
							blockX4 <= Pieces[piece_count][0][3][2:0] + (board_width>>1);
							
							// Testing
							clear_row <= 1'b1;
							num_rows_to_clear <= 1;
							row_to_clear <= 18;
//							Board[18] <= Board[17];
//							Board[17] <= 10'b0;
							// end testing
							
							if (color+1 < number_of_colors)
								color <= color+1;
							else 
								color <= 0;
								
							if (piece_count == number_of_pieces-1)
								piece_count <= 0;
							else
								piece_count <= piece_count + 1;
						end
						else begin
							blockYPrevious[0] <= blockY1;
							blockYPrevious[1] <= blockY2;
							blockYPrevious[2] <= blockY3;
							blockYPrevious[3] <= blockY4;
				
							blockY1 <= blockY1 + blockYMotion;
							blockY2 <= blockY2 + blockYMotion;
							blockY3 <= blockY3 + blockYMotion;
							blockY4 <= blockY4 + blockYMotion;
						end
					 end
					 else 
						frame_count_move_Y <= frame_count_move_Y + 1;
			end
	  end	


	always_comb begin
			 
		blockXPos[0] = blockX1;
		blockYPos[0] = blockY1;
		blockXPos[1] = blockX2;
		blockYPos[1] = blockY2;
		blockXPos[2] = blockX3;
		blockYPos[2] = blockY3;
		blockXPos[3] = blockX4;
		blockYPos[3] = blockY4;
		blockXPrev = blockXPrevious;
		blockYPrev = blockYPrevious;
		blockColor = palette[color];
		Clear_row = clear_row;
		Num_rows_to_clear = num_rows_to_clear;
		Row_to_clear = row_to_clear;
	end


	
endmodule

//
//module Game_Logic (
//		input Reset, frame_clk, Clk,
//		input [7:0] keycode,
//		output logic [6:0] blockXPos [4], 
//		output logic [6:0] blockYPos [4],
//		output logic [6:0] blockXPrev [4], 
//		output logic [6:0] blockYPrev [4],
//		output logic [15:0] blockColor,
//		output logic Clear_row,
//		output logic [3:0] Num_rows_to_clear,
//		output logic [6:0] Row_to_clear
//	);
//	
//	parameter [6:0] board_width =9; // number of squares in each row (starting at 0)
//	parameter [6:0] board_height =19; // number of rows (starting at 0)
//	parameter [7:0] frames_per_move_X = 5;
////	parameter [7:0] frames_per_move_Y = 13;
//	parameter [4:0] number_of_colors = 3; // 1 indexed
//	parameter [49:0] keystroke_sample_period = 50'h10000;
//	parameter [4:0] number_of_pieces = 5'd4; // 1 indexed
//	
//	parameter [7:0] default_frames_per_move_Y = 13;
//	logic [7:0] frames_per_move_Y;
//	
//	logic [49:0] keystroke_counter; // counter to wait after sampling a keystroke to sample the next
//	
//	logic [6:0] row_to_clear;
//	logic [3:0] num_rows_to_clear;
//	logic clear_row;
//	
//	logic [9:0] Board[board_height+1]; // each bit represents the presence of a block in that square of the screen
//	logic [6:0] blockX1, blockX2, blockX3, blockX4; // zero indexed
//	logic [6:0] blockY1, blockY2, blockY3, blockY4; // zero indexed
//	
//	logic [6:0] blockXPrevious [4];
//	logic [6:0] blockYPrevious [4];
//	
//	logic [6:0] blockXMotion;
//	logic [7:0] blockYMotion;
//	logic [4:0] color;
//	
//	logic [15:0] palette [number_of_colors];
//	assign palette = '{16'h0f00, 16'h05f0, 16'h00a8};
//	
//	logic [5:0] Pieces[number_of_pieces][2][4]; // each peice's block positions for two rotations
//	assign Pieces = '{ // Format is for the last block to have the largest Y value to compare for clearing rows
//		'{'{6'b000000,6'b001000,6'b001001,6'b010001},'{6'b001000,6'b001001,6'b000001,6'b000010}}, // piece 1
//		'{'{6'b000000,6'b000001,6'b000010,6'b000011},'{6'b000000,6'b000001,6'b000010,6'b000011}}, // piece 2
//		'{'{6'b000000,6'b000001,6'b001000,6'b001001},'{6'b000000,6'b000001,6'b001000,6'b001001}}, // piece 3
//		'{'{6'b000000,6'b000001,6'b001001,6'b010001},'{6'b000000,6'b000001,6'b001001,6'b010001}}  // piece 4
//	}; // array of 3 different peices. each register in the array contains the coordinates
//	// for a block of the peice in the format [5:3]=Y [2:0]=X, relative to (0,0)
//	logic [2:0] piece_count;
//	logic piece_rotation;
//	
//	logic move_clk_X, move_clk_Y;
//	logic [5:0] frame_count_move_X, frame_count_move_Y;
//	
//	always_ff @ (posedge Reset or posedge frame_clk ) begin
//	    if (Reset) begin
//			frame_count_move_X <= 0;
//			frame_count_move_Y <= 0;
//			blockXPrevious[0] <= 7'b0;
//			blockXPrevious[1] <= 7'b0;
//			blockXPrevious[2] <= 7'b0;
//			blockXPrevious[3] <= 7'b0;
//		
//			blockX1 <= Pieces[0][0][0][2:0] + (board_width>>1); // divided by 2
//			blockX2 <= Pieces[0][0][1][2:0] + (board_width>>1);
//			blockX3 <= Pieces[0][0][2][2:0] + (board_width>>1);
//			blockX4 <= Pieces[0][0][3][2:0] + (board_width>>1);
//			
//			blockY1 <= Pieces[0][0][0][5:3];
//			blockY2 <= Pieces[0][0][1][5:3];
//			blockY3 <= Pieces[0][0][2][5:3];
//			blockY4 <= Pieces[0][0][3][5:3];
//			
//			blockYPrevious[0] <= 7'b0;
//			blockYPrevious[1] <= 7'b0;
//			blockYPrevious[2] <= 7'b0;
//			blockYPrevious[3] <= 7'b0;
//			
//			piece_count <= 1;
//			piece_rotation <= 0;
//			color <= 0;
//			Board <= '{default: 16'h0};
//		 end
//		 else begin
//			// 
//			// clear row logic
//			//
//			clear_row <= 1'b0;
////			if (Board[blockYPrevious[3]]==10'b1111111111) begin // determines if there's a row to clear, then
////			// looks at rows above it to see how many to clear (num_rows_to_clear referes to rows above the row_to_clear)
////				clear_row <= 1'b1;
////				row_to_clear <= blockYPrevious[3];
////				num_rows_to_clear <= 1;
////				if (row_to_clear >= 1 && Board[blockYPrevious[3]-1]==10'b1111111111) begin
////					num_rows_to_clear <= 2;
////					if (row_to_clear >= 2 && Board[blockYPrevious[3]-2]==10'b1111111111) begin
////						num_rows_to_clear <= 3;
////						if (row_to_clear >= 3 && Board[blockYPrevious[3]-3]==10'b1111111111) begin
////							num_rows_to_clear <= 4;
////						end
////					end
////				end
////			end
////			else if () begin
////
////			end
//		 
//		 
//			 //
//			 // move_clk_X logic
//			 //
//			 if (frame_count_move_X >= frames_per_move_X) begin: MoveX_Block
//				frame_count_move_X <= 0;
//				
//				blockXPrevious[0] <= blockX1;
//				blockXPrevious[1] <= blockX2;
//				blockXPrevious[2] <= blockX3;
//				blockXPrevious[3] <= blockX4;
//				
//				if ((blockX1+blockXMotion<board_width+1)&&(blockX1+blockXMotion>0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)&&
//					  (blockX2+blockXMotion<board_width+1)&&(blockX2+blockXMotion>0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)&&
//					  (blockX3+blockXMotion<board_width+1)&&(blockX3+blockXMotion>0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)&&
//					  (blockX4+blockXMotion<board_width+1)&&(blockX4+blockXMotion>0)&&(Board[blockX1+blockXMotion][blockY1]!=1'b1)) begin
//					blockX1 <= blockX1 + blockXMotion;
//					blockX2 <= blockX2 + blockXMotion;
//					blockX3 <= blockX3 + blockXMotion;
//					blockX4 <= blockX4 + blockXMotion;
//				end
//			 end
//			 else
//				frame_count_move_X <= frame_count_move_X + 1;
//				
//			 //
//			 // move_clk_Y logic
//			 //
//			 if (frame_count_move_Y >= frames_per_move_Y) begin: MoveY_Block
//				frame_count_move_Y <= 0;
//				
//				
//				if (
//				Board[blockY1+blockYMotion][blockX1]==1'b1 || (blockY1+blockYMotion>board_height) ||
//				Board[blockY2+blockYMotion][blockX2]==1'b1 || (blockY2+blockYMotion>board_height) ||
//				Board[blockY3+blockYMotion][blockX3]==1'b1 || (blockY3+blockYMotion>board_height) ||
//				Board[blockY4+blockYMotion][blockX4]==1'b1 || (blockY4+blockYMotion>board_height)
//				) begin // collision with other block or bottom of screen
//					// new block generated
//					blockYPrevious[0] <= 7'b0;
//					blockYPrevious[1] <= 7'b0;
//					blockYPrevious[2] <= 7'b0;
//					blockYPrevious[3] <= 7'b0;
//					
//					Board[blockY1][blockX1] <= 1'b1;
//					Board[blockY2][blockX2] <= 1'b1;
//					Board[blockY3][blockX3] <= 1'b1;
//					Board[blockY4][blockX4] <= 1'b1;
//					blockY1 <= Pieces[piece_count][0][0][5:3];
//					blockY2 <= Pieces[piece_count][0][1][5:3];
//					blockY3 <= Pieces[piece_count][0][2][5:3];
//					blockY4 <= Pieces[piece_count][0][3][5:3];
//					blockX1 <= Pieces[piece_count][0][0][2:0] + (board_width>>1); // divided by 2
//					blockX2 <= Pieces[piece_count][0][1][2:0] + (board_width>>1);
//					blockX3 <= Pieces[piece_count][0][2][2:0] + (board_width>>1);
//					blockX4 <= Pieces[piece_count][0][3][2:0] + (board_width>>1);
//					
//					// Testing
//					clear_row <= 1'b1;
//					num_rows_to_clear <= 1;
//					row_to_clear <= 18;
//					
//					if (color+1 < number_of_colors)
//						color <= color+1;
//					else 
//						color <= 0;
//						
//					if (piece_count == number_of_pieces-1)
//						piece_count <= 0;
//					else
//						piece_count <= piece_count + 1;
//				end
//				else begin
//					blockYPrevious[0] <= blockY1;
//					blockYPrevious[1] <= blockY2;
//					blockYPrevious[2] <= blockY3;
//					blockYPrevious[3] <= blockY4;
//		
//					blockY1 <= blockY1 + blockYMotion;
//					blockY2 <= blockY2 + blockYMotion;
//					blockY3 <= blockY3 + blockYMotion;
//					blockY4 <= blockY4 + blockYMotion;
//				end
//			 end
//			 else 
//				frame_count_move_Y <= frame_count_move_Y + 1;
//		end 
//	end
//	
//		
//		always_ff @ (posedge Clk )
//		 begin: Input_Block
//			blockXMotion <= 0;
//			blockYMotion <= 1;
//			frames_per_move_Y <= default_frames_per_move_Y;
//			case (keycode)
//				8'h04 : begin
//						  blockXMotion <= -1;//A
////							if ((blockX1>0)&&(blockX2>0)&&(blockX3>0)&&(blockX4>0))
////								blockXMotion <= -1;//A
//						  end
//						  
//				8'h07 : begin
//						  blockXMotion <= 1;//D
////						  if ((blockX1<board_width)&&
////							  (blockX2<board_width)&&
////							  (blockX3<board_width)&&
////							  (blockX4<board_width))
////								blockXMotion <= 1;//D
//						  end
//
//						  
//				8'h16 : begin
//							if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height)) begin
////								blockYMotion <= 2;//S
//								frames_per_move_Y <= default_frames_per_move_Y / 2;
//							end
//						 end
////				8'hd44 : begin // space
////							if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
////								blockYMotion <= 2;//S
////						 end
//						  
//	//					8'h1A : begin //W
//				default: ;
//			endcase
//	  end	
//
////	always_ff @ (posedge Clk )
////    begin: Input_Block
////		if (keystroke_counter < keystroke_sample_period)
////			keystroke_counter <= keystroke_counter + 1;
////		else begin
////			case (keycode)
////				8'h04 : begin
////							if ((blockX1>0)&&(blockX2>0)&&(blockX3>0)&&(blockX4>0)) begin
////								blockXMotion <= -1;//A
////								keystroke_counter <= 0;
////							end
////						  end
////						  
////				8'h07 : begin
////							
////						  if ((blockX1<board_width)&&(blockX2<board_width)&&(blockX3<board_width)&&(blockX4<board_width))begin
////								blockXMotion <= 1;//D
////								keystroke_counter <= 0;
////						  end
////						  end
////
////						  
////				8'h16 : begin
//////							if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
////								blockYMotion <= 2;//S
////								keystroke_counter <= 0;
////						 end
////	//					8'hd44 : begin // space
////	//								if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
////	//									blockYMotion <= 2;//S
////	//							 end
////						  
////	//					8'h1A : begin //W
////				default: begin
////						blockXMotion <= 0;
////						blockYMotion <= 1;
////				end 
////			endcase
////		end
////	  end	
////	  
//
//	always_comb begin
//			 
//		blockXPos[0] = blockX1;
//		blockYPos[0] = blockY1;
//		blockXPos[1] = blockX2;
//		blockYPos[1] = blockY2;
//		blockXPos[2] = blockX3;
//		blockYPos[2] = blockY3;
//		blockXPos[3] = blockX4;
//		blockYPos[3] = blockY4;
//		blockXPrev = blockXPrevious;
//		blockYPrev = blockYPrevious;
//		blockColor = palette[color];
//		Clear_row = clear_row;
//		Num_rows_to_clear = num_rows_to_clear;
//		Row_to_clear = row_to_clear;
//	end
//
//
//	
//endmodule