//
// File: centerOfMass.v
// Date: 11/30/2013
// Author: Turner Bohlen <turnerbohlen@gmail.com>
//
// Finds the center of mass of a certain color. A color is chosed using the
// colorSelect input.
//
// colorSelect = 0 : red
// colorSelect = 1 : green
// colorSelect = 2 : blue
//
// All pixels which contain the selected color above the stored or input
// minimum value and both other colors a certain stored or input value below
// that value are included in the calculation.
//
// All qualifying pixels' positions are averaged, and the result is output.
//
// This module also contains a parameter setting system. (TODO: move this system
// into a separate module). 8 input switches are used to input the minimum color
// (switches 7-4) and minimum color difference (switches 3-0). The 'set' and
// 'reset' buttons toggle the mode. When reset is pressed any stored values are
// discarded and the values from the switches
//
module centerOfMass(input clk, input reset, input [17:0] pixel,
                    input [10:0] x, input [9:0] y, input [1:0] colorSelect,
                    output [9:0] xCenter, output [9:0] yCenter,
                    output included, input [7:0] switches, input setButton, input resetButton, output reg set);

	 reg [22:0] total;
	 reg [31:0] xTotal, yTotal;

    // dividers for finding x and y results
    reg [31:0] xTop, yTop;
    reg [22:0] xBottom, yBottom;
    wire [31:0] xQuotient, yQuotient, xRemainder, yRemainder;
    wire xRFD, yRFD;

    comDivider xDiv(
        .clk(clk),
        .dividend(xTop),
        .divisor(xBottom),
        .quotient(xQuotient),
        .fractional(xRemainder),
        .rfd(xRFD)
        );

    comDivider yDiv(
        .clk(clk),
        .dividend(yTop),
        .divisor(yBottom),
        .quotient(yQuotient),
        .fractional(yRemainder),
        .rfd(yRFD)
        );

    // connect outputs
    // if the divisor is 0 set the output to a default (center0
    assign xCenter = (!xBottom) ? 10'd360 : xQuotient[9:0];
    assign yCenter = (!yBottom) ? 10'd240 : yQuotient[9:0];

    // set and reset the colors
    // calculate color parameters: min color and min color diff
    reg [4:0] setColorDiff = 5'd0;
    reg [4:0] setColorMin = 5'd0;
    reg oldSet, oldReset;
    wire setEdge = setButton & ~oldSet;
    wire resetEdge = resetButton & ~oldReset;

    always @(posedge clk) begin
        oldSet <= setButton;
        oldReset <= resetButton;
        if (setEdge) begin
            set <= 1;
            setColorDiff <= {switches[3:0], 1'b1};
            setColorMin <= {switches[7:4], 1'b1};
        end
        if (resetEdge) set <= 0;
    end

    wire [4:0] colorDiff = set ? setColorDiff : {switches[3:0], 1'b1};
    wire [4:0] colorMin = set ? setColorMin : {switches[7:4], 1'b1};

    // calculate masses and increment xColor, yColor, and color
    // downsample color by 1 order of magnitude
    wire [4:0] color0 = pixel[17:13];
    wire [4:0] color1 = pixel[11:7];
    wire [4:0] color2 = pixel[5:1];

    wire [4:0] mainColor = (colorSelect == 2'd0) ? color0 : ((colorSelect == 2'd1) ? color1 : color2);
    wire [4:0] otherColor1 = (colorSelect == 2'd0) ? color1 : ((colorSelect == 2'd1) ? color2 : color0);
    wire [4:0] otherColor2 = (colorSelect == 2'd0) ? color2 : ((colorSelect == 2'd1) ? color0 : color1);

    assign included = mainColor > colorMin &&
                    (otherColor1 < mainColor) &&
                    (mainColor - otherColor1 > colorDiff) &&
                    (otherColor2 < mainColor) &&
                    (mainColor - otherColor2 > colorDiff) &&
                    valid;

     // check to make sure this is a valid pixel
     wire valid = y < 786 && x < 1024;

     // delay the input signals so that we can do a better calculation
     reg [32:0] xDelay;
     reg [29:0] yDelay;
     reg [2:0] includeDelay;

     always @(posedge clk) begin
         if (valid) begin
             xDelay <= {xDelay[21:0], x};
             yDelay <= {yDelay[19:0], y};
             includeDelay <= {includeDelay[2:0], included};
         end
     end

     // calculate weighting
     wire [2:0] weight = (& includeDelay) ? 4 : ((~| includeDelay) ? 1 : 2);
     wire [12:0] xValue = weight * x;
     wire [12:0] yValue = weight * y;

    always @(posedge clk) begin
        if (reset) begin
            // reset all values
            xTotal <= 0;
            yTotal <= 0;
            total <= 0;
        end
        else begin
            // if this is the first pixel of the next frame calculate centers,
            // output them, and clear values
            if (x == 0 && y == 0) begin
                xTop <= xTotal;
                yTop <= yTotal;
                xBottom <= total;
                yBottom <= total;
                xTotal <= included ? {19'd0, xValue} : 32'd0;
                yTotal <= included ? {19'd0, yValue} : 32'd0;
                total <= included ? {20'd0, weight} : 23'd0;
            end
            else begin
                xTotal <= included ? xTotal + {19'd0, xValue} : xTotal;
                yTotal <= included ? yTotal + {19'd0, yValue} : yTotal;
                total <= included ? total + {20'd0, weight} : total;
            end
        end
    end
endmodule
