// will output the moving block's X and Y position

module Game_Logic (
		input Reset, frame_clk,
		input [7:0] keycode,
		output logic [5:0] blockXPos, 
		output logic [6:0] blockYPos,
		output logic [3:0] blockColor // index into palette
	);
	
	parameter [5:0] board_width =11; // number of squares in each row (starting at 0)
	parameter [6:0] board_height =18; // number of rows (starting at 0)
	parameter [7:0] frames_per_move = 13;
	
	logic [15:0] Blocks[board_height+1]; // each bit represents the presence of a block in that square
	// of the screen
	logic [5:0] blockX; // zero indexed
	logic [6:0] blockY; // zero indexed
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
				blockY <= 0;
				blockX <= 7;
				color <= 1;
				Blocks <= '{default: 16'h0};

        end
		else begin
				blockXMotion <= 0;
				blockYMotion <= 1;
				case (keycode)
					8'h04 : begin
								if (blockX > 0)
									blockXMotion <= -1;//A
							  end
					        
					8'h07 : begin
								
					        if (blockX < board_width)
									blockXMotion <= 1;//D
							  end

							  
					8'h16 : begin
								if (blockY < board_height)
									blockYMotion <= 2;//S
							 end
							  
//					8'h1A : begin //W
					default: ;
			   endcase
				
				if (Blocks[blockY + blockYMotion][blockX + blockXMotion] == 1'b1 || (blockY + blockYMotion >= board_height)) begin // collision with other block or bottom of screen
					// new block generated
					Blocks[blockY][blockX] <= 1'b1;
					blockX <= 7; // middle of screen
					blockY <= 0;
					color <= color+1;
				end
				else begin
					blockX <= blockX + blockXMotion;
					blockY <= blockY + blockYMotion;
				end
// DEBUG
//				case (keycode)
//					8'h04 : begin
//								if (blockX > 0)
//									blockXMotion <= -1;//A
//								else
//									blockXMotion <= 0;
//								blockYMotion<= 0;
//							  end
//					        
//					8'h07 : begin
//								
//					        if (blockX < board_width)
//									blockXMotion <= 1;//D
//								else
//									blockXMotion <= 0;
//							  blockYMotion <= 0;
//							  end
//
//							  
//					8'h16 : begin
//								
//							 end
//							  
////					8'h1A : begin //W
//					default: begin
//						blockXMotion <= 0;
//						blockYMotion <= 0;
//						end
//			   endcase
//				blockX <= blockX + blockXMotion;
//				blockY <= blockY + blockYMotion;
		end
	end	

	always_comb begin
		blockXPos = blockX;
		blockYPos = blockY;
		blockColor = color;
	end


	
endmodule 