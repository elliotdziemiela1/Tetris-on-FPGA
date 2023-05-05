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
		output logic [6:0] Row_to_clear,
		output logic [4:0] Score_to_add [4]

	);
	
	parameter [6:0] board_width =9; // number of squares in each row (starting at 0)
	parameter [6:0] board_height =19; // number of rows (starting at 0)
	parameter [7:0] frames_per_move_X = 5;
//	parameter [7:0] frames_per_move_Y = 13;
	parameter [7:0] frames_per_rotate = 5;
	parameter [4:0] number_of_colors = 3; // 1 indexed
	parameter [49:0] keystroke_sample_period = 50'h10000;
	parameter [4:0] number_of_pieces = 5'd5; // 1 indexed
	
	parameter [7:0] default_frames_per_move_Y = 13;
	logic [7:0] frames_per_move_Y;
	
	logic frame_clk_flag;
	
	logic [49:0] keystroke_counter; // counter to wait after sampling a keystroke to sample the next
	logic W_pressed; // flag if space is pressed
	logic W_held, D_held, A_held;
	
	logic [6:0] row_to_clear;
	logic [3:0] num_rows_to_clear;
	logic clear_row;
	
	logic [9:0] Board[board_height+1]; // each bit represents the presence of a block in that square of the screen
	logic [6:0] blockX1, blockX2, blockX3, blockX4; // zero indexed
	logic [6:0] blockY1, blockY2, blockY3, blockY4; // zero indexed
	logic [6:0] blockXPrevious [4];
	logic [6:0] blockYPrevious [4];
	logic [6:0] blockYLanded [4];
	logic [6:0] blockXMotion; // register for non-rotating X motion
	logic [6:0] blockYMotion; // register for non-rotating Y motion
	logic [6:0] blockX1Motion, blockX2Motion, blockX3Motion, blockX4Motion; // combinational calculations for rotation motion
	logic [6:0] blockY1Motion, blockY2Motion, blockY3Motion, blockY4Motion; // combinational calculations for rotation motion
	logic [2:0] block_orientation;
	logic [4:0] color;
	
	logic [15:0] palette [number_of_colors];
	assign palette = '{16'h0f00, 16'h05f0, 16'h00a8};
	
	logic [13:0] Pieces[number_of_pieces][4][4]; // each peice's block positions for two rotations
	assign Pieces = '{ // Format is for the last block to have the largest Y value to compare for clearing rows and the second block
	// to have the middle X value
		'{'{14'b00000000000000,14'b00000010000000,14'b00000010000001,14'b00000100000001},'{14'b00000000000001,14'b00000000000010,14'b00000010000000,14'b00000010000001},'{14'b00000000000000,14'b00000010000000,14'b00000010000001,14'b00000100000001},'{14'b00000000000001,14'b00000000000010,14'b00000010000000,14'b00000010000001}}, // piece 1
		'{'{14'b00000000000000,14'b00000000000001,14'b00000000000010,14'b00000000000011},'{14'b00000000000000,14'b00000010000000,14'b00000100000000,14'b00000110000000},'{14'b00000000000000,14'b00000000000001,14'b00000000000010,14'b00000000000011},'{14'b00000000000000,14'b00000010000000,14'b00000100000000,14'b00000110000000}}, // piece 2
		'{'{14'b00000000000000,14'b00000000000001,14'b00000000000010,14'b00000010000001},'{14'b00000000000001,14'b00000010000001,14'b00000010000000,14'b00000100000001},'{14'b00000000000001,14'b00000010000000,14'b00000010000001,14'b00000010000010},'{14'b00000000000001,14'b00000010000001,14'b00000010000010,14'b00000100000001}},  // piece 4
		'{'{14'b00000000000000,14'b00000000000001,14'b00000010000000,14'b00000010000001},'{14'b00000000000000,14'b00000000000001,14'b00000010000000,14'b00000010000001},'{14'b00000000000000,14'b00000000000001,14'b00000010000000,14'b00000010000001},'{14'b00000000000000,14'b00000000000001,14'b00000010000000,14'b00000010000001}}, // piece 3
		'{'{14'b00000000000000,14'b00000000000001,14'b00000010000001,14'b00000100000001},'{14'b00000000000010,14'b00000010000000,14'b00000010000001,14'b00000010000010},'{14'b00000000000000,14'b00000010000000,14'b00000100000000,14'b00000100000001},'{14'b00000000000000,14'b00000000000001,14'b00000000000010,14'b00000010000000}}  // piece 4
		}; // array of 3 different peices. each register in the array contains the coordinates
	// for a block of the peice in the format [13:7]=Y [6:0]=X, relative to (0,0)
	logic [3:0] piece_count; // index of the next piece to be dropped, not the current
	logic piece_rotation;
	logic [3:0] current_piece;
	
	logic move_clk_X, move_clk_Y;
	logic [5:0] frame_count_move_X, frame_count_move_Y, frame_count_rotate;
	
	logic [4:0] score_to_add [4];
	assign Score_to_add = score_to_add;
	
	enum logic [15:0] {Wait, clear1, clear2, clear3, clear4} state;
	logic [6:0] clear_counter, clear_counter_start;
	logic [6:0] clear_row_counter, clear_row_counter_start;
	
	
	
		always_ff @ (posedge Clk )
		 begin: Input_Block
			frames_per_move_Y <= default_frames_per_move_Y;
			A_held <= 0;
			D_held <= 0;
			W_held <= 0;
			case (keycode)
				8'h04 : begin
						  A_held <= 1;
							if ((A_held==0))begin
								blockXMotion <= -1;//A
							end
					  end
						  
				8'h07 : begin
						  D_held <= 1;
						  if ((D_held==0))begin
								blockXMotion <= 1;//D
						  end
						  end

						  
				8'h16 : begin
							if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height)) begin
								frames_per_move_Y <= 2; // S
							end
						 end
				8'd26 : begin // W
							W_held <= 1;
							if (W_held == 0)
								W_pressed <= 1'b1;
						 end
				default: ;
			endcase
			
			if (Reset) begin
					frame_count_move_X <= 0;
					frame_count_move_Y <= 0;
					frame_count_rotate <= 0;
					blockXPrevious[0] <= 7'b0;
					blockXPrevious[1] <= 7'b0;
					blockXPrevious[2] <= 7'b0;
					blockXPrevious[3] <= 7'b0;
					
					blockYMotion <= 1;
				
					blockX1 <= Pieces[0][0][0][6:0] + (board_width>>1); // divided by 2
					blockX2 <= Pieces[0][0][1][6:0] + (board_width>>1);
					blockX3 <= Pieces[0][0][2][6:0] + (board_width>>1);
					blockX4 <= Pieces[0][0][3][6:0] + (board_width>>1);
					blockY1 <= Pieces[0][0][0][13:7];
					blockY2 <= Pieces[0][0][1][13:7];
					blockY3 <= Pieces[0][0][2][13:7];
					blockY4 <= Pieces[0][0][3][13:7];
					
					blockYPrevious[0] <= 7'b0;
					blockYPrevious[1] <= 7'b0;
					blockYPrevious[2] <= 7'b0;
					blockYPrevious[3] <= 7'b0;
					blockYLanded[0] <= 7'b0;
					blockYLanded[1] <= 7'b0;
					blockYLanded[2] <= 7'b0;
					blockYLanded[3] <= 7'b0;
					
					piece_count <= 0;
					current_piece <= 0;
					piece_rotation <= 0;
					color <= 0;
					Board <= '{default: 16'h0};
					
					frame_clk_flag <= 1'b0;
					
					block_orientation <= 1'b0;
					
					num_rows_to_clear <= 0;
					
		  end
		  
		  score_to_add[0] <= 5'h0;
		  score_to_add[1] <= 5'h0;
		  score_to_add[2] <= 5'h0;
		  score_to_add[3] <= 5'h0;
		  // row clearing state machine. clear_counter_start should be the topmost row of the clear.
		  unique case (state)
				Wait: clear_counter <= 0;
				clear1: begin
					if (num_rows_to_clear == 1)
						score_to_add[0] <= 5'h1;
					else if (num_rows_to_clear == 2)
						score_to_add[0] <= 5'h5;
					else if (num_rows_to_clear == 3)
						score_to_add[1] <= 5'h1;
					else if (num_rows_to_clear == 4) begin
						score_to_add[0] <= 5'h5;
						score_to_add[1] <= 5'h2;
					end
					clear_row_counter <= 0;
					clear_counter <= clear_counter_start;
					state <= clear2;
				end
				clear2: begin
					if (clear_row_counter != num_rows_to_clear) begin
						clear_counter <= clear_counter_start + clear_row_counter;
						state <= clear3;
					end
					else
						state <= Wait;
				end
				clear3: begin 
					if (clear_counter != 0) begin
						clear_counter <= clear_counter - 1;
						Board[clear_counter] <= Board[clear_counter-1];
					end
					else begin
						state <= clear2;
						clear_row_counter <= clear_row_counter + 1;
					end
				end
				clear4: ;
				default: ;
		  endcase
			
			
			
			
			if (frame_clk == 1'b0) begin
				frame_clk_flag <= 1'b0;
				clear_row <= 1'b0;
			end
// THIS HAPPENS ONCE, ONE CYCLE AFTER POSITIVE EDGE OF FRAME CLOCK
			if (frame_clk == 1'b1 && frame_clk_flag == 1'b0) begin
					blockXPrevious[0] <= blockX1;
					blockXPrevious[1] <= blockX2;
					blockXPrevious[2] <= blockX3;
					blockXPrevious[3] <= blockX4;
					blockYPrevious[0] <= blockY1;
					blockYPrevious[1] <= blockY2;
					blockYPrevious[2] <= blockY3;
					blockYPrevious[3] <= blockY4;
					
					if (piece_count == number_of_pieces-1)
						piece_count <= 0;
					else
						piece_count <= piece_count + 1;
					
					frame_clk_flag <= 1'b1;
					
					// 
					// clear row logic
					//
					
					if ((Board[blockYLanded[3]]==10'b1111111111) && (blockYLanded[3] >= 1)) begin // determines if there's a row to clear, then
					// looks at rows above it to see how many to clear (num_rows_to_clear referes to rows above the row_to_clear)
						clear_row <= 1'b1;
						row_to_clear <= blockYLanded[3];
						num_rows_to_clear <= 1;
						state <= clear1;
						clear_counter_start <= blockYLanded[3];
						if (Board[blockYLanded[3]-1]==10'b1111111111) begin
							num_rows_to_clear <= 2;
							clear_counter_start <= blockYLanded[3]-1;
							if (blockYLanded[3] >= 2 && Board[blockYLanded[3]-2]==10'b1111111111) begin
								num_rows_to_clear <= 3;
								clear_counter_start <= blockYLanded[3]-2;
								if (blockYLanded[3] >= 3 && Board[blockYLanded[3]-3]==10'b1111111111) begin
									num_rows_to_clear <= 4;
									clear_counter_start <= blockYLanded[3]-3;
								end
							end
						end
					end
					else if ((Board[blockYLanded[2]]==10'b1111111111) && (blockYLanded[2] >= 1)) begin // determines if there's a row to clear, then
					// looks at rows above it to see how many to clear (num_rows_to_clear referes to rows above the row_to_clear)
						clear_row <= 1'b1;
						row_to_clear <= blockYLanded[2];
						num_rows_to_clear <= 1;
						state <= clear1;
						clear_counter <= blockYLanded[2];
						
						if (Board[blockYLanded[2]-1]==10'b1111111111) begin
							num_rows_to_clear <= 2;
							clear_counter_start <= blockYLanded[2]-1;
							if (blockYLanded[2] >= 2 && Board[blockYLanded[2]-2]==10'b1111111111) begin
								num_rows_to_clear <= 3;
								clear_counter_start <= blockYLanded[2]-2;
								if (blockYLanded[2] >= 3 && Board[blockYLanded[2]-3]==10'b1111111111) begin
									num_rows_to_clear <= 4;
									clear_counter_start <= blockYLanded[2]-3;
								end
							end
						end
					end
					else if ((Board[blockYLanded[1]]==10'b1111111111) && (blockYLanded[1] >= 1)) begin // determines if there's a row to clear, then
					// looks at rows above it to see how many to clear (num_rows_to_clear referes to rows above the row_to_clear)
						clear_row <= 1'b1;
						row_to_clear <= blockYLanded[1];
						num_rows_to_clear <= 1;
						state <= clear1;
						clear_counter <= blockYLanded[1];
						if (Board[blockYLanded[1]-1]==10'b1111111111) begin
							num_rows_to_clear <= 2;
							clear_counter_start <= blockYLanded[1]-1;
							if (blockYLanded[1] >= 2 && Board[blockYLanded[1]-2]==10'b1111111111) begin
								num_rows_to_clear <= 3;
								clear_counter_start <= blockYLanded[1]-2;
								if (blockYLanded[1] >= 3 && Board[blockYLanded[1]-3]==10'b1111111111) begin
									num_rows_to_clear <= 4;
									clear_counter_start <= blockYLanded[1]-3;
								end
							end
						end
					end
					else if ((Board[blockYLanded[0]]==10'b1111111111) && (blockYLanded[0] >= 1)) begin // determines if there's a row to clear, then
					// looks at rows above it to see how many to clear (num_rows_to_clear referes to rows above the row_to_clear)
						clear_row <= 1'b1;
						row_to_clear <= blockYLanded[0];
						num_rows_to_clear <= 1;
						state <= clear1;
						clear_counter <= blockYLanded[0];
						if (Board[blockYLanded[0]-1]==10'b1111111111) begin
							num_rows_to_clear <= 2;
							clear_counter_start <= blockYLanded[0]-1;
							if (blockYLanded[0] >= 2 && Board[blockYLanded[0]-2]==10'b1111111111) begin
								num_rows_to_clear <= 3;
								clear_counter_start <= blockYLanded[0]-2;
								if (blockYLanded[0] >= 3 && Board[blockYLanded[0]-3]==10'b1111111111) begin
									num_rows_to_clear <= 4;
									clear_counter_start <= blockYLanded[0]-3;
								end
							end
						end
					end
					else begin
						
						 //
						// rotate logic
						// 
						if ((frame_count_rotate >= frames_per_rotate) && (frame_count_move_Y != frames_per_move_Y)) begin: Rotate_Block // if not rotating on a move Y frame
								frame_count_rotate <= 0;
								W_pressed <= 1'b0;
								if (W_pressed) begin
									if ((blockX1+blockX1Motion!=7'b1111111)&&(blockX2+blockX2Motion!=7'b1111111)&&(blockX3+blockX3Motion!=7'b1111111)&&(blockX4+blockX4Motion!=7'b1111111)&& // if within bounds
										(blockX1+blockX1Motion<=board_width)&&(blockX2+blockX2Motion<=board_width)&&(blockX3+blockX3Motion<=board_width)&&(blockX4+blockX4Motion<=board_width)&& 
										(blockY1+blockY1Motion<=board_height)&&(blockY2+blockY2Motion<=board_height)&&(blockY3+blockY3Motion<=board_height)&&(blockY4+blockY4Motion<=board_height)&&
										(Board[blockY1+blockY1Motion][blockX1+blockX1Motion]!=1'b1)&&(Board[blockY2+blockY2Motion][blockX2+blockX2Motion]!=1'b1)&& // and if no collisions
										(Board[blockY3+blockY3Motion][blockX3+blockX3Motion]!=1'b1)&&(Board[blockY4+blockY4Motion][blockX4+blockX4Motion]!=1'b1)
										) begin
											if (block_orientation == 3)
												block_orientation <= 0;
											else
												block_orientation <= block_orientation + 1;
											blockX1 <= blockX1 + blockX1Motion;
											blockX2 <= blockX2 + blockX2Motion;
											blockX3 <= blockX3 + blockX3Motion;
											blockX4 <= blockX4 + blockX4Motion;
											blockY1 <= blockY1 + blockY1Motion;
											blockY2 <= blockY2 + blockY2Motion;
											blockY3 <= blockY3 + blockY3Motion;
											blockY4 <= blockY4 + blockY4Motion;
										end
								end
							// if rotating on a move Y frame then we do nothing, dont increment this counter, and we repeat next frame.
						end
						else 
							frame_count_rotate <= frame_count_rotate + 1;
						
						 //
						 // move_clk_X logic
						 //
						 if (frame_count_move_X >= frames_per_move_X) begin: MoveX_Block
							frame_count_move_X <= 0;
							blockXMotion <= 0;
							
							
							if (!((frame_count_rotate >= frames_per_rotate)&&(frame_count_move_Y != frames_per_move_Y)&&(W_pressed))&& // if not in a rotate frame
							(blockX1+blockXMotion!=7'b1111111)&&(blockX2+blockXMotion!=7'b1111111)&&(blockX3+blockXMotion!=7'b1111111)&&(blockX4+blockXMotion!=7'b1111111)&& // and within bounds
							(blockX1+blockXMotion<=board_width)&&(blockX2+blockXMotion<=board_width)&&(blockX3+blockXMotion<=board_width)&&(blockX4+blockXMotion<=board_width)&&
							(Board[blockY1][blockX1+blockXMotion]!=1'b1)&&(Board[blockY2][blockX2+blockXMotion]!=1'b1)&& //and not colliding with other blocks
							(Board[blockY3][blockX3+blockXMotion]!=1'b1)&&(Board[blockY4][blockX4+blockXMotion]!=1'b1)
							) begin
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
							blockYMotion <= 1;
							
							
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
								
								blockYLanded[0] <= blockY1;
								blockYLanded[1] <= blockY2;
								blockYLanded[2] <= blockY3;
								blockYLanded[3] <= blockY4;
								
								Board[blockY1][blockX1] <= 1'b1;
								Board[blockY2][blockX2] <= 1'b1;
								Board[blockY3][blockX3] <= 1'b1;
								Board[blockY4][blockX4] <= 1'b1;
								blockY1 <= Pieces[piece_count][0][0][13:7];
								blockY2 <= Pieces[piece_count][0][1][13:7];
								blockY3 <= Pieces[piece_count][0][2][13:7];
								blockY4 <= Pieces[piece_count][0][3][13:7];
								blockX1 <= Pieces[piece_count][0][0][6:0] + (board_width>>1); // divided by 2
								blockX2 <= Pieces[piece_count][0][1][6:0] + (board_width>>1);
								blockX3 <= Pieces[piece_count][0][2][6:0] + (board_width>>1);
								blockX4 <= Pieces[piece_count][0][3][6:0] + (board_width>>1);
								
								// Testing
	//							clear_row <= 1'b1;
	//							num_rows_to_clear <= 1;
	//							row_to_clear <= 18;
	//							Board[1:18] <= Board[0:17];
								// end testing
								
								block_orientation <= 0;
								
								current_piece <= piece_count; 
								
								if (color+1 < number_of_colors)
									color <= color+1;
								else 
									color <= 0;
									
							end
							else begin
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
	  end	

	always_comb begin

		blockX1Motion = (Pieces[current_piece][(block_orientation+1)%4][0][6:0] - Pieces[current_piece][block_orientation][0][6:0]);
		blockX2Motion = (Pieces[current_piece][(block_orientation+1)%4][1][6:0] - Pieces[current_piece][block_orientation][1][6:0]);
		blockX3Motion = (Pieces[current_piece][(block_orientation+1)%4][2][6:0] - Pieces[current_piece][block_orientation][2][6:0]);
		blockX4Motion = (Pieces[current_piece][(block_orientation+1)%4][3][6:0] - Pieces[current_piece][block_orientation][3][6:0]);
		blockY1Motion = (Pieces[current_piece][(block_orientation+1)%4][0][13:7] - Pieces[current_piece][block_orientation][0][13:7]);
		blockY2Motion = (Pieces[current_piece][(block_orientation+1)%4][1][13:7] - Pieces[current_piece][block_orientation][1][13:7]);
		blockY3Motion = (Pieces[current_piece][(block_orientation+1)%4][2][13:7] - Pieces[current_piece][block_orientation][2][13:7]);
		blockY4Motion = (Pieces[current_piece][(block_orientation+1)%4][3][13:7] - Pieces[current_piece][block_orientation][3][13:7]);

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
