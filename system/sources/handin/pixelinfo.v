module pixelinfo#(parameter width =48, height = 20)
(
	input clockin,
  input [68:0] infoin,
  input exists,
  input signed [12:0] screeny,
  input signed [11:0] screenx,


  output reg [23:0] pixel,
	output pclock,
	output reg  pvsync,
	output reg phsync,
	output reg pblank
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

  assign {reset, clock_65mhz, hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;     /// assign inputs
  assign vclock = clockin;
  always @(posedge vclock) {pvsync,phsync,pblank} <= {vsync,hsync,blank};        //// pipeline output h,vsync, and blank 
  assign pclock = clockin;                                                        //// pipeline clock
  


	reg [5:0]border;
	reg finalborder;          //// inittially holds had borders, this was removed becuase it was not able to be implimented cleanly
	reg [12:0]multiplier;
	reg [20:0] r;
	reg [20:0] g;
	reg [20:0] b;
	integer i;


  always @(*) begin
		
		
		if (((-1* screeny +(768-vcount))<(2**11)))
			multiplier = (-1* screeny +(768-vcount));            //// gradient calculations for each horrizontal stripe in the background
		else
			multiplier = 2**11;
		
		
		
		r = ('hAA*multiplier>>>11);
		g = ('h88*multiplier>>>11);              /// multiply the pixel by the multiplier, then shift, creates gradient
		b = ('h33*multiplier>>>11);
   end

   always  @ (posedge vclock) begin

	
      if       (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)  //right hand
         if (usergrab1)
            pixel <= 24'hFF_FF_00;
         else 
            pixel <=24'h00_FF_00;

      else if  (((hcount-userhand2x)*(hcount-userhand2x)+(vcount-userhand2y)*(vcount-userhand2y)) < 150) // left hand
         if (usergrab2)
            pixel <= 24'hFF_FF_00;
         else 
            pixel <=24'hFF_00_00;


      else if ((hcount-1024/2)*(hcount-1024/2)+(vcount-768/2)*(vcount-768/2) < 200)  //player
         pixel <=  24'hFF_FF_FF;

        else if (exists==1)                                                     //wall
         pixel <= 24'h00_FF_FF;
		else if ((vcount +screeny== -(2000 + 768/2))||(vcount +screeny== -(2000 + 768/2)-1)||(vcount+screeny == -(2000 + 768/2)+1))
		 pixel <= 24'h00_00_00;

      else begin                                                       //bg
			if ((screeny+vcount-768<=-( 2**11))||screeny + vcount >768)       //// if above gradient cuttoff, just give solid color (avoids overflow)
				pixel <=24'hAA8833;
			else 
         pixel <= { r[7:0],  g[7:0], b[7:0]};                           ///// otherwise use gradient
	   end
   end

endmodule