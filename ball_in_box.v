module ball_in_box
(
	input clk,reset_n,
	input video_on,
	input [1:0] key,
	input [11:0] pixel_x,pixel_y,
	output reg [2:0] rgb
);
	 localparam LWALL_XL=187, //left
					LWALL_XR=192, //right
					LWALL_YT=107, //top
					LWALL_YB=373, //bottom
					
						//RIGHT WALL
					RWALL_XL=447, //left
					RWALL_XR=452, //right
					RWALL_YT=107, //top
					RWALL_YB=372, //bottom
						
						//TOP WALL
					TWALL_XL=187, //left
					TWALL_XR=452, //right
					TWALL_YT=107, //top
					TWALL_YB=112, //bottom
		
						//BOTTOM WALL
					BWALL_XL=187, //left
					BWALL_XR=452, //right
					BWALL_YT=367, //top
					BWALL_YB=372, //bottom
					
					BALL_DIAM=7; //ball diameter minus one

reg [4:0] ball_v[3:0];
reg [1:0] ball_v_reg,ball_v_next;
initial
begin
	ball_v[0] = 5'd1;
	ball_v[1] = 5'd5;
	ball_v[2] = 5'd10;
	ball_v[3]= 5'd20;
end

wire lwall_on,rwall_on,twall_on,bwall_on,ball_box;
wire key_0_tick,key_1_tick;
reg [2:0] lwall_reg,lwall_next,rwall_reg,rwall_next,
bwall_reg,bwall_next,twall_reg,twall_next;
reg ball_on;
reg [2:0] rom_addr;
reg [7:0] rom_data;
reg [9:0] ball_x_reg=280,ball_x_next;
reg [9:0] ball_y_reg=200, ball_y_next;
reg ball_x_delta_reg,ball_x_delta_next;
reg ball_y_delta_reg,ball_y_delta_next;
//display conditions for the four walls
assign lwall_on= LWALL_XL<=pixel_x && pixel_x<=LWALL_XR && LWALL_YT<=pixel_y && pixel_y<=LWALL_YB;
assign rwall_on= RWALL_XL<=pixel_x && pixel_x<=RWALL_XR && RWALL_YT<=pixel_y && pixel_y<=RWALL_YB;
assign twall_on= TWALL_XL<=pixel_x && pixel_x<TWALL_XR && TWALL_YT<=pixel_y && pixel_y<=TWALL_YB;
assign bwall_on= BWALL_XL<=pixel_x && pixel_x<BWALL_XR && BWALL_YT<=pixel_y && pixel_y<=BWALL_YB;

assign ball_box= ball_x_reg<=pixel_x && pixel_x<=(ball_x_reg+BALL_DIAM) &&  ball_y_reg<=pixel_y && pixel_y<=(ball_y_reg+BALL_DIAM);

always @*
begin
	rom_addr=0;
	ball_on=0;
	if(ball_box)
	begin
		rom_addr = pixel_y - ball_y_reg;
		if(rom_data[pixel_x-ball_x_reg]) ball_on = 1;
	end
end
//ball rom pattern
always @* begin
	case(rom_addr)
			3'd0: rom_data=8'b0001_1000;
			3'd1: rom_data=8'b0011_1100;
			3'd2: rom_data=8'b0111_1110;
			3'd3: rom_data=8'b1111_1111;
			3'd4: rom_data=8'b1111_1111;
			3'd5: rom_data=8'b0111_1110;
			3'd6: rom_data=8'b0011_1100;
			3'd7: rom_data=8'b0001_1000;
	endcase
end
always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
	begin
		ball_x_reg <= 320;
		ball_y_reg <= 240;
		ball_x_delta_reg <= 0;
		ball_y_delta_reg <= 0;
		lwall_reg <= 0;
		rwall_reg <= 0;
		twall_reg <= 0;
		bwall_reg <= 0;
		ball_x_reg<=0;
	end
	else
	begin
			ball_x_reg<=ball_x_next;
			ball_y_reg<=ball_y_next;
			ball_x_delta_reg<=ball_x_delta_next;
			ball_y_delta_reg<=ball_y_delta_next;
			lwall_reg<=lwall_next;
			rwall_reg<=rwall_next;
			twall_reg<=twall_next;
			bwall_reg<=bwall_next;
			ball_v_reg<=ball_v_next;
	end
end
always @(*)
begin
	ball_x_next = ball_x_reg;
	ball_y_next = ball_y_reg;
	ball_x_delta_next = ball_x_delta_reg;
	ball_y_delta_next = ball_y_delta_reg;
	lwall_next = lwall_reg;
	rwall_next = rwall_reg;
	twall_next = twall_reg;
	bwall_next = bwall_reg;
	ball_v_next = ball_v_reg;
	if(key_0_tick)
	begin
		ball_x_next = pixel_x;
		ball_y_next = pixel_y;
	end
	else if(pixel_y ==500 && pixel_x == 0)
	begin
		lwall_next = 3'b010;
		rwall_next = 3'b010;
		twall_next = 3'b010;
		bwall_next = 3'b010;
		if(ball_x_reg <= LWALL_XR)
		begin
			ball_x_delta_next = 1;
			lwall_next = 3'b100;
		end
		else if(ball_x_reg + BALL_DIAM >= RWALL_XL)
		begin
			ball_x_delta_next  = 0;
			rwall_next = 3'b001;
		end

		if(ball_y_reg<= TWALL_YB)
		begin
			ball_y_delta_next = 1;
			twall_next = 3'b100;
		end
		else if(ball_y_reg + BALL_DIAM >= BWALL_YT)
		begin
			ball_y_delta_next = 0;
			bwall_next = 3'b001;
		end
		ball_x_next = (ball_x_delta_next)? ball_x_reg + ball_v[ball_v_reg]: ball_x_reg - ball_v[ball_v_reg];
		ball_y_next = (ball_y_delta_next)? ball_y_reg + ball_v[ball_v_reg]: ball_y_reg - ball_v[ball_v_reg];

	end
	if(key_1_tick)
		ball_v_next = ball_v_reg + 1;
end
always @*
begin
	rgb=0;
	if(video_on)
	begin
		if(ball_on) 
			rgb = 3'b100;
		else if(rwall_on)
			rgb= rwall_reg;
		else if(lwall_on)
			rgb = lwall_reg;
		else if(twall_on)
			rgb = twall_reg;
		else if(bwall_on)
			rgb = bwall_reg;
		else if(LWALL_XR<=pixel_x && pixel_x<=RWALL_XL && TWALL_YB<=pixel_y && pixel_y<=BWALL_YT)
			rgb=3'b110;
		else
			rgb=3'b111;
	end
end

db_fsm inst0
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(key[0]),
	.db_level(),
	.db_tick(key_0_tick)
);

db_fsm inst1
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(key[1]),
	.db_level(),
	.db_tick(key_1_tick)
);

endmodule