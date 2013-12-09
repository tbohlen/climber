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


  reg anchorhand;

  reg delaygrab1;
  reg delaygrab2;
  reg grab1pulse;
  reg grab2pulse;
  
  reg delay2grab1;
  reg delay2grab2;
  
  reg [10:0]delay1handx1;
  reg [9:0]delay1handy1;
  reg [10:0]delay2handx1;
  reg [9:0]delay2handy1;
  
  

  reg [10:0] holdx;
  reg  [9:0] holdy;
  reg signed [11:0] holdscreenx;
  reg signed [12:0] holdscreeny;


  reg signed [12-1:0] prevposx1;
  reg signed [13-1:0] prevposy1;
  reg signed [12-1:0] prevposx2;
  reg signed [13-1:0] prevposy2;
  reg signed [12-1:0] prevposx3;
  reg signed [13-1:0] prevposy3;
  reg signed [12-1:0] prevposx4;
  reg signed [13-1:0] prevposy4;

  reg signed  [11:0] nscreenx;
  reg signed  [12:0] nscreeny;

 
  assign {reset,  hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;


  always @(posedge vsync) begin

    delaygrab1 <= usergrab1;
    delaygrab2 <= usergrab2;
    grab1pulse <= usergrab1 && ~ delaygrab1;
    grab2pulse <= usergrab2 && ~ delaygrab2;
	 
	 delay2grab1 <= delaygrab1;	 
	 delay2grab2 <= delaygrab2;
	 
	 
	 delay1handx1<=userhand1x;
	 delay2handx1<=delay1handx1;
	 delay1handy1<=userhand1y;
	 delay2handy1<=delay1handy1;

    prevposx4 <= prevposx3;
    prevposx3 <= prevposx2;
    prevposx2 <= prevposx1;
    prevposx1 <= screenx;
    prevposy4 <= prevposy3;
    prevposy3 <= prevposy2;
    prevposy2 <= prevposy1;
    prevposy1 <= screeny;



    if (grab1pulse || (anchorhand ==1 && usergrab2 == 0 && usergrab1 == 1)) begin
      anchorhand <= 0;
      holdx <= userhand1x;
      holdy <= userhand1y;
      holdscreenx <= screenx;
      holdscreeny <= screeny;
	 end
	 
    else if (grab2pulse || (anchorhand ==0 && usergrab1 == 0 && usergrab2 == 1)) begin 
      anchorhand <= 1;
      holdx <= userhand2x;
      holdy <= userhand2y;
      holdscreenx <= screenx;
      holdscreeny <= screeny;
	end

    else begin 
      anchorhand <= anchorhand;
      holdx <= holdx;
      holdy <= holdy;
      holdscreenx <= holdscreenx;
      holdscreeny <= holdscreeny;
		end


	 if (usergrab1 == 0 && usergrab2 == 0) begin
      nscreenx <= screenx + ((screenx - prevposx1));
      nscreeny <= screeny + ((screeny - prevposy1))+1;
    end

    else if ((anchorhand == 0)&&delay2grab1)  begin
      nscreenx <= holdscreenx - (delay2handx1-holdx);
      nscreeny <= holdscreeny - (delay2handy1-holdy);
    end

    else if ((anchorhand == 1)&&delay2grab2)  begin
      nscreenx <= holdscreenx - (userhand2x-holdx);
      nscreeny <= holdscreeny - (userhand2y-holdy);
    end

    else begin
      nscreenx <= screenx;
      nscreeny <= screeny;
    end 

  end
  
  always@(*) begin
  	 
	 
    if (reset ==1) {screenx, screeny} <= {12'b0, 13'b0};
	 else if (switch==1) begin
		screenx <= screenxin;
		screeny <= screenyin;
	 end
	 else if (nscreeny[12] ==1 ) begin
		screenx<= nscreenx;
		screeny<= nscreeny;
	 end
	 else begin
	   screenx<= nscreenx;
		screeny<= 0;
	 end
  end
  
  

endmodule







