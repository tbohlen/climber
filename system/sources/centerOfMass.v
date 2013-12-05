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
                    input [9:0] x, y, input [1:0] colorSelect,
                    output [9:0] xCenter, output [9:0] yCenter);

    // current x*color total
    // current y*color total
    // current color total
    // 32 bits so that a screen that is all the color of interest will
    // not overflow.
    reg [31:0] xColorTotal, yColorTotal;
    reg [25:0] colorTotal;

    // dividers for finding x and y results
    reg [31:0] xTop, yTop;
    reg [25:0] xBottom, yBottom;
    wire [31:0] xQuotient, yQuotient, xRemainder, yRemainder;

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
		.dividend(s_top),
		.divisor(s_bottom),
		.quotient(s_quotient),
	        // note: the "fractional" output was originally named "remainder" in this
		// file -- it seems coregen will name this output "fractional" even if
		// you didn't select the remainder type as fractional.
		.fractional(s_remainder),
		.rfd(yRFD)
		);

    // connect outputs
    assign xCenter = xQuotient[9:0];
    assign yCenter = yQuotient[9:0];

    // calculate masses and increment xColor, yColor, and color
    // downsample color by 1 order of magnitude
    wire [4:0] color = (colorSelect == 2'd0) ? pixel[17:13] :
                       (colorSelect == 2'd1) ? pixel[11:7] : pixel[5:1];
    wire [14:0] xColor = color * x;
    wire [14:0] yColor = color * y;
    always @(posedge clk) begin
        if (reset) begin
            // reset all values
            xColorTotal <= 0;
            yColorTotal <= 0;
            colorTotal <= 0;
        end
        else begin
            xColorTotal <= xColorTotal + xColor;
            yColorTotal <= yColorTotal + yColor;
            colorTotal <= colorTotal + color;

            // if this is the first pixel of the next frame calculate centers,
            // output them, and clear values
            if (x == 0 && y == 0) begin
                xTop <= xColorTotal;
                yTop <= yColorTotal;
                xBottom <= xColor;
                yBottom <= yBottom;
                xColorTotal <= 0;
                yColorTotal <= 0;
                colorTotal <= 0;
            end
        end
    end
endmodule
