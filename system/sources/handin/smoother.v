// 
// File: smoother.v
// Date: 12/7/2013
// Author: Turner Bohlen <turnerbohlen@gmail.com>
//
// Averages the last four x and y values and averages them to create the
// outputs, effectively implementing a low-pass filter.

module smoother( input clk, input reset, input [9:0] x, input [9:0] y, output [9:0] smoothedX, output [9:0] smoothedY);
    reg[39:0] xDelay, yDelay;

    wire [11:0] sumX = xDelay[9:0] + xDelay[19:10] + xDelay[29:20] + xDelay[39:30];
    wire [11:0] sumY = yDelay[9:0] + yDelay[19:10] + yDelay[29:20] + yDelay[39:30];
    assign smoothedX = sumX >> 2;
    assign smoothedY = sumY >> 2;

    always @(posedge clk) begin
        // make sure we are only taking valid new positions
        if (x != xDelay[9:0]) xDelay <= {xDelay[29:0], x};
        if (y != yDelay[9:0]) yDelay <= {yDelay[29:0], y};
    end

endmodule
