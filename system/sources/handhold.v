module hold
    #(parameter width =64, height = 24)
    (
        input [10:0] hcount,
        input [9:0]  vcount,
        input clock,

        input signed [11:0] x,
        input signed [12:0] y,  /// make sure that it is signed and correct bits (it is)

        input signed [11:0] screenx,
        input signed [12:0] screeny,

        output reg exists
    );



    always @(*) begin
        if (((hcount+screenx) >= x && (hcount+screenx) < (x+width)) &&  ((vcount+screeny) >= y && (vcount+screeny) < (y+height)))  // simple blob  module, outputs exist if a hold exists at each pixel
            exists = 1;
        else
            exists = 0;
    end

endmodule                                           //// blocking assignemts are used to avoid additional clock cycles, clock times still met
