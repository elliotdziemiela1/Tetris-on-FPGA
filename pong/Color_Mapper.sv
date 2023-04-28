//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// VGA = 640*480

module  color_mapper (  input Clk, hs,
								input logic [15:0] Row [10],
								input logic rowReady,
								input logic [9:0] DrawX, DrawY,
								output logic [7:0] rowNum,
							   output logic LD_Row,
								output logic [7:0]  Red, Green, Blue );
    
	 
	 parameter squareSize = (640/2)/(board_width+1); // half of the screen is the board, and divide that by
	 // the # of squares in a row of the board
	 parameter [6:0] board_width =9; // number of squares in each row (starting at 0)
	 parameter [6:0] board_height =19;
	 
	 logic [7:0] currentRow;
	 
       
    always_comb
    begin:RGB_Display
        if ((DrawX >= (640/4)) && (DrawX < (3*640/4)))  // if drawing in board
        begin 
				Red = Row[(DrawX-(640/4))/(squareSize)][3:0];
            Green = Row[(DrawX-(640/4))/(squareSize)][7:4];
            Blue = Row[(DrawX-(640/4))/(squareSize)][11:8];
        end  
        else 
        begin // draw side bars
            Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h7c;
        end   
    end 
    
	 
	 enum logic [15:0] {S1, S2, Wait} state;

	// State machine logic with reset for correct default values of regs
	always_ff @(posedge Clk)
	begin
		unique case (state)
			Wait: begin
				if (hs == 1'b1 && ((DrawY+1) % squareSize == 0)) begin // at the end of a block row fetch the next row
					state <= S1;
				end
				end 
			S1: begin
				state <= Wait;
				end 
//			S2: begin
//				
//				state <= Wait
//				end 
			default: ;
		endcase
	end
	
	always_comb 
	begin
		rowNum = 0;
		LD_Row = 1'b0;
		unique case (state)
			Wait: begin
				if (DrawY >= 639) begin  // if at the end of the last block row
					rowNum = 0;
					LD_Row = 1'b1;
				end
				else if (hs == 1'b1 && ((DrawY+1) % squareSize == 0)) begin  // else if at the end at a block row
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
endmodule

//// VGA = 640*480
//
//module  color_mapper ( input        [9:0] blockx1, blocky1, blockx2, blocky2, blockx3, blocky3, blockx4, blocky4, DrawX, DrawY, Ball_size,
//                       output logic [7:0]  Red, Green, Blue );
//    
//	 
//    logic ball_on;
//	 
//
//	 parameter squareSize = (640/2)/12; // half of the screen is the board, and divide that by
//	 // the # of squares in a row of the board
//	 logic [9:0] BallX [4]; 
//	 logic [9:0] BallY [4];
//	 
//	 assign BallX[0] = (blockx1 * squareSize) + (640/4); // start at second quarter of screen
//	 assign BallY[0] = blocky1 * squareSize;
//	 assign BallX[1] = (blockx2 * squareSize) + (640/4); // start at second quarter of screen
//	 assign BallY[1] = blocky2 * squareSize;
//	 assign BallX[2] = (blockx3 * squareSize) + (640/4); // start at second quarter of screen
//	 assign BallY[2] = blocky3 * squareSize;
//	 assign BallX[3] = (blockx4 * squareSize) + (640/4); // start at second quarter of screen
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
//		  (DrawX <= (640/4) - (squareSize/2)) || (DrawX >= (3*640/4) + (squareSize/2))
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