// will output the moving block's X and Y position

module Game_Logic (
		input Reset, frame_clk, Clk,
		input [7:0] keycode,
		output logic [5:0] blockX1Pos, blockX2Pos, blockX3Pos, blockX4Pos, 
		output logic [6:0] blockY1Pos, blockY2Pos, blockY3Pos, blockY4Pos,
		output logic [3:0] blockColor // index into palette
	);
	
	parameter [5:0] board_width =11; // number of squares in each row (starting at 0)
	parameter [6:0] board_height =18; // number of rows (starting at 0)
	parameter [7:0] frames_per_move = 13;
	
	logic [15:0] Board[board_height+1]; // each bit represents the presence of a block in that square of the screen
	logic [5:0] blockX1, blockX2, blockX3, blockX4; // zero indexed
	logic [6:0] blockY1, blockY2, blockY3, blockY4; // zero indexed
	logic [6:0] blockXMotion;
	logic [7:0] blockYMotion;
	logic [3:0] color;
	
	logic [5:0] Pieces[3][2][4]; // each peice's block positions for two rotations
	assign Pieces = '{
		'{'{6'b000000,6'b001000,6'b001001,6'b010001},'{6'b001000,6'b001001,6'b000001,6'b000010}}, // piece 1
		'{'{6'b000000,6'b000001,6'b001000,6'b001001},'{6'b000000,6'b000001,6'b001000,6'b001001}}, // piece 2
		'{'{6'b000000,6'b001000,6'b001001,6'b010001},'{6'b001000,6'b001001,6'b000001,6'b000010}}  // piece 3
	}; // array of 3 different peices. each register in the array contains the coordinates
	// for a block of the peice in the format [5:3]=Y [2:0]=X, relative to (0,0)
	logic [2:0] piece_count;
	logic piece_rotation;
	
	logic move_clk;
	logic [5:0] frame_count;
	
	always_ff @ (posedge Reset or posedge frame_clk ) begin
	    if (Reset)
			frame_count <= 0;
		 else begin
			 
			 if (frame_count > frames_per_move) begin
				frame_count <= 0;
				move_clk <= 1;
			 end
			 else begin
				frame_count <= frame_count + 1;
				move_clk <= 0;
			 end
		 end
		  
		  
	end
	
	always_ff @ (posedge frame_clk )
		begin: MoveX_Block
			if (Reset)  // Asynchronous Reset
			  begin 
					blockX1 <= Pieces[0][0][0][2:0] + (board_width>>1); // divided by 2
					blockX2 <= Pieces[0][0][1][2:0] + (board_width>>1);
					blockX3 <= Pieces[0][0][2][2:0] + (board_width>>1);
					blockX4 <= Pieces[0][0][3][2:0] + (board_width>>1);
			  end
			blockX1 <= blockX1 + blockXMotion;
			blockX2 <= blockX2 + blockXMotion;
			blockX3 <= blockX3 + blockXMotion;
			blockX4 <= blockX4 + blockXMotion;
		end
	 
	always_ff @ (posedge move_clk )
		begin: MoveY_Block
		if (Reset)  // Asynchronous Reset
        begin 
//				blockX1 <= Pieces[0][0][0][2:0] + (board_width>>1); // divided by 2
				blockY1 <= Pieces[0][0][0][5:3];
//				blockX2 <= Pieces[0][0][1][2:0] + (board_width>>1);
				blockY2 <= Pieces[0][0][1][5:3];
//				blockX3 <= Pieces[0][0][2][2:0] + (board_width>>1);
				blockY3 <= Pieces[0][0][2][5:3];
//				blockX4 <= Pieces[0][0][3][2:0] + (board_width>>1);
				blockY4 <= Pieces[0][0][3][5:3];
				
				piece_count <= 0;
				piece_rotation <= 0;
				color <= 1;
				Board <= '{default: 16'h0};
        end
		else 
			if (
				Board[blockY1+blockYMotion][blockX1]==1'b1 || (blockY1+blockYMotion>=board_height) ||
				Board[blockY2+blockYMotion][blockX2]==1'b1 || (blockY2+blockYMotion>=board_height) ||
				Board[blockY3+blockYMotion][blockX3]==1'b1 || (blockY3+blockYMotion>=board_height) ||
				Board[blockY4+blockYMotion][blockX4]==1'b1 || (blockY4+blockYMotion>=board_height)
				) begin // collision with other block or bottom of screen
					// new block generated
					Board[blockY1][blockX1] <= 1'b1;
					Board[blockY2][blockX2] <= 1'b1;
					Board[blockY3][blockX3] <= 1'b1;
					Board[blockY4][blockX4] <= 1'b1;
//					blockX1 <= Pieces[piece_count][0][0][2:0] + (board_width>>1); // divided by 2
					blockY1 <= Pieces[piece_count][0][0][5:3];
//					blockX2 <= Pieces[piece_count][0][1][2:0] + (board_width>>1); // divided by 2
					blockY2 <= Pieces[piece_count][0][1][5:3];
//					blockX3 <= Pieces[piece_count][0][2][2:0] + (board_width>>1); // divided by 2
					blockY3 <= Pieces[piece_count][0][2][5:3];
//					blockX4 <= Pieces[piece_count][0][3][2:0] + (board_width>>1); // divided by 2
					blockY4 <= Pieces[piece_count][0][3][5:3];
					color <= color+1;
					if (piece_count == 3'h2)
						piece_count <= 0;
					else
						piece_count <= piece_count + 1;
				end
			else begin
					blockY1 <= blockY1 + blockYMotion;
					blockY2 <= blockY2 + blockYMotion;
					blockY3 <= blockY3 + blockYMotion;
					blockY4 <= blockY4 + blockYMotion;
				end
		end
		  
	always_ff @ (posedge Reset or posedge Clk )
    begin: Input_Block
		blockXMotion <= 0;
		blockYMotion <= 1;
		case (keycode)
			8'h04 : begin
						if ((blockX1>0)&&(blockX2>0)&&(blockX3>0)&&(blockX4>0))
							blockXMotion <= -1;//A
					  end
					  
			8'h07 : begin
						
					  if ((blockX1<board_width)&&(blockX2<board_width)&&(blockX3<board_width)&&(blockX4<board_width))
							blockXMotion <= 1;//D
					  end

					  
//					8'h16 : begin
//								if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
//									blockYMotion <= 2;//S
//							 end
//					8'hd44 : begin // space
//								if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
//									blockYMotion <= 2;//S
//							 end
					  
//					8'h1A : begin //W
			default: ;
		endcase
	  end	

	always_comb begin
		blockX1Pos = blockX1;
		blockY1Pos = blockY1;
		blockX2Pos = blockX2;
		blockY2Pos = blockY2;
		blockX3Pos = blockX3;
		blockY3Pos = blockY3;
		blockX4Pos = blockX4;
		blockY4Pos = blockY4;
		blockColor = color;
	end


	
endmodule 