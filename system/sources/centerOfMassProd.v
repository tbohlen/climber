// This module calculates the center of mass of a certain hue on the screen.
// Parameters allowing for flexibility in the hue detected are provided in-file.
// The first version of this is naive, and only considers a single pixel at
// a time. Later versions aim to check areas of pixels and weight them
// accordingly.
//
// Creates its own internal address based on where it is with its frames.
//
// Will output the result from the last frame for the duration of the subsequent
// frame.
//
// We are making the assumption that the divider will always be ready for data
// when we send data. This is safe thanks to the huge delay between devisions
// (divisions occur at only 30hz).
//
// colorSelect = 0 : red
// colorSelect = 1 : green
// colorSelect = 2 : blue
//
module centerOfMass(input clk, input reset, input [17:0] pixel,
                    input [10:0] x, input [9:0] y, input [1:0] colorSelect,
                    output [9:0] xCenter, output [9:0] yCenter);

    parameter MIN_MAIN_COLOR = 5'b01_11_1;
    parameter COLOR_DIFFERENCE = 5'b00_10_0;

    // current x*color total
    // current y*color total
    // current color total
    // 32 bits so that a screen that is all the color of interest will
    // not overflow.
    // total and xBottom and yBottom only need 26 bits (actually fewer
    // still)
    reg [28:0] xTotal, yTotal;
	 reg [19:0] total;

    // dividers for finding x and y results
    reg [28:0] xTop, yTop;
    reg [19:0] xBottom, yBottom;
    wire [28:0] xQuotient, yQuotient, xRemainder, yRemainder;
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
        .clk(clock),
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

    // calculate masses and increment xColor, yColor, and color
    // downsample color by 1 order of magnitude
    wire [4:0] color0 = pixel[17:13];
    wire [4:0] color1 = pixel[11:7];
    wire [4:0] color2 = pixel[5:1];

    wire [4:0] mainColor = (colorSelect == 2'd0) ? color0 : ((colorSelect == 2'd1) ? color1 : color2);
    wire [4:0] otherColor1 = (colorSelect == 2'd0) ? color1 : ((colorSelect == 2'd1) ? color2 : color0);
    wire [4:0] otherColor2 = (colorSelect == 2'd0) ? color2 : ((colorSelect == 2'd1) ? color0 : color1);

    wire included = mainColor > MIN_MAIN_COLOR &&
                    (otherColor1 + COLOR_DIFFERENCE) < mainColor &&
                    (otherColor2 + COLOR_DIFFERENCE) < mainColor &&
                    y < 786 && x < 1024;
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
                xTotal <= included ? x[9:0] : 0;
                yTotal <= included ? y : 0;
                total <= included;
            end
            else begin
                xTotal <= included ? xTotal + x[9:0] : xTotal;
                yTotal <= included ? yTotal + y : yTotal;
                total <= total + included;
            end
        end
    end
endmodule
