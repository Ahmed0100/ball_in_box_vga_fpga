module ball_in_box_top
(
	input clk,reset_n,
	input [1:0] btn,
	output vga_hsync,vga_vsync,
	output [2:0] vga_rgb
);
//signal declarations
wire [9:0] pixel_x,pixel_y;
wire video_on;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;
//body 
vga_sync vga_sync_inst
(
	.clk(clk), .rst_n(reset_n), .hsync(vga_hsync),.vsync(vga_vsync),.pixel_x(pixel_x),.pixel_y(pixel_y),
	.video_on(video_on)
);

two_balls_in_box ball_in_box_inst
(	.clk(clk),.reset_n(reset_n),
	.video_on(video_on),
	.key(btn),
	.pixel_x(pixel_x),.pixel_y(pixel_y),
	.rgb(rgb_next)
);

always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
		rgb_reg <= 0;
	else 
		rgb_reg <= rgb_next;
end
assign vga_rgb = rgb_reg;
endmodule