module handholds (
  input clockin, 
  input [68:0] infoin,
  input signed [12:0]  screeny,
  input signed [11:0] screenx,

  output reg [68:0] infout,
  output reg exists,
  output clockout

  );

  wire reset;
  wire vclock;
  wire [10:0] hcount;
  wire [9:0]  vcount;
  wire hsync,vsync,blank;
  wire [10:0] userhand1x;
  wire [9:0]  userhand1y;
  wire [10:0] userhand2x;
  wire [9:0] userhand2y;
  wire usergrab1;
  wire usergrab2;


  assign {reset, hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;
  assign vclock = clockin;
  always @(posedge vclock) infout <= infoin;
  assign clockout = clockin;
  
  wire exists1;
  wire exists2;
  wire exists3;
  wire exists4;
  wire exists5;
  wire exists6;
  wire exists7;
  wire exists8;
  wire exists9;
  wire exists10;
  wire exists11;
  wire exists12;
  wire exists13;
  wire exists14;
  wire exists15;

  wire signed [11:0] x1;
  wire signed [11:0] x2;
  wire signed [11:0] x3;
  wire signed [11:0] x4;
  wire signed [11:0] x5;
  wire signed [11:0] x6;
  wire signed [11:0] x7;
  wire signed [11:0] x8;
  wire signed [11:0] x9;
  wire signed [11:0] x10;
  wire signed [11:0] x11;
  wire signed [11:0] x12;
  wire signed [11:0] x13;
  wire signed [11:0] x14;
  wire signed [11:0] x15;

  wire signed [12:0] y1;
  wire signed [12:0] y2;
  wire signed [12:0] y3;
  wire signed [12:0] y4;
  wire signed [12:0] y5;
  wire signed [12:0] y6;
  wire signed [12:0] y7;
  wire signed [12:0] y8;
  wire signed [12:0] y9;
  wire signed [12:0] y10;
  wire signed [12:0] y11;
  wire signed [12:0] y12;
  wire signed [12:0] y13;
  wire signed [12:0] y14;
  wire signed [12:0] y15;


  assign x1 = 150;
  assign x2 = 800;
  assign x3 = 680;
  assign x4 = 300;
  assign x5 = 700;
  assign x6 = 450;
  assign x7 = 600;
  assign x8 = 640;
  assign x9 = 300;
  assign x10 = 250;
  assign x11 = 375;
  assign x12 = 500;
  assign x13 = 530;
  assign x14 = 580;
  assign x15 = 650;

  assign y1 = 50;
  assign y2 = 50;
  assign y3 = 400;
  assign y4 = 600;
  assign y5 = -100;
  assign y6 = -550;
  assign y7 = -450;
  assign y8 = -200;
  assign y9 = -1000;
  assign y10 = -2000;
  assign y11 = -1500;
  assign y12 = -1200;
  assign y13 = -1400;
  assign y14 = -1600;
  assign y15 = -700; 

  hold hold1(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x1), .y(y1), .screeny(screeny),.screenx(screenx), .exists(exists1));
  hold hold2(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x2), .y(y2), .screeny(screeny),.screenx(screenx), .exists(exists2));
  hold hold3(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x3), .y(y3), .screeny(screeny),.screenx(screenx), .exists(exists3));
  hold hold4(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x4), .y(y4), .screeny(screeny),.screenx(screenx), .exists(exists4));
  hold hold5(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x5), .y(y5), .screeny(screeny),.screenx(screenx), .exists(exists5));
  hold hold6(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x6), .y(y6), .screeny(screeny),.screenx(screenx), .exists(exists6));
  hold hold7(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x7), .y(y7), .screeny(screeny),.screenx(screenx), .exists(exists7));
  hold hold8(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x8), .y(y8), .screeny(screeny),.screenx(screenx), .exists(exists8));
  hold hold9(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x9), .y(y9), .screeny(screeny),.screenx(screenx), .exists(exists9));
  hold hold10(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x10), .y(y10), .screeny(screeny),.screenx(screenx), .exists(exists10));
  hold hold11(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x11), .y(y11), .screeny(screeny),.screenx(screenx), .exists(exists11));
  hold hold12(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x12), .y(y12), .screeny(screeny),.screenx(screenx), .exists(exists12));
  hold hold13(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x13), .y(y13), .screeny(screeny),.screenx(screenx), .exists(exists13));
  hold hold14(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x14), .y(y14), .screeny(screeny),.screenx(screenx), .exists(exists14));
  hold hold15(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x15), .y(y15), .screeny(screeny),.screenx(screenx), .exists(exists15));
	
	
	always @ (posedge vclock) begin
		if (exists1 || exists2 || exists3 || exists4 ||exists5||exists6 || exists7 || exists8 || exists9 ||exists10||exists11 || exists12 || exists13 || exists14 ||exists15) exists <= 1;
		else exists <=0;
  end

endmodule
