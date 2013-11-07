//
// File:   ntsc2zbt.v
// Date:   27-Nov-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Example for MIT 6.111 labkit showing how to prepare NTSC data
// (from Javier's decoder) to be loaded into the ZBT RAM for video
// display.
//
// The ZBT memory is 36 bits wide; we only use 32 bits of this, to
// store 4 bytes of black-and-white intensity data from the NTSC
// video input.
//
// Bug fix: Jonathan P. Mailoa <jpmailoa@mit.edu>
// Date   : 11-May-09  // gph mod 11/3/2011
//
//
// Bug due to memory management will be fixed. It happens because
// -. Fix the memory addressing in this module (neat addressing protocol)
//    and do memory forecast in vram_display module.
// -. Do nothing in this module and do memory forecast in vram_display
//    module (different forecast count) while cutting off reading from
//    address(0,0,0).
//
// Bug in this module causes 4 pixel on the rightmost side of the camera
// to be stored in the address that belongs to the leftmost side of the
// screen.
//
// In this example, the second method is used. NOTICE will be provided
// on the crucial source of the bug.
//
// Inputs:
//
// clk - system clock
// vclk - video camera clock (tv_in_line_clock1 from 6.111 labkit)
// fvh - three bits giving field, vertical, and horizontal sync signals
// dataValid - dataValid signal from ntsc_decode module
// dataIn - the video data input
// switch - switch to choose between two modes (for debugging) (unclear on modes)
//
// Outputs:
//
// ntsc_addr - the address of ZBT memory in which to store the data
// ntsc_data - the data to store at the given address
// ntsc_we - writeEnabled signal telling system that data is ready to write
//
/////////////////////////////////////////////////////////////////////////////
// Prepare data and address values to fill ZBT memory with NTSC data

module ntsc_to_zbt(clk, vclk, fvh, dataValid, dataIn, ntsc_addr, ntsc_data, ntsc_we, switch);

    input clk;	// system clock
    input vclk;	// video clock from camera
    input [2:0] fvh;
    input dataValid;
    input [7:0] dataIn;
    output [18:0] ntsc_addr;
    output [35:0] ntsc_data;
    output ntsc_we;	// write enable for NTSC data
    input switch;		// switch which determines mode (for debugging)

    parameter COL_START = 10'd30;
    parameter ROW_START = 10'd30;

    // here put the luminance data from the ntsc decoder into the ram
    // this is for 1024 * 786 XGA display

    reg [9:0] col = 0;
    reg [9:0] row = 0;
    reg [7:0] vdata = 0;
    reg vwe; // write enable signal that also checks dataValid
    reg oldDataValid;
    reg old_frame;	// frames are even / odd interlaced
    reg even_odd;	// decode interlaced frame to this wire

    wire frame = fvh[2];
    wire frame_edge = frame & ~old_frame;

    always @ (posedge vclk) //LLC1 is reference
    begin
        oldDataValid <= dataValid;
        vwe <= dataValid && !fvh[2] & ~oldDataValid; // if dataValid just flipped up and the field signal is 0, write data
        old_frame <= frame;
        even_odd = frame_edge ? ~even_odd : even_odd;

        if (!fvh[2])
        begin
            col <= fvh[0] ? COL_START :
                (!fvh[2] && !fvh[1] && dataValid && (col < 1024)) ? col + 1 : col;
            row <= fvh[1] ? ROW_START :
                (!fvh[2] && fvh[0] && (row < 768)) ? row + 1 : row;
            vdata <= (dataValid && !fvh[2]) ? dataIn : vdata;
        end
    end

    // synchronize with system clock by putting everything through a couple
    // registers

    reg [9:0] x[1:0],y[1:0]; // synced row and col
    reg [7:0] data[1:0]; // synced vdata
    reg we[1:0]; // synced vwe
    reg eo[1:0]; // synced even_odd

    always @(posedge clk)
    begin
        {x[1],x[0]} <= {x[0],col};
        {y[1],y[0]} <= {y[0],row};
        {data[1],data[0]} <= {data[0],vdata};
        {we[1],we[0]} <= {we[0],vwe};
        {eo[1],eo[0]} <= {eo[0],even_odd};
    end

    // edge detection on write enable signal

    reg old_we;
    wire we_edge = we[1] & ~old_we; // pulses on edge of write enable signal
    always @(posedge clk)
    begin
        old_we <= we[1];
    end

    // shift each set of four bytes into a large register for the ZBT

   reg [31:0] mydata;
   always @(posedge clk) begin
       // shift data if new, writable data has come through
       if (we_edge) begin
           mydata <= { mydata[23:0], data[1] };
       end
   end

   // NOTICE : Here we have put 4 pixel delay on mydata. For example, when:
   // (x[1], y[1]) = (60, 80) and eo[1] = 0, then:
   // mydata[31:0] = ( pixel(56,160), pixel(57,160), pixel(58,160), pixel(59,160) )
   // This is the root of the original addressing bug.


   // NOTICE : Notice that we have decided to store mydata, which
   //          contains pixel(56,160) to pixel(59,160) in address
   //          (0, 160 (10 bits), 60 >> 2 = 15 (8 bits)).
   //
   //          This protocol is dangerous, because it means
   //          pixel(0,0) to pixel(3,0) is NOT stored in address
   //          (0, 0 (10 bits), 0 (8 bits)) but is rather stored
   //          in address (0, 0 (10 bits), 4 >> 2 = 1 (8 bits)). This
   //          calculation ignores COL_START & ROW_START.
   //
   //          4 pixels from the right side of the camera input will
   //          be stored in address corresponding to x = 0.
   //
   //          To fix, delay col & row by 4 clock cycles.
   //          Delay other signals as well.

   reg [39:0] x_delay;
   reg [39:0] y_delay;
   reg [3:0] we_delay;
   reg [3:0] eo_delay;

   always @ (posedge clk) begin
       // delay all signals by shifting them through regs
       x_delay <= {x_delay[29:0], x[1]};
       y_delay <= {y_delay[29:0], y[1]};
       we_delay <= {we_delay[2:0], we[1]};
       eo_delay <= {eo_delay[2:0], eo[1]};
   end

   // compute address to store data in
   wire [8:0] y_addr = y_delay[38:30];
   wire [9:0] x_addr = x_delay[39:30];

   wire [18:0] myaddr = {1'b0, y_addr[8:0], eo_delay[3], x_addr[9:2]};

   // Now address (0,0,0) contains pixel data(0,0) etc.


   // alternate (256x192) image data and address
   wire [31:0] mydata2 = {data[1],data[1],data[1],data[1]};
   wire [18:0] myaddr2 = {1'b0, y_addr[8:0], eo_delay[3], x_addr[7:0]};

   // update the output address and data only when four bytes ready

   reg [18:0] ntsc_addr;
   reg [35:0] ntsc_data;
   wire ntsc_we = switch ? we_edge : (we_edge & (x_delay[31:30]==2'b00));

   always @(posedge clk) begin
       if ( ntsc_we ) begin
           ntsc_addr <= switch ? myaddr2 : myaddr;	// normal and expanded modes
           ntsc_data <= switch ? {4'b0,mydata2} : {4'b0,mydata};
       end
   end

endmodule // ntsc_to_zbt
