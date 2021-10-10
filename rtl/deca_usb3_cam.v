`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
//
// 
// | reg settings              | COLOR_MODE | FPGA_PROCESSING |               Comment                     |
// | OV5642_1280p_30f_rgb.mif  |     2      |        2        | 1280 x 720 x 30 FPS RGB565                |
// | OV5642_1280p_60f_gray.mif |     1      |        2        | 1280 x 720 x 60 FPS GRAY8 Cam processing  |
// | OV5642_1920p_30f_rgb.mif  |     2      |        2        | 1920 x 1080 x 30 FPS RGB565               |
// | OV5642_1920p_30f_gray.mif |     1      |        2        | 1920 x 1080 x 30 FPS GRAY8 Cam processing |
module deca_usb3_cam
#(	parameter IM_X = 1920,
	parameter IM_Y = 1080,
	parameter COLOR_MODE = 2,		// 1 - Grayscale, 2 - RGB565
	parameter FPGA_PROCESSING = 2, // 1 - Convert RGB565 -> 8-bit Grayscale, 2 - No processing
	parameter CAMERA_ADDR = 8'h78,// 8'h60 - OV2640, 8'h42 - OV7670, 8'h78 - OV5642
	parameter MIF_FILE = "./rtl/cam_config/OV5642_1920p_30f_rgb.mif", // Camera registers init file
	parameter FAST_SIM = 0			// 1- Fast simulation mode, skip camera initialization
)
(
	//System
	input 						clk_50,
	input 						rst_n,
	
	//CYUSB 3014
	input wire 					USB_CLK,
	inout	tri		[15:0]	DQ,
	output wire					RD,
	output wire					WR,
	output wire					LastWRData,
	output wire					OE,
	input wire					DMA0_Ready,
	input wire					DMA0_Watermark,
	input wire					DMA1_Ready,
	input wire					DMA1_Watermark,
		
	//Cam DVP & SCCB
	input				[7:0]		data_cam,
	input 						VSYNC_cam,
	input 						HREF_cam,
	input 						PCLK_cam,	
	output						XCLK_cam,
	output						res_cam,
	output						on_off_cam,	
	output						sioc,
	output						siod
	
);
//declarations
wire 			rst_s;
wire			conf_done;
wire 	[7:0] pixdata;
wire 			pixdata_valid;
wire 			in_ready;
wire			start_stream;

//OV5642 assignments
assign on_off_cam = 0;
assign res_cam = 0;
assign XCLK_cam = 1'bz;

//rst sync
sync rst_sync
(
	.in					(rst_n),
	.clk					(clk_50),
	.out					(rst_s)
);

//camera config
camera_configure 
#(	
    .CLK_FREQ			(50000000),
	 .CAMERA_ADDR		(CAMERA_ADDR),
	 .MIF_FILE			(MIF_FILE),
	 .I2C_ADDR_16		(1'b1),
	 .FAST_SIM			(FAST_SIM)
)
camera_configure_0
(
    .clk					(clk_50),	
	 .rst_n				(rst_s),
	 .sioc				(sioc),
    .siod				(siod),
	 .done				(conf_done)
	
);

//cam capture
cam_capture 
#(
	.COLOR_MODE			(FPGA_PROCESSING),
	.IM_X					(IM_X),
	.IM_Y					(IM_Y)
)
cam_capture_0
(
	.rst_n				(rst_s & conf_done),
	.data_cam			(data_cam),
	.VSYNC_cam			(VSYNC_cam),
	.HREF_cam			(HREF_cam),
	.PCLK_cam			(PCLK_cam),
	.pixel				(pixdata),
	.pixel_valid		(pixdata_valid),
	.out_ready			(in_ready),
	.start_stream		(start_stream)	

);


//Main control
MainFSM
# (
	.IM_X					(IM_X),
	.IM_Y					(IM_Y),
	.COLOR_MODE			(COLOR_MODE)
	)
MainFSM_Inst
(
    .USB_CLK			(USB_CLK),
	 .rst_n				(rst_s),
    .WR					(WR), 
	 .RD					(RD),
	 .LastWRData		(LastWRData),
	 .OE					(OE),
	 .DMA0_Ready		(DMA0_Ready),
	 .DMA0_Watermark	(DMA0_Watermark),
	 .DMA1_Ready		(DMA1_Ready), 
	 .DMA1_Watermark	(DMA1_Watermark), 
	 .DQ					(DQ),
	 .start_stream		(start_stream),
	 .wrclk				(PCLK_cam),
	 .in_valid			(pixdata_valid),
	 .in_data			(pixdata),
	 .in_ready			(in_ready)
	 	 
);

endmodule
