//
// File:   zbt_6111_sample.v
// Date:   26-Nov-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Sample code for the MIT 6.111 labkit demonstrating use of the ZBT
// memories for video display.  Video input from the NTSC digitizer is
// displayed within an XGA 1024x768 window.  One ZBT memory (ram0) is used
// as the video frame buffer, with 8 bits used per pixel (black & white).
//
// Since the ZBT is read once for every four pixels, this frees up time for
// data to be stored to the ZBT during other pixel times.  The NTSC decoder
// runs at 27 MHz, whereas the XGA runs at 65 MHz, so we synchronize
// signals between the two (see ntsc2zbt.v) and let the NTSC data be
// stored to ZBT memory whenever it is available, during cycles when
// pixel reads are not being performed.
//
// We use a very simple ZBT interface, which does not involve any clock
// generation or hiding of the pipelining.  See zbt_6111.v for more info.
//
//
// Bug fix: Jonathan P. Mailoa <jpmailoa@mit.edu>
// Date   : 11-May-09
//
// Use ramclock module to deskew clocks;  GPH
// To change display from 1024*787 to 800*600, use clock_40mhz and change
// accordingly. Verilog ntsc2zbt.v will also need changes to change resolution.
//
// Date   : 10-Nov-11

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2013-Dec-9: Modified for use with climber game, build by Turner Bohlen and
//             Chris Lang
//
// 2011-Nov-10: Changed resolution to 1024 * 768.
//					 Added back ramclok to deskew RAM clock
//
// 2009-May-11: Fixed memory management bug by 8 clock cycle forecast.
//              Changed resolution to  800 * 600.
//              Reduced clock speed to 40MHz.
//              Disconnected zbt_6111's ram_clk signal.
//              Added ramclock to control RAM.
//              Added notes about ram1 default values.
//              Commented out clock_feedback_out assignment.
//              Removed delayN modules because ZBT's latency has no more effect.
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
//
// Modifications by Turner Bohlen <turnerbohlen@gmail.com>
//
// Enabled ram1. alternatively reads from ram1 and writes to ram0. This eases
// timing and allows for the storage of one frame and the reading of a second
// frame.
//
///////////////////////////////////////////////////////////////////////////////

module climber_color(beep, audio_reset_b,
		       ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,

	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b,

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,

	       user1, user2, user3, user4,

	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,

	       analyzer1_data, analyzer1_clock,
	       analyzer2_data, analyzer2_clock,
	       analyzer3_data, analyzer3_clock,
	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;

   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;

   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;

   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;

   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;

   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;

   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;
   input  disp_data_in;
   output  disp_data_out;

   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;

   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data,
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////

   // Audio Input and Output
   assign beep = 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
/*
*/
   // ac97_sdata_in is an input

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;

   // Video Input
   //assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b1;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b1;
   //assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = clock_27mhz;//1'b0;
   //assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2,
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs

   // SRAMs

/* change lines below to enable ZBT RAM bank0 */

/*
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_clk = 1'b0;
   assign ram0_we_b = 1'b1;
   assign ram0_cen_b = 1'b0;	// clock enable
*/

/* enable RAM pins */

   assign ram0_ce_b = 1'b0;
   assign ram0_oe_b = 1'b0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_bwe_b = 4'h0;

/**********/

   assign ram1_data = 36'hZ;
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;

   //These values has to be set to 0 like ram0 if ram1 is used.
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
/*
   //assign ram1_data = 36'hZ;
   //assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   //assign ram1_clk = 1'b0;

   //These values has to be set to 0 like ram0 if ram1 is used.
   //assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b0;
   assign ram1_oe_b = 1'b0;
   //assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'h0;
*/

   // clock_feedback_out will be assigned by ramclock
   // assign clock_feedback_out = 1'b0;  //2011-Nov-10
   // clock_feedback_in is an input

   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
/*
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
*/
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   //lab3 assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   //assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;

   ////////////////////////////////////////////////////////////////////////////
   // Demonstration of ZBT RAM as video memory

   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

//   wire clk = clock_65mhz;  // gph 2011-Nov-10

/*   ////////////////////////////////////////////////////////////////////////////
   // Demonstration of ZBT RAM as video memory

   // use FPGA's digital clock manager to produce a
   // 40MHz clock (actually 40.5MHz)
   wire clock_40mhz_unbuf,clock_40mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_40mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 2
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 3
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_40mhz),.I(clock_40mhz_unbuf));

   wire clk = clock_40mhz;
*/
	wire locked;
	//assign clock_feedback_out = 0; // gph 2011-Nov-10

   ramclock rc(.ref_clock(clock_65mhz), .fpga_clock(clk),
					.ram0_clock(ram0_clk),
					//.ram1_clock(ram1_clk),   //uncomment if ram1 is used
					.clock_feedback_in(clock_feedback_in),
					.clock_feedback_out(clock_feedback_out), .locked(locked));


   // power-on reset generation
   wire power_on_reset;    // remain high for first 16 clocks
   SRL16 reset_sr (.D(1'b0), .CLK(clk), .Q(power_on_reset),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

   // ENTER button is user reset
   wire reset,user_reset;
   debounce dbEnter(power_on_reset, clk, ~button_enter, user_reset);
   assign reset = user_reset | power_on_reset;

   // display module for debugging

   reg [63:0] dispdata;
   display_16hex hexdisp1(reset, clk, dispdata,
			  disp_blank, disp_clock, disp_rs, disp_ce_b,
			  disp_reset_b, disp_data_out);

   // generate basic XVGA video signals
   wire [10:0] hcount;
   wire [9:0]  vcount;
   wire hsync,vsync,blank;
   xvga xvga1(clk,hcount,vcount,hsync,vsync,blank);

   // wire up to ZBT ram
   wire [35:0] vram_write_data;
   wire [35:0] vram_read_data;
   wire [18:0] vram_addr;
   wire        vram_we;

   wire ram0_clk_not_used;
   zbt_6111 zbt1(clk, 1'b1, vram_we, vram_addr,
		   vram_write_data, vram_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);

   // generate pixel value from reading ZBT memory
   wire [17:0] vr_pixel;
   wire [18:0] vramReadAddr;

   vram_display vd1(reset,clk,hcount,vcount,vr_pixel,
		    vramReadAddr,vram_read_data, switch[7:5]);

    // clean up button signals for later use
    wire button3Clean, button2Clean, button1Clean, button0Clean;
    debounce db3(.reset(reset), .clk(clk), .noisy(~button3), .clean(button3Clean));
    debounce db2(.reset(reset), .clk(clk), .noisy(~button2), .clean(button2Clean));
    debounce db1(.reset(reset), .clk(clk), .noisy(~button1), .clean(button1Clean));
    debounce db0(.reset(reset), .clk(clk), .noisy(~button0), .clean(button0Clean));

    // use a button to switch between displaying red, green, and both
    // find edge of button input
    // NOTE: settings 2 and 3 both point to the same screen. Would be good to do
    // reset after 2'd2 instead of relying on looping
    wire switchColors = button0Clean;
    reg oldSwitchColors = 0;
    wire switchColorsEdge = switchColors & ~oldSwitchColors;
    reg [1:0] screenSetting = 2'b0; // 0 = green, 1 = red, 2 = both, 3 = none
    always @(posedge clk) begin
        oldSwitchColors <= switchColors;
        // on edge switch setting
        if (switchColorsEdge) screenSetting <= screenSetting + 1;
    end




    ///////////////////////////////////////////////////////////////////////////
    // Center of Mass Calculation and Configuration
    ///////////////////////////////////////////////////////////////////////////

    // set and reset buttons for configuration functionality
    wire redSetButton = button1Clean && screenSetting == 2'd1;
    wire greenSetButton = button1Clean && screenSetting == 2'd0;
    wire redResetButton = button2Clean && screenSetting == 2'd1;
    wire greenResetButton = button2Clean && screenSetting == 2'd0;

    // center of mass calculation
    wire [9:0] xCenterRed, xCenterGreen, yCenterRed, yCenterGreen, xSmoothGreen, xSmoothRed, ySmoothGreen, ySmoothRed;
	 wire redIncluded, greenIncluded;

    centerOfMass redCOM(.clk(clk), .reset(reset), .pixel(vr_pixel),
                 .x(hcount), .y(vcount), .colorSelect(2'd0), .xCenter(xCenterRed),
                 .yCenter(yCenterRed), .included(redIncluded), .switches(switch[7:0]), .setButton(redSetButton), .resetButton(redResetButton));

    centerOfMass greenCOM(.clk(clk), .reset(reset), .pixel(vr_pixel),
                 .x(hcount), .y(vcount), .colorSelect(2'd1), .xCenter(xCenterGreen),
                 .yCenter(yCenterGreen), .included(greenIncluded), .switches(switch[7:0]), .setButton(greenSetButton), .resetButton(greenResetButton));

    // smoothing to get rid of high-frequency signals in the center of mass
    // result
    smoother greenSmooth(.clk(clk), .reset(reset), .x(xCenterGreen), .y(yCenterGreen), .smoothedX(xSmoothGreen), .smoothedY(ySmoothGreen));
    smoother redSmooth(.clk(clk), .reset(reset), .x(xCenterRed), .y(yCenterRed), .smoothedX(xSmoothRed), .smoothedY(ySmoothRed));

    // draw lines to note the center of mass (for debugging, enable on the
    // configuration screens)
    wire [23:0] greenVertPixel, redVertPixel, greenHorizPixel, redHorizPixel;
    blob #(.WIDTH(4), .HEIGHT(480), .COLOR(24'hFF_30_30)) redVert(.x(xSmoothRed), .y(0), .hcount(hcount), .vcount(vcount), .pixel(redVertPixel));
    blob #(.WIDTH(720), .HEIGHT(4), .COLOR(24'hFF_30_30)) redHoriz(.x(0), .y(ySmoothRed), .hcount(hcount), .vcount(vcount), .pixel(redHorizPixel));
    blob #(.WIDTH(4), .HEIGHT(480), .COLOR(24'h30_FF_30)) greenVert(.x(xSmoothGreen), .y(0), .hcount(hcount), .vcount(vcount), .pixel(greenVertPixel));
    blob #(.WIDTH(720), .HEIGHT(4), .COLOR(24'h30_FF_30)) greenHorix(.x(0), .y(ySmoothGreen), .hcount(hcount), .vcount(vcount), .pixel(greenHorizPixel));




    // ADV7185 NTSC decoder interface code
    // adv7185 initialization module
    adv7185init adv7185(.reset(reset), .clock_27mhz(clock_27mhz),
        .source(1'b0), .tv_in_reset_b(tv_in_reset_b),
        .tv_in_i2c_clock(tv_in_i2c_clock),
        .tv_in_i2c_data(tv_in_i2c_data));

    wire [29:0] ycrcb;	// video data (luminance, chrominance)
    wire [2:0] fvh;	// sync for field, vertical, horizontal
    wire       dv;	// data valid

    ntsc_decode decode (.clk(tv_in_line_clock1), .reset(reset),
        .tv_in_ycrcb(tv_in_ycrcb[19:10]),
        .ycrcb(ycrcb), .f(fvh[2]),
        .v(fvh[1]), .h(fvh[0]), .data_valid(dv));




    ///////////////////////////////////////////////////////////////////////////
    // Pixel storage in ZBT
    ///////////////////////////////////////////////////////////////////////////

    // change to 24-bit RGB
    // this operation runs on the LLC, not the system clock
    wire [23:0] rgb;
    ycrcb2rgb ycrcbToRGB(.R(rgb[23:16]), .G(rgb[15:8]), .B(rgb[7:0]),
        .clk(tv_in_line_clock1), .Y(ycrcb[29:20]), .Cr(ycrcb[19:10]),
        .Cb(ycrcb));

    // take only the 6 most significant bits from each value (R, G, and B) in
    // order to cut down on storage
    wire [17:0] rgbDataIn = {rgb[23:18], rgb[15:10], rgb[7:2]};

    // code to write NTSC data to video memory
    // stores the data in 36-bit chunks and figures out where they should go in
    // memory
    wire [18:0] ntsc_addr;
    wire [35:0] ntsc_data;

    ntsc_to_zbt n2z (.clk(clk), .vclk(tv_in_line_clock1), .fvh(fvh),
        .dataValid(dv), .dataIn(rgbDataIn), .ntsc_addr(ntsc_addr),
        .ntsc_data(ntsc_data));




    ///////////////////////////////////////////////////////////////////////////
    // code to write pattern to ZBT memory
    // DISABLED. Always writes video to memory
    ///////////////////////////////////////////////////////////////////////////

    reg [31:0]	count;
    always @(posedge clk) begin
        count <= reset ? 0 : count + 1;
    end

    wire [18:0]	vram_addr2 = count[19:1];
    wire [35:0]	vpat = {2{count[8:3], 6'b00_00_00, count[8:3]}};//switch[0] ? 36'd0 : {2{count[8:3], 6'b00_00_00, count[8:3]}};



    // mux selecting read/write to memory based on which write-enable is chosen
    wire	        sw_ntsc = 1; // if 1 then saves video data
    wire	        my_we = sw_ntsc ? (hcount[0]==1'd1) : blank;
    wire [18:0]	write_addr = sw_ntsc ? ntsc_addr : vram_addr2;
    wire [35:0]	write_data = sw_ntsc ? ntsc_data : vpat;

    assign	vram_addr = my_we ? write_addr : vramReadAddr;
    assign	vram_we = my_we;
    assign	vram_write_data = write_data;




    ///////////////////////////////////////////////////////////////////////////
    // Determine pixel to display to screen
    ///////////////////////////////////////////////////////////////////////////

    reg [23:0] pixel;
    reg b,hs,vs;

    // figure out the green configuration screen pixel
    wire [23:0] greenCrossPixel = greenVertPixel | greenHorizPixel;
    wire [17:0] greenComPixel = (greenIncluded && (screenSetting == 2'd0)) ? 18'o00_77_00 : vr_pixel;
    wire [23:0] greenScreenPixel = greenCrossPixel ? greenCrossPixel : {greenComPixel[17:12], 2'd0, greenComPixel[11:6], 2'd0, greenComPixel[5:0], 2'd0};

    // figure out the red configuration screen pixel
    wire [23:0] redCrossPixel = redVertPixel | redHorizPixel;
    wire [17:0] redComPixel = (redIncluded && (screenSetting == 2'd1)) ? 18'o77_00_00 : vr_pixel;
    wire [23:0] redScreenPixel = redCrossPixel ? redCrossPixel : {redComPixel[17:12], 2'd0, redComPixel[11:6], 2'd0, redComPixel[5:0], 2'd0};




    ///////////////////////////////////////////////////////////////////////////
    // Gameplay module and gameplay pixel calculation
    ///////////////////////////////////////////////////////////////////////////

    wire exists1;        /// pipeline of exist signal
    wire exists2;

    reg [68:0]infoin1;
    wire [68:0]infoin2; //<----replaces usergrab with gamegrab given to infoin3
    wire [68:0]infoin3;

    wire clock_1;
    wire clock_2;           // pipeline of clock
    wire clock_3;
    wire pclock;
    wire phsync;            // pipelined video signals
    wire pvsync;
    wire pblank;

    assign clock_1 = clock_65mhz;

    wire signed [11:0]screenx;
    wire signed [12:0]screeny;
    wire signed [11:0]screenxmove;
    wire signed [12:0]screenymove;       // only screenx used, other values used in older version of map editor
    wire signed [11:0]screenxmap;
    wire signed [12:0]screenymap;
    reg [10:0] userhand1x;
    reg [9:0]  userhand1y;           // hand positions
    reg [10:0] userhand2x;
    reg [9:0] userhand2y;
    reg usergrab1;
    reg usergrab2;
    wire [12*5+13*5-1:0] holdinfo;
    wire [23:0] gamepixel;           // output pixel from game module
    wire vibrate1;    // vibrate outputs, worked, but too heavy on power supply
    wire vibrate2;



    wire reset2 = button3Clean;  // gameplay reset button

    always @(posedge clock_1) begin
        infoin1 = {reset2, hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1};  /// assign first infoin
    end

    always @(posedge vsync) begin
        userhand1x <= (3*xSmoothGreen)>>1;       //  scales output from tracking module, different sized screens
        userhand1y <= (3*ySmoothGreen)>>1;
        userhand2x <= (3*xSmoothRed)>>1;
        userhand2y <= (3*ySmoothRed)>>1;
    end



    assign	user1[2] = vibrate1;
    assign	user1[3] = vibrate2;             // output of vibrate signal

    always@(posedge clock_1) begin
        usergrab1<= user1[0];                        // input of grab
        usergrab2<= user1[1];
    end

    // mapeditor mapeditor(.infoin(infoin1), .switch (switch[1]), .screenxin(screenx), .screenyin(screeny), .screenx(screenxmap), .screeny(screenymap));
    handholds holds(.clockin(clock_1), .infoin(infoin1), .switch(switch[2]),
                    .screenx(screenx), .screeny(screeny),  .infout(infoin2),
                    .exists(exists1), .clockout(clock_2));
    grab       grab(.clockin(clock_2), .infoin(infoin2), .existsin(exists1),
                    .infout(infoin3), .existsout(exists2), .clockout(clock_3),
                    .vibrate1(vibrate1), .vibrate2(vibrate2));
    movement   move(.infoin(infoin3), .screenxin(screenx), .screenyin(screeny),
                    .switch(switch[2]), .screenx(screenx), .screeny(screeny));
    pixelinfo pixelmod(.clockin(clock_3),.infoin(infoin3), .screenx(screenx),
                       .screeny(screeny), .exists(exists2), .pclock(pclock),
                       .phsync(phsync), .pvsync(pvsync), .pblank(pblank), .pixel(gamepixel));
    // calls all the modules from gameplay block




   reg finalclock;


   always @(*) begin                                // uses blocking assignmets to avoid syncing issues with clocks
       // show pixel based on screen setting
       case (screenSetting)
           2'd0: begin pixel = greenScreenPixel;b = blank; hs = hsync;vs = vsync; finalclock =clk; end           // chooses output from green screen calbration
           2'd1: begin pixel = redScreenPixel;b = blank; hs = hsync;vs = vsync; finalclock =clk; end             // red screen calibration
           default: begin pixel = gamepixel;b = pblank; hs = phsync;vs = pvsync; finalclock =pclock;end          // or gameplay, notice pipelined clocks and auxillary info
       endcase
        // blank from xvga display
        // hsync from xvga display
        // vsync from xvga display
   end




   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clk.
   assign vga_out_red = {pixel[23:16]};
   assign vga_out_green = {pixel[15:8]};                     //// output to vga
   assign vga_out_blue = {pixel[7:0]};
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_pixel_clock = ~finalclock;
   assign vga_out_blank_b = ~b;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;

   // debugging

   assign led = ~{my_we, vpat[35:29]};

   reg [17:0] centerPixel;

   always @(posedge clk) begin
       if (hcount == 360 && vcount == 240) centerPixel <= pixel;
       dispdata <= {xSmoothGreen[7:0], ySmoothGreen[7:0], 4'hA, 2'b00, centerPixel, 4'hA, 1'b0, ntsc_addr[18:0]};
   end

endmodule

///////////////////////////////////////////////////////////////////////////////
// xvga: Generate XVGA display signals (1024 x 768 @ 60Hz)

module xvga(vclock,hcount,vcount,hsync,vsync,blank);
   input vclock;
   output [10:0] hcount;
   output [9:0] vcount;
   output 	vsync;
   output 	hsync;
   output 	blank;

   reg 	  hsync,vsync,hblank,vblank,blank;
   reg [10:0] 	 hcount;    // pixel number on current line
   reg [9:0] vcount;	 // line number

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   wire      hsyncon,hsyncoff,hreset,hblankon;
   assign    hblankon = (hcount == 1023);
   assign    hsyncon = (hcount == 1047);
   assign    hsyncoff = (hcount == 1183);
   assign    hreset = (hcount == 1343);

   // vertical: 806 lines total
   // display 768 lines
   wire      vsyncon,vsyncoff,vreset,vblankon;
   assign    vblankon = hreset & (vcount == 767);
   assign    vsyncon = hreset & (vcount == 776);
   assign    vsyncoff = hreset & (vcount == 782);
   assign    vreset = hreset & (vcount == 805);

   // sync and blanking
   wire      next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end
endmodule

/////////////////////////////////////////////////////////////////////////////
// generate display pixels from reading the ZBT ram
// note that the ZBT ram has 2 cycles of read (and write) latency
//
// We take care of that by latching the data at an appropriate time.
//
// Note that the ZBT stores 36 bits per word; we use only 32 bits here,
// decoded into four bytes of pixel data.
//
// Bug due to memory management will be fixed. The bug happens because
// memory is called based on current hcount & vcount, which will actually
// shows up 2 cycle in the future. Not to mention that these incoming data
// are latched for 2 cycles before they are used. Also remember that the
// ntsc2zbt's addressing protocol has been fixed.

// The original bug:
// -. At (hcount, vcount) = (100, 201) data at memory address(0,100,49)
//    arrives at vram_read_data, latch it to vr_data_latched.
// -. At (hcount, vcount) = (100, 203) data at memory address(0,100,49)
//    is latched to last_vr_data to be used for display.
// -. Remember that memory address(0,100,49) contains camera data
//    pixel(100,192) - pixel(100,195).
// -. At (hcount, vcount) = (100, 204) camera pixel data(100,192) is shown.
// -. At (hcount, vcount) = (100, 205) camera pixel data(100,193) is shown.
// -. At (hcount, vcount) = (100, 206) camera pixel data(100,194) is shown.
// -. At (hcount, vcount) = (100, 207) camera pixel data(100,195) is shown.
//
// Unfortunately this means that at (hcount == 0) to (hcount == 11) data from
// the right side of the camera is shown instead (including possible sync signals).

// To fix this, two corrections has been made:
// -. Fix addressing protocol in ntsc_to_zbt module.
// -. Forecast hcount & vcount 8 clock cycles ahead and use that
//    instead to call data from ZBT.
//
// MODIFICATION (Turner) -
// Now that we are doing this in color we need only forcast values 4 in advance.


module vram_display(reset,clk,hcount,vcount,vr_pixel,
		    vram_addr,vram_read_data, switches);

    input reset, clk;
    input [10:0] hcount;
    input [9:0] vcount;
    output [17:0] vr_pixel;
    output [18:0] vram_addr;
    input [35:0]  vram_read_data;
    input [2:0] switches; // NO LONGER USED

    // forecast hcount & vcount 4 clock cycles ahead to get data from ZBT
    // hcount goes to 1344
    // vcount goes to 806
    wire [10:0] hcount_f = (hcount >= 1044) ? (hcount - 1044) : (hcount + 4);
    wire [9:0] vcount_f = (hcount >= 1044) ? ((vcount == 805) ? 0 : vcount + 1) : vcount;

    wire [18:0] vram_addr = {vcount_f, hcount_f[9:1]};

	 wire hc2 = hcount[0];
    reg [35:0] last_vr_data, next_vr_data;
	 wire [24:0] redOnGreenPixel, greenOnRedPixel, whiteOnBlackPixel;

	 wire [17:0] vr_pixel, normalPixel, blobPixel, bgPixel;

    always @(posedge clk) begin
        // right before data will be needed, load it into last_vr_data
        last_vr_data = (hc2==1'b0) ? next_vr_data : last_vr_data;
        // 3 cycles after it was first requested, 2 cycles after it was last
        // requested, and 3 cycles before it will be needed, save the new data
        next_vr_data = (hc2==1'b0) ? vram_read_data : next_vr_data;
    end

    assign vr_pixel = (hcount >= 720 || vcount >= 460) ? 18'd0 : (hc2 == 2'd1 ? last_vr_data[17:0] : last_vr_data[35:0]);

endmodule // vram_display

////////////////////////////////////////////////////////////////////////////
// ramclock module

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- ZBT RAM clock generation
//
//
// Created: April 27, 2004
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// This module generates deskewed clocks for driving the ZBT SRAMs and FPGA
// registers. A special feedback trace on the labkit PCB (which is length
// matched to the RAM traces) is used to adjust the RAM clock phase so that
// rising clock edges reach the RAMs at exactly the same time as rising clock
// edges reach the registers in the FPGA.
//
// The RAM clock signals are driven by DDR output buffers, which further
// ensures that the clock-to-pad delay is the same for the RAM clocks as it is
// for any other registered RAM signal.
//
// When the FPGA is configured, the DCMs are enabled before the chip-level I/O
// drivers are released from tristate. It is therefore necessary to
// artificially hold the DCMs in reset for a few cycles after configuration.
// This is done using a 16-bit shift register. When the DCMs have locked, the
// <lock> output of this mnodule will go high. Until the DCMs are locked, the
// ouput clock timings are not guaranteed, so any logic driven by the
// <fpga_clock> should probably be held inreset until <locked> is high.
//
///////////////////////////////////////////////////////////////////////////////

module ramclock(ref_clock, fpga_clock, ram0_clock, ram1_clock,
	        clock_feedback_in, clock_feedback_out, locked);

   input ref_clock;                 // Reference clock input
   output fpga_clock;               // Output clock to drive FPGA logic
   output ram0_clock, ram1_clock;   // Output clocks for each RAM chip
   input  clock_feedback_in;        // Output to feedback trace
   output clock_feedback_out;       // Input from feedback trace
   output locked;                   // Indicates that clock outputs are stable

   wire  ref_clk, fpga_clk, ram_clk, fb_clk, lock1, lock2, dcm_reset;

   ////////////////////////////////////////////////////////////////////////////

   //To force ISE to compile the ramclock, this line has to be removed.
   //IBUFG ref_buf (.O(ref_clk), .I(ref_clock));

	assign ref_clk = ref_clock;

   BUFG int_buf (.O(fpga_clock), .I(fpga_clk));

   DCM int_dcm (.CLKFB(fpga_clock),
		.CLKIN(ref_clk),
		.RST(dcm_reset),
		.CLK0(fpga_clk),
		.LOCKED(lock1));
   // synthesis attribute DLL_FREQUENCY_MODE of int_dcm is "LOW"
   // synthesis attribute DUTY_CYCLE_CORRECTION of int_dcm is "TRUE"
   // synthesis attribute STARTUP_WAIT of int_dcm is "FALSE"
   // synthesis attribute DFS_FREQUENCY_MODE of int_dcm is "LOW"
   // synthesis attribute CLK_FEEDBACK of int_dcm  is "1X"
   // synthesis attribute CLKOUT_PHASE_SHIFT of int_dcm is "NONE"
   // synthesis attribute PHASE_SHIFT of int_dcm is 0

   BUFG ext_buf (.O(ram_clock), .I(ram_clk));

   IBUFG fb_buf (.O(fb_clk), .I(clock_feedback_in));

   DCM ext_dcm (.CLKFB(fb_clk),
		    .CLKIN(ref_clk),
		    .RST(dcm_reset),
		    .CLK0(ram_clk),
		    .LOCKED(lock2));
   // synthesis attribute DLL_FREQUENCY_MODE of ext_dcm is "LOW"
   // synthesis attribute DUTY_CYCLE_CORRECTION of ext_dcm is "TRUE"
   // synthesis attribute STARTUP_WAIT of ext_dcm is "FALSE"
   // synthesis attribute DFS_FREQUENCY_MODE of ext_dcm is "LOW"
   // synthesis attribute CLK_FEEDBACK of ext_dcm  is "1X"
   // synthesis attribute CLKOUT_PHASE_SHIFT of ext_dcm is "NONE"
   // synthesis attribute PHASE_SHIFT of ext_dcm is 0

   SRL16 dcm_rst_sr (.D(1'b0), .CLK(ref_clk), .Q(dcm_reset),
		     .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   // synthesis attribute init of dcm_rst_sr is "000F";


   OFDDRRSE ddr_reg0 (.Q(ram0_clock), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));
   OFDDRRSE ddr_reg1 (.Q(ram1_clock), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));
   OFDDRRSE ddr_reg2 (.Q(clock_feedback_out), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));

   assign locked = lock1 && lock2;

endmodule
