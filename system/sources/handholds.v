module handholds (
    input clockin,
    input [68:0] infoin,
    input signed [12:0]  screeny,
    input signed [11:0] screenx,
    input switch,                   ///switch indicates if it is in map edditing mode

        output reg [68:0] infout,
        output reg exists,
        output clockout

    );

    wire reset;
    wire vclock;
    wire [10:0] hcount;
    wire [9:0]  vcount;
    wire hsync,vsync,blank;
    wire [10:0] userhand1x;
    wire [9:0]  userhand1y;
    wire [10:0] userhand2x;
    wire [9:0] userhand2y;
    wire usergrab1;
    wire usergrab2;


    assign {reset, hcount, vcount, hsync, vsync, blank, userhand1x, userhand1y, userhand2x, userhand2y, usergrab2, usergrab1} = infoin;   ///pipelines info accordingly
    assign vclock = clockin;
    always @(posedge vclock) infout <= infoin;
    assign clockout = clockin;

    wire exists1;
    wire exists2;
    wire exists3;
    wire exists4;
    wire exists5;
    wire exists6;
    wire exists7;
    wire exists8;
    wire exists9;
    wire exists10;
    wire exists11;
    wire exists12;
    wire exists13;
    wire exists14;
    wire exists15;

    reg signed [11:0] x1;
    reg   signed [11:0] x2;
    reg   signed [11:0] x3;
    reg   signed [11:0] x4;
    reg   signed [11:0] x5;
    reg   signed [11:0] x6;
    reg   signed [11:0] x7;
    reg   signed [11:0] x8;                  //// each handhold has an exist register and  x and y position
    reg   signed [11:0] x9;
    reg   signed [11:0] x10;
    reg   signed [11:0] x11;
    reg   signed [11:0] x12;
    reg   signed [11:0] x13;
    reg   signed [11:0] x14;
    reg   signed [11:0] x15;

    reg   signed [12:0] y1;
    reg   signed [12:0] y2;
    reg   signed [12:0] y3;
    reg   signed [12:0] y4;
    reg   signed [12:0] y5;
    reg   signed [12:0] y6;
    reg   signed [12:0] y7;
    reg   signed [12:0] y8;
    reg   signed [12:0] y9;
    reg   signed [12:0] y10;
    reg   signed [12:0] y11;
    reg   signed [12:0] y12;
    reg   signed [12:0] y13;
    reg   signed [12:0] y14;
    reg   signed [12:0] y15;


    hold hold1(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x1), .y(y1), .screeny(screeny),.screenx(screenx), .exists(exists1));
    hold hold2(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x2), .y(y2), .screeny(screeny),.screenx(screenx), .exists(exists2));
    hold hold3(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x3), .y(y3), .screeny(screeny),.screenx(screenx), .exists(exists3));
    hold hold4(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x4), .y(y4), .screeny(screeny),.screenx(screenx), .exists(exists4));
    hold hold5(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x5), .y(y5), .screeny(screeny),.screenx(screenx), .exists(exists5));
    hold hold6(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x6), .y(y6), .screeny(screeny),.screenx(screenx), .exists(exists6));
    hold hold7(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x7), .y(y7), .screeny(screeny),.screenx(screenx), .exists(exists7));     ///15 instances of holds
    hold hold8(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x8), .y(y8), .screeny(screeny),.screenx(screenx), .exists(exists8));
    hold hold9(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x9), .y(y9), .screeny(screeny),.screenx(screenx), .exists(exists9));
    hold hold10(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x10), .y(y10), .screeny(screeny),.screenx(screenx), .exists(exists10));
    hold hold11(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x11), .y(y11), .screeny(screeny),.screenx(screenx), .exists(exists11));
    hold hold12(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x12), .y(y12), .screeny(screeny),.screenx(screenx), .exists(exists12));
    hold hold13(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x13), .y(y13), .screeny(screeny),.screenx(screenx), .exists(exists13));
    hold hold14(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x14), .y(y14), .screeny(screeny),.screenx(screenx), .exists(exists14));
    hold hold15(.clock(vclock),.hcount(hcount), .vcount(vcount), .x(x15), .y(y15), .screeny(screeny),.screenx(screenx), .exists(exists15));


    always @ (posedge vclock) begin
        if (exists1 || exists2 || exists3 || exists4 ||exists5||exists6 || exists7 || exists8 || exists9 ||exists10||exists11 || exists12 || exists13 || exists14 ||exists15) exists <= 1;
        else exists <=0;

        // ands the exists from each module, final output exist

        if (reset) begin

            x1 <= 400;
            x2 <= 300;
            x3 <= 580;               //// if reset, use predetermined placements
            x4 <= 300;
            x5 <= 700;
            x6 <= 450;
            x7 <= 600;
            x8 <= 640;
            x9 <= 300;
            x10 <= 250;
            x11 <= 375;
            x12 <= 500;
            x13 <= 530;
            x14 <= 580;
            x15 <= 650;

            y1 <= 50;
            y2 <= 100;
            y3 <= 400;
            y4 <= 600;
            y5 <= 200;
            y6 <= -550;
            y7 <= -450;
            y8 <= -200;
            y9 <= -1000;
            y10 <= 300;
            y11 <= -1500;
            y12 <= -1200;
            y13 <= -1400;
            y14 <= -1600;
            y15 <= -700;

        end

        else	if (switch==1) begin           //// map editor, if in map editor mode, and a user grabs a hold in the game, update the position of the hold, done for each hold
            //// movement of holds worked, but player movement inside map editor held it back
            if ((exists1 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x1 <= screenx + userhand1x;
                y1 <= screeny + userhand1y;
            end
            else if ((exists2 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x2 <= screenx + userhand1x;
                y2 <= screeny + userhand1y;
            end
            else if ((exists3 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x3 <= screenx + userhand1x;
                y3 <= screeny + userhand1y;
            end
            else if ((exists4 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x4 <= screenx + userhand1x;
                y4 <= screeny + userhand1y;
            end
            else if ((exists5 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x5 <= screenx + userhand1x;
                y5 <= screeny + userhand1y;
            end
            else if ((exists6 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x6 <= screenx + userhand1x;
                y6 <= screeny + userhand1y;
            end
            else if ((exists7 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x7 <= screenx + userhand1x;
                y7 <= screeny + userhand1y;
            end
            else if ((exists8 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x8 <= screenx + userhand1x;
                y8 <= screeny + userhand1y;
            end
            else if ((exists9 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x9 <= screenx + userhand1x;
                y9 <= screeny + vcount;
            end
            else if ((exists10 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x10 <= screenx + userhand1x;
                y10 <= screeny + userhand1y;
            end
            else if ((exists11 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x11 <= screenx + userhand1x;
                y11 <= screeny + userhand1y;
            end
            else if ((exists12 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x12 <= screenx + userhand1x;
                y12 <= screeny + userhand1y;
            end
            else if ((exists13 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x13 <= screenx + userhand1x;
                y13 <= screeny + userhand1y;
            end
            else if ((exists14 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x14 <= screenx + userhand1x;
                y14 <= screeny + userhand1y;
            end
            else if ((exists5 == 1 && usergrab1 ==1) && (((hcount-userhand1x)*(hcount-userhand1x)+(vcount-userhand1y)*(vcount-userhand1y)) < 150)) begin
                x15 <= screenx + userhand1x;
                y15 <= screeny + userhand1y;
            end
        end
    end

endmodule
