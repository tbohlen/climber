//
// File: flexReader.v
// Date: 12/4/2013
// Author: Turner Bohlen
//
// Reads the input form an analog circuit and outputs whether or not the person
// is grabbing.
//

module flexReader(input clk, input reset, input pinIn, output grabbing);
    wire cleanIn;
    // debounce and sync with clock
    debounce dbIn(.reset(reset), .clk(clk), .noisy(pinIn), .clean(cleanIn));
    // the input is high when the flex sensor is straight. We want the opposite.
    assign grabbing = ~cleanIn;
endmodule
