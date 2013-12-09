module hold
  #(parameter width =48, height = 20)
  (
  input clock,
  input [10:0] hcount,	
  input [9:0]  vcount, 

  input signed [10:0] x,
  input signed [11:0] y,

  input signed[11:0]  screenx,
  input signed[12:0]  screeny,

	output reg exists
  );


	
	always @(*) begin
		if (((hcount+screenx) >= x && (hcount+screenx) < (x+width)) && ((vcount+screeny) >= y && (vcount+screeny) < (y+height)))
			exists = 1;
      else 
			exists = 0;
		end

endmodule

