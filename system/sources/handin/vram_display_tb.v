`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:24:34 12/04/2013
// Design Name:   vram_display
// Module Name:   /afs/athena.mit.edu/user/other/t_bohlen/projects/climber/system/sources/vram_display_tb.v
// Project Name:  climber
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vram_display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vram_display_tb;

	// Inputs
	reg reset;
	reg clk;
	reg [10:0] hcount;
	reg [9:0] vcount;
	reg [35:0] vram_read_data;

	// Outputs
	wire [17:0] vr_pixel;
	wire [18:0] vram_addr;

	// Instantiate the Unit Under Test (UUT)
	vram_display uut (
		.reset(reset), 
		.clk(clk), 
		.hcount(hcount), 
		.vcount(vcount), 
		.vr_pixel(vr_pixel), 
		.vram_addr(vram_addr), 
		.vram_read_data(vram_read_data)
	);

	initial begin
		// Initialize Inputs
		reset = 0;
		clk = 0;
		hcount = 0;
		vcount = 0;
		vram_read_data = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here

        // first values
        vram_read_data = 36'b111111_000000_111111_000000_111111_000000;
        hcount = 0;
        vcount = 0;

        // clock it in round 1
        clk = 1;
        #5;
        clk = 0;
        #5;

        hcount = 1;
        vcount = 0;

        // clock it in round 2
        clk = 1;
        #5;
        clk = 0;
        #5;

        // second values
        vram_read_data = 36'b100000__010000_001000_000100_000010_000001;
        hcount = 2;
        vcount = 0;

        // clock it in round 1
        clk = 1;
        #5;
        clk = 0;
        #5;

        hcount = 3;
        vcount = 0;

        // clock it in round 2
        clk = 1;
        #5;
        clk = 0;
        #5;

        // at this point we should have one set of values in last_vr_data and
        // one in next_vr_data
        // starting immediately, it should be outputting 18 bits

        hcount = 4;
        vcount = 0;
        vram_read_data = 36'd0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 10
        // data should be 111111_000000_111111

        hcount = 5;
        vcount = 0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 11
        // data should be 000000_111111_000000

        hcount = 6;
        vcount = 0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 12
        // data should be 100000_010000_001000

        hcount = 7;
        vcount = 0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 12
        // data should be 000100_000010_000001



        // now lets test to see if it can handle the end of a line

        // first values
        vram_read_data = 36'b111111_000000_111111_000000_111111_000000;
        hcount = 1042;
        vcount = 0;

        // clock it in round 1
        clk = 1;
        #5;
        clk = 0;
        #5;

        hcount = 1043;
        vcount = 0;

        // clock it in round 2
        clk = 1;
        #5;
        clk = 0;
        #5;

        // second values
        vram_read_data = 36'b100000__010000_001000_000100_000010_000001;
        hcount = 1044;
        vcount = 0;

        // clock it in round 1
        clk = 1;
        #5;
        clk = 0;
        #5;

        hcount = 1045;
        vcount = 0;

        // clock it in round 2
        clk = 1;
        #5;
        clk = 0;
        #5;

        // at this point we should have one set of values in last_vr_data and
        // one in next_vr_data
        // starting immediately, it should be outputting 18 bits

        hcount = 1046;
        vcount = 0;
        vram_read_data = 36'd0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = ?? , h = ??
        // data should be 111111_000000_111111

        hcount = 1047;
        vcount = 0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 11
        // data should be 000000_111111_000000

        hcount = 1048;
        vcount = 0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 12
        // data should be 100000_010000_001000

        hcount = 0;
        vcount = 1;

        clk = 1;
        #5;
        clk = 0;
        #5;

        // vram_addr should be v = 0 , h = 12
        // data should be 000100_000010_000001

	end
      
endmodule

