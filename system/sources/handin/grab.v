module grab 
  (
  input clockin,
  input existsin,
  input [68:0] infoin,
  
  output reg existsout,
  
  output reg [68:0] infout,
  output clockout,
  output reg vibrate1,
  output reg vibrate2
  );


 
  wire [10:0] hcount;
  wire [9:0]  vcount;
  wire hsync,vsync,blank;
  wire clock_65mhz;
  wire [10:0] userhand1x;
  wire [9:0]  userhand1y;
  wire [10:0] userhand2x;
  wire [9:0] userhand2y;
  wire usergrab1;
  wire usergrab2;
  wire reset;
  
  reg [68:2] infoindelay;

  assign {reset,hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;   ///labels inputs
  assign vclock = clockin;
 
  always @(posedge vclock)begin  infout[68:2] <= infoindelay[68:2];  infoindelay<= infoin[68:2];end        ///assigns pipelined info
  assign clockout = clockin;                            /// pipelines clock as well


  always@(posedge vclock) existsout <= existsin;        /// pipelines exist also

  reg nextgrab1;   /// scans all pixels and looks for overlap, this is set to the output once every frame, then reset
  reg nextgrab2;

  always @(posedge vclock) begin
  
	    if ((existsin == 1 && usergrab1 ==0) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150))    ///  checks if the hand is over a hold, but not grabbing
				vibrate1<=1;
		 else if ((hcount == 0 )&& (vcount==0)) vibrate1<=0;
  
		 if ((existsin == 1 && usergrab2 ==0) &&(((hcount-userhand2x)*(hcount-userhand2x)+(vcount-userhand2y)*(vcount-userhand2y)) < 150))  //// does the same for hand 2
				vibrate2 <= 1;
		 else if ((hcount == 0 )&& (vcount==0)) vibrate2<=0;
  
  
	     if ((infout[0] ==1)&& (usergrab1 ==1))       /// If a player held a hold in the last frame, and continues holding, he will continue holding in the game, prevents glitches
		     nextgrab1 <= 1;
		  
        else if ((existsin == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150))   ///checks to see if overlap of hand and hold + grabbing
          nextgrab1 <=1;
        else if (hcount==0 && vcount==0)  ////resets nextgrab at each vsync
          nextgrab1 <=0;
        else 
          nextgrab1 <= nextgrab1;  /// default case
			

		
	     if ((infout[1] ==1)&& (usergrab2 ==1))   /// does the same for the second hand
		     nextgrab2 <= 1;
		  else if ((existsin == 1 && usergrab2 ==1) &&(((hcount-userhand2x)*(hcount-userhand2x)+(vcount-userhand2y)*(vcount-userhand2y)) < 150))
          nextgrab2 <=1;
        else if (hcount==0 && vcount==0)
          nextgrab2 <=0;
        else
          nextgrab2 <= nextgrab2;
  end

  always @(posedge vsync) begin

    infout[0] <= nextgrab1;  ///updates output at each frame
	 infout[1] <= nextgrab2;
	end

endmodule