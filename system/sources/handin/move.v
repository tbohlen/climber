module movement 
  (
  input existsin,
  input [68:0] infoin,
  input switch,
  input signed  [11:0] screenxin,
  input signed  [12:0] screenyin,
  output reg signed  [11:0] screenx,
  output reg signed  [12:0] screeny

  );

  wire reset;
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


  reg anchorhand;           ///anchorhand determines which hand governs movement

  reg delaygrab1;            //// grab pulses are used to detect if a player grabs a new hold, will be used to update anchorhand
  reg delaygrab2;
  reg grab1pulse;
  reg grab2pulse;
  
  reg delay2grab1;
  reg delay2grab2;
  
  reg [10:0]delay1handx1;          /// additionally, the hand positions are also pipelined twice, becuase grabpulse must go through two clock cycles to be created.
  reg [9:0]delay1handy1;
  reg [10:0]delay2handx1;
  reg [9:0]delay2handy1;
  
  

  reg [10:0] holdx;                /// position of hands when grabbed, used to update movement
  reg  [9:0] holdy;
  reg signed [11:0] holdscreenx;   /// position of screen when grabbed, used to update movement
  reg signed [12:0] holdscreeny;


  reg signed [12-1:0] prevposx1;
  reg signed [13-1:0] prevposy1;    /// takes previous positions of the player, will be used to calculate freefall velocity
  reg signed [12-1:0] prevposx2;
  reg signed [13-1:0] prevposy2;    /// however in the implimentation, only the most recent is used.
  reg signed [12-1:0] prevposx3;
  reg signed [13-1:0] prevposy3;
  reg signed [12-1:0] prevposx4;
  reg signed [13-1:0] prevposy4;

  reg signed  [11:0] nscreenx;        // next screen position
  reg signed  [12:0] nscreeny;
  
  
	reg signed [11:0] switchdifx;      // used in map editor mode, registeres were used to ensure proper signing and length
	reg signed [12:0] switchdify;      // the difference between hand 1 position and center of the screen, will be used in map editor movement

	reg fallcount;                      /// used to get gravity to desired strength
 
  assign {reset,  hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;  //pipeline info


  always @(posedge vsync) begin

    delaygrab1 <= usergrab1;
    delaygrab2 <= usergrab2;
    grab1pulse <= usergrab1 && ~ delaygrab1;
    grab2pulse <= usergrab2 && ~ delaygrab2;       //// create grab pulses 
	 
	 delay2grab1 <= delaygrab1;	 
	 delay2grab2 <= delaygrab2;
	 
	 
	 delay1handx1<=userhand1x;
	 delay2handx1<=delay1handx1;           //// delay hand positions
	 delay1handy1<=userhand1y;
	 delay2handy1<=delay1handy1;

    prevposx4 <= prevposx3;
    prevposx3 <= prevposx2;
    prevposx2 <= prevposx1;               //// store previous positinos for freefall
    prevposx1 <= screenx;
    prevposy4 <= prevposy3;
    prevposy3 <= prevposy2;
    prevposy2 <= prevposy1;
    prevposy1 <= screeny;
	 
	switchdifx <= (userhand1x-(screenx+512));            //// difference from hand 1 and center of screen, should 
	switchdify <= (userhand1y-(screeny+ (384)));

    if (grab1pulse || (anchorhand ==1 && usergrab2 == 0 && usergrab1 == 1)) begin            /// if a player grabs with a new hand, or lets go with the anchoring hand, and other hand still holds, switch anchoring hand
      anchorhand <= 0;
      holdx <= userhand1x;
      holdy <= userhand1y;
      holdscreenx <= screenx;
      holdscreeny <= screeny;
	 end
	 
    else if (grab2pulse || (anchorhand ==0 && usergrab1 == 0 && usergrab2 == 1)) begin       //// anchoring calculation for hand2
      anchorhand <= 1;
      holdx <= userhand2x;
      holdy <= userhand2y;
      holdscreenx <= screenx;
      holdscreeny <= screeny;
	end

    else begin 
      anchorhand <= anchorhand;
      holdx <= holdx;
      holdy <= holdy;                              ////default
      holdscreenx <= holdscreenx;
      holdscreeny <= holdscreeny;
		end

	 
	 if (switch==1) begin
		nscreenx <= screenx +(switchdifx>>>1);            /// map editor mode, not sure why this movement doesnt work, registers all correct length and singing, should move player in direction of hand
		nscreeny <=  screeny +(switchdify>>>1);           //// allowing them to edit the map easily. 
	end

	
	 else if (usergrab1 == 0 && usergrab2 == 0) begin                 //// if no one is grabbing, go in freefall
      fallcount <= fallcount+1;
		
      nscreenx <= screenx + ((screenx - prevposx1));                           //// continue on x velocity path
      nscreeny <= screeny + ((screeny - prevposy1))+ (fallcount ==0);        /// decriment y velocity once every other frame
    end


    else if ((anchorhand == 0)&&delay2grab1)  begin
      nscreenx <= holdscreenx - (delay2handx1-holdx);                    //// if anchorhand + grab, set newscreen so that hand will still overlap hold
      nscreeny <= holdscreeny - (delay2handy1-holdy);
    end

    else if ((anchorhand == 1)&&delay2grab2)  begin
      nscreenx <= holdscreenx - (userhand2x-holdx);
      nscreeny <= holdscreeny - (userhand2y-holdy);                       ///// same for hand 2
    end

    else begin
      nscreenx <= screenx;                                               //// update screen position 
      nscreeny <= screeny;
    end 

  end
  
  always@(*) begin
  	 
	 
    if (reset ==1) {screenx, screeny} <= {12'b0, 13'b0};                  //// reset screen position when necessary

	 else if (screeny <= -2000)begin
	 
	   screenx<= screenx;                             //// if reached top of map, stop movement
		screeny<= screeny;
	end
	 
	 else if (nscreeny[12] ==1 ) begin
		screenx<= nscreenx;                        ///// only allow movement if newscreen is above the ground level
		screeny<= nscreeny;
	 end
	 else begin
	   screenx<= screenx;               //// do not allow going below the ground
		screeny<= 0;
	 end
  end
  
  

endmodule







