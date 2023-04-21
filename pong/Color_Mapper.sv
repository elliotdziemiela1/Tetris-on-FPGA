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

module  color_mapper ( input        [9:0] ballx, bally, DrawX, DrawY, Ball_size,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on;
	 

	 parameter squareSize = (640/2)/12; // half of the screen is the board, and divide that by
	 // the # of squares in a row of the board
	 logic [9:0] BallX, BallY;
	 
	 assign BallX = (ballx * squareSize) + (640/4); // start at second quarter of screen
	 assign BallY = bally * squareSize;
//	 assign BallX = ballx; // start at second quarter of screen
//	 assign BallY = bally;
    int DistX, DistY, Size;
	 assign DistX = DrawX - BallX; // change to BallX
    assign DistY = DrawY - BallY; // change to BallY
//    assign Size = Ball_size;
	assign Size = squareSize/2;
	  
    always_comb
    begin:Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) || (DrawX <= (640/4) - (squareSize/2)) || (DrawX >= (3*640/4) + (squareSize/2))) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
       
    always_comb
    begin:RGB_Display
        if ((ball_on == 1'b1)) 
        begin 
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
        end  
        else 
        begin 
            Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h7f - DrawX[9:3];
        end      
    end 
    
endmodule
