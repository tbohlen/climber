module hold
  #(parameter width =32, height = 8)
  (
  input [10:0] hcount,	
  input [9:0]  vcount, 
  input clock,

  input [12:0] x,
  input [12:0] y,

  input [12:0] screenx,
  input [12:0] screeny,

	output reg exists
  );


	reg axis;
	

	always @(*) begin
      if (((hcount+screenx) >= x && (hcount+screenx) < (x+width)) &&  ((vcount+screeny) >= y && (vcount+screeny) < (y+height)))
        exists = 1;
      else
        exists = 0;
   end

endmodule
