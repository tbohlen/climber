//
// File: centerOfMass.v
// Date Created: 12/3/2013
// Author: Turner Bohlen <turnerbohlen@gmail.com
//
// ramReader works as a timing mechanism for the ram, outputting the address to
// be read and the x and y values that should be readable right now.

module ramReader(input clk, input reset, input [35:0] vramData,
                 output [17:0] pixel, output [19:0] vramAddr,
                 output reg [9:0] x, output reg [9:0] y);

    // next x and y coordinates to add to the calculation and the x and
    // y coordinates forecast 6 cycles in the future
    wire [9:0] xForecast, yForcast;

    // the vram address should be pulling the value needed in 6 cycles
    assign xForcast = x + 6; // this will wrap just fine!
    assign yForcast = (x >= 1015) ? (y == 767) ? 0 : y + 1) : y;
    assign vramAddr = {1'b0, yForcast, xForcast[9:1]};

    // latch the data coming in to make sure you are accessing what you mean to
    // be and letting the ram catch up
    wire hc2 = x[0];
    reg [35:0] currentVrData, nextVrData;

    always @(posedge clk) begin
        // right before data will be needed, load it into last_vr_data
        currentVrData = (hc2==1'b1) ? nextVrData : currentVrData;
        // 3 cycles after it was first requested, 2 cycles after it was last
        // requested, and 3 cycles before it will be needed, save the new data
        nextVrData = (hc2==1'b1) ? vramData : nextVrData;
    end

    // calculate masses and increment xColor, yColor, and color
    wire [17:0] pixel = (hc2) ? currentVrData[17:0] : currentVrData[35:18];
    always @(posedge clk) begin
        if (reset) begin
            // reset all values
            x <= 0;
            y <= 0;
        end
        else begin
            // increment x and y, color totals
            x <= x + 1;
            y <= (y == 768) ? 0 : y + 1;
        end
    end
endmodule

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
    // all given 35 bits so that a screen that is all the color of interest will
    // not overflow.
    reg [34:0] xColorTotal, yColorTotal
    reg [25:0] colorTotal;

    // dividers for finding x and y results
    reg [34:0] xTop, yTop;
    reg [25:0] xBottom, yBottom;
    wire [35:0] xQuotient, yQuotient, xRemainder, yRemainder;

    divider xDiv(
		.clk(clk),
		.dividend(xTop),
		.divisor(xBottom),
		.quotient(xQuotient),
		.fractional(xRemainder),
		.rfd(xRFD)
		);
    divider yDiv(
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
    wire [5:0] color = (colorSelect == 2'd0) ? pixel[17:12] :
                       (colorSelect == 2'd1) ? pixel[11:6] : pixel[5:0];
    wire [15:0] xColor = color * x;
    wire [15:0] yColor = color * y;
    always @(posedge clk) begin
        if (reset) begin
            // reset all values
            xColor <= 0;
            yColor <= 0;
            color <= 0;
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
