module grab 
  (
  input clockin,
  input existsin,
  input [68:0] infoin,
  
  output reg existsout,
  
  output reg [68:0] infout,
  output clockout
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

  assign {reset,hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;
  assign vclock = clockin;
 
  always @(posedge vclock)begin  infout[68:2] <= infoindelay[68:2];  infoindelay<= infoin[68:2];end
  assign clockout = clockin;


  always@(posedge vclock) existsout <= existsin;

  reg nextgrab1;
  reg nextgrab2;

  always @(posedge vclock) begin
	     if ((infout[0] ==1)&& (usergrab1 ==1))
		     nextgrab1 <= 1;
		  

        else if ((existsin == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150))
          nextgrab1 <=1;
        else if (hcount==0 && vcount==0)
          nextgrab1 <=0;
        else 
          nextgrab1 <= nextgrab1;
			

		
	     if ((infout[1] ==1)&& (usergrab2 ==1))
		     nextgrab2 <= 1;
		  else if ((existsin == 1 && usergrab2 ==1) &&(((hcount-userhand2x)*(hcount-userhand2x)+(vcount-userhand2y)*(vcount-userhand2y)) < 150))
          nextgrab2 <=1;
        else if (hcount==0 && vcount==0)
          nextgrab2 <=0;
        else
          nextgrab2 <= nextgrab2;
  end

  always @(posedge vsync) begin

    infout[0] <= nextgrab1;
	 infout[1] <= nextgrab2;
	end

endmodule
