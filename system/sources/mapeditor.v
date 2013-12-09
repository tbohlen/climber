`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:34:13 12/07/2013 
// Design Name: 
// Module Name:    mapeditor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mapeditor(

	 
	 input [68:0] infoin,
	 input [11:0]screenxin,
	 input [12:0]screenyin,
	 input switch,
	 output reg signed [11:0] screenx,
	 output reg signed [12:0] screeny
	 
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

  
  always @(posedge vsync) begin
  	if (switch==0) screeny <= screenyin;
	else screeny<= screeny + ((userhand1y-(768/2))>>5);
	
	if (switch==0) screenx <= screenxin;
	else screenx<= screenx + ((userhand1x-(1024/2))>>5);
  end

endmodule
