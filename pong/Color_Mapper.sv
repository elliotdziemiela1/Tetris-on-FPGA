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

module  color_mapper ( input        [9:0] blockx1, blocky1, blockx2, blocky2, blockx3, blocky3, blockx4, blocky4, DrawX, DrawY, Ball_size,
                       output logic [7:0]  Red, Green, Blue );
    
	 
    logic ball_on;
	 

	 parameter squareSize = (640/2)/12; // half of the screen is the board, and divide that by
	 // the # of squares in a row of the board
	 logic [9:0] BallX [4]; 
	 logic [9:0] BallY [4];
	 
	 assign BallX[0] = (blockx1 * squareSize) + (640/4); // start at second quarter of screen
	 assign BallY[0] = blocky1 * squareSize;
	 assign BallX[1] = (blockx2 * squareSize) + (640/4); // start at second quarter of screen
	 assign BallY[1] = blocky2 * squareSize;
	 assign BallX[2] = (blockx3 * squareSize) + (640/4); // start at second quarter of screen
	 assign BallY[2] = blocky3 * squareSize;
	 assign BallX[3] = (blockx4 * squareSize) + (640/4); // start at second quarter of screen
	 assign BallY[3] = blocky4 * squareSize;
//	 assign BallX = ballx; // start at second quarter of screen
//	 assign BallY = bally;
    int DistX1, DistY1, DistX2, DistY2, DistX3, DistY3, DistX4, DistY4;
	 int Size;
	 assign DistX1 = DrawX - BallX[0]; 
    assign DistY1 = DrawY - BallY[0]; 
	 assign DistX2 = DrawX - BallX[1]; 
    assign DistY2 = DrawY - BallY[1]; 
	 assign DistX3 = DrawX - BallX[2]; 
    assign DistY3 = DrawY - BallY[2]; 
	 assign DistX4 = DrawX - BallX[3]; 
    assign DistY4 = DrawY - BallY[3]; 
//    assign Size = Ball_size;
	assign Size = squareSize/2;
	  
    always_comb
    begin:Ball_on_proc
        if ( 
		  (DistX1*DistX1+DistY1*DistY1)<=(Size*Size) || (DistX2*DistX2+DistY2*DistY2)<=(Size*Size) || 
		  (DistX3*DistX3+DistY3*DistY3)<=(Size*Size) || (DistX4*DistX4+DistY4*DistY4)<=(Size*Size) || 
		  (DrawX <= (640/4) - (squareSize/2)) || (DrawX >= (3*640/4) + (squareSize/2))
		  ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
       
    always_comb
    begin:RGB_Display
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
		  if (DrawX > 300) begin
			  Red = 8'hff;
			  Green = 8'h55;
			  Blue = 8'h00;
		  end 
		  else begin
			  Red = 8'h00;
			  Green = 8'h55;
			  Blue = 8'hff;
		  end 
    end 
    
endmodule
