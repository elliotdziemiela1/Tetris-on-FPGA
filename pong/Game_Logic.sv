// will output the moving block's X and Y position

module Game_Logic (
		input Reset, frame_clk,
		input [7:0] keycode,
		output logic [5:0] blockX1Pos, blockX2Pos, blockX3Pos, blockX4Pos, 
		output logic [6:0] blockY1Pos, blockY2Pos, blockY3Pos, blockY4Pos,
		output logic [3:0] blockColor // index into palette
	);
	
	parameter [5:0] board_width =11; // number of squares in each row (starting at 0)
	parameter [6:0] board_height =18; // number of rows (starting at 0)
	parameter [7:0] frames_per_move = 13;
	
	logic [15:0] Blocks[board_height+1]; // each bit represents the presence of a block in that square
	// of the screen
	logic [5:0] blockX1, blockX2, blockX3, blockX4; // zero indexed
	logic [6:0] blockY1, blockY2, blockY3, blockY4; // zero indexed
	logic [6:0] blockXMotion;
	logic [7:0] blockYMotion;
	logic [3:0] color;
	
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
		  
	always_ff @ (posedge Reset or posedge move_clk )
    begin: Move_Block
		if (Reset)  // Asynchronous Reset
        begin 
            blockXMotion <= 7'd0;
				blockYMotion <= 8'd0; 
				blockX1 <= 7;
				blockY1 <= 0;
				blockX2 <= 7;
				blockY2 <= 1;
				blockX3 <= 8;
				blockY3 <= 1;
				blockX4 <= 8;
				blockY4 <= 2;

				color <= 1;
				Blocks <= '{default: 16'h0};

        end
		else begin
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

							  
					8'h16 : begin
								if ((blockY1<board_height)&&(blockY2<board_height)&&(blockY3<board_height)&&(blockY4<board_height))
									blockYMotion <= 2;//S
							 end
							  
//					8'h1A : begin //W
					default: ;
			   endcase
				
				if (
				Blocks[blockY1+blockYMotion][blockX1+blockXMotion]==1'b1 || (blockY1+blockYMotion>=board_height) ||
				Blocks[blockY2+blockYMotion][blockX2+blockXMotion]==1'b1 || (blockY2+blockYMotion>=board_height) ||
				Blocks[blockY3+blockYMotion][blockX3+blockXMotion]==1'b1 || (blockY3+blockYMotion>=board_height) ||
				Blocks[blockY4+blockYMotion][blockX4+blockXMotion]==1'b1 || (blockY4+blockYMotion>=board_height)
				) begin // collision with other block or bottom of screen
					// new block generated
					Blocks[blockY1][blockX1] <= 1'b1;
					Blocks[blockY2][blockX2] <= 1'b1;
					Blocks[blockY3][blockX3] <= 1'b1;
					Blocks[blockY4][blockX4] <= 1'b1;
					blockX1 <= 7; // middle of screen
					blockY1 <= 0;
					blockX2 <= 7; // middle of screen
					blockY2 <= 1;
					blockX3 <= 8; // middle of screen
					blockY3 <= 1;
					blockX4 <= 8; // middle of screen
					blockY4 <= 2;
					color <= color+1;
				end
				else begin
					blockX1 <= blockX1 + blockXMotion;
					blockX2 <= blockX2 + blockXMotion;
					blockX3 <= blockX3 + blockXMotion;
					blockX4 <= blockX4 + blockXMotion;
					blockY1 <= blockY1 + blockYMotion;
					blockY2 <= blockY2 + blockYMotion;
					blockY3 <= blockY3 + blockYMotion;
					blockY4 <= blockY4 + blockYMotion;
				end
		end
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