//
// File: motorDriver.v
// Date: 12/3/2013
// Author: Turner Bohlen
//
// Takes in a single bit. If the bit is 1, outputs 1. If it is 0, outputs 0.
// This will be modified to be more sophisticated later on
//

module motorDriver(input motorState, output drive);
    assign drive = motorState;
endmodule