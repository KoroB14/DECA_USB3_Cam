//////////////////////////////////////////////////////////////////////////////////
// Dmitry Koroteev
// korob14@gmail.com
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module MainFSM
#(	//Image params
	parameter IM_X = 1280,
	parameter IM_Y = 720,
	parameter COLOR_MODE = 2
)

(
    input 					USB_CLK,
	 input 					rst_n,
    input 					DMA0_Ready,
	 input 					DMA0_Watermark,
	 input 					DMA1_Ready, 
	 input 					DMA1_Watermark, 
	 output reg 			WR, 
	 output reg 			RD,
	 output reg 			LastWRData,
	 output reg 			OE,
	 inout 		[15:0] 	DQ,
	 
	 input 					wrclk,
	 input 					in_valid,
	 input 		[7:0] 	in_data,
	 output 					in_ready,
	 output reg				start_stream
 
);

//FIFO params
localparam BYTE_MUL = 'd2;
localparam BYTES = COLOR_MODE * IM_X + 2;
localparam WORDS = BYTES / BYTE_MUL;
localparam XWORDS = $clog2(2*WORDS);
//Packet params
localparam PacketID = (COLOR_MODE == 1) ? 16'h00AA : ((COLOR_MODE == 2) ? 16'h00BB : 0);
//Ctrl params
localparam GET_CFG = 8'h01;
localparam STRT_ST = 8'h11;
localparam STOP_ST = 8'h0f;
//FSM states
localparam WAIT4DMA 	= 10'b0000000001;
localparam WRITE 		= 10'b0000000010;
localparam PAUSE_W 	= 10'b0000000100;
localparam DR_READ	= 10'b0000001000;
localparam READ 		= 10'b0000010000;
localparam PAUSE_R 	= 10'b0000100000;
localparam RD_CMD		= 10'b0001000000;
localparam SEND_CFG  = 10'b0010000000;
localparam START_ST	= 10'b0100000000;
localparam STP_ST		= 10'b1000000000;

//declarations
reg DMA0_Ready_t, DMA0_Watermark_t, DMA0_Ready_r, DMA0_Watermark_r, DMA1_Ready_r, DMA1_Watermark_r;
reg [9:0] CurrentState, NextState;
reg [15:0] DATA_IN, DATA;
reg [15:0] pkt_data;
reg [2:0] lat_count;
reg [15:0] send_cnt;
reg [15:0] line_cnt;
reg [1:0] rdaddress;
reg OEp;
wire [15:0] fifo_data;
wire fifo_full;
wire fifo_empty;
wire [XWORDS - 1 : 0] usedw;
//assignments
wire rdreq = (CurrentState == WRITE) && ((send_cnt <= WORDS - 2));
assign DQ = OEp ? DATA : 16'hzzzz;
assign in_ready = ~fifo_full;

//reg DMA flags
always @ (posedge USB_CLK)
begin
	{DMA0_Ready_t, DMA0_Watermark_t, DMA1_Ready_r, DMA1_Watermark_r} <= {DMA0_Ready, DMA0_Watermark, DMA1_Ready, DMA1_Watermark};
	{DMA0_Ready_r, DMA0_Watermark_r} <= {DMA0_Ready_t, DMA0_Watermark_t};
end

//reg input data
always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n) 	
	DATA_IN <= 0;
else 
	if (CurrentState == READ) 
		DATA_IN <= DQ;

//FIFO
dc_data_fifo 
#(.ADDR_W(XWORDS),
  .DATA_IN_W(8),
  .DATA_OUT_W(8*BYTE_MUL)) 
dc_data_fifo_inst
(
	.rdclk(USB_CLK),
	.wrclk(wrclk),
	.rst_n(rst_n & start_stream),
	.rdreq(rdreq & !fifo_empty),
	.wrreq(in_valid & !fifo_full),
	.data_in(in_data),
	.data_out(fifo_data),
	.rdempty(fifo_empty),
	.wrfull(fifo_full),
	.rdusedw(usedw)
);

//Stream params rom
always @(*)
case(rdaddress)
	'h00	:	pkt_data = PacketID; // Packet ID
	'h01	: 	pkt_data = IM_X; // IM_X
	'h02	: 	pkt_data = IM_Y; // IM_Y
	default: pkt_data = 8'h00;
endcase

always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n)
	rdaddress <= 0;
else if (CurrentState == SEND_CFG)
	rdaddress <= rdaddress + 1'b1;
else
	rdaddress <= 0;

//Control signals
always @ (posedge USB_CLK) 
begin
	 OEp <= (CurrentState == WRITE) || (CurrentState == SEND_CFG);
	 WR <= (CurrentState == WRITE) || (CurrentState == SEND_CFG) ;
	 LastWRData <= (rdaddress == 'h02) && (CurrentState == SEND_CFG);
	 RD <= (CurrentState == DR_READ) && (lat_count == 1);
	 OE <= (CurrentState == DR_READ) || (CurrentState == READ);  
end

//Data mux
always @ (posedge USB_CLK) 
if (((CurrentState == WRITE) || (CurrentState == PAUSE_W)) && (send_cnt == 0))
		DATA <= line_cnt;
else if (CurrentState == SEND_CFG)
		DATA <= pkt_data;
else
		DATA <= fifo_data;


//reg start_stream;
always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n)
	start_stream <= 0;
else if (CurrentState == START_ST)
	start_stream <= 1'b1;
else if (CurrentState == STP_ST)
	start_stream <= 0;

//FSM state
always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n) 
	CurrentState <= WAIT4DMA;
else 
	CurrentState <= NextState;

//latency counter
always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n)
	lat_count <= 0;
else if ((CurrentState == DR_READ) || (CurrentState == PAUSE_R) || (CurrentState == PAUSE_W))
	lat_count <= lat_count + 1'b1;
else 
	lat_count <= 0;
	
//Next state logic
always @ (*) begin
	NextState = CurrentState;
	case (CurrentState)
	WAIT4DMA:	begin
						if (DMA1_Ready_r) 
							NextState = DR_READ;
						else if (DMA0_Ready_r && ((usedw >= WORDS - 2) || (send_cnt > 0 && send_cnt <= WORDS - 1)) && !((send_cnt == WORDS) && WR)) 
							NextState = WRITE; 
					end	
	WRITE:		begin
						if (DMA0_Watermark_r) 
							NextState = PAUSE_W;
						else if (send_cnt >= WORDS - 1)
							NextState = WAIT4DMA;
					end
	PAUSE_W:		begin
						if (~DMA0_Ready_r || (lat_count == 6)) 
							NextState = WAIT4DMA;
					end
	DR_READ:		begin
						if (lat_count == 4)
							NextState = READ;
					end
	READ:			begin
						if (DMA1_Watermark_r) 
							NextState = PAUSE_R;
					end
	PAUSE_R:		begin
						if (~DMA1_Ready_r) 
							NextState = RD_CMD;
					end
	RD_CMD:		begin
						case (DATA_IN[7:0])
							GET_CFG	:	begin
												if (DMA0_Ready_r & !DMA0_Watermark_r)
													NextState = SEND_CFG;
											end
							STRT_ST	:	NextState = START_ST;
							STOP_ST	:	NextState = STP_ST;
							default	:	NextState = WAIT4DMA;
						endcase
					end
	SEND_CFG:	begin
						if (rdaddress == 'h02)
							NextState = WAIT4DMA;
					end
	START_ST:	begin
						NextState = WAIT4DMA;
					end
	STP_ST:		begin
						NextState = WAIT4DMA;
					end
	
	default:		NextState = WAIT4DMA;		
	endcase
end
		
//Send Cnt
always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n)
	send_cnt <= 0;
else if ((send_cnt == WORDS) || (CurrentState == SEND_CFG))
	send_cnt <= 0;
else if (CurrentState == WRITE)
	send_cnt <= send_cnt + 1'b1;

//line cnt
always @ (posedge USB_CLK or negedge rst_n)
if (!rst_n) 
	line_cnt <= 0;
else if (((send_cnt == WORDS) && (line_cnt == IM_Y - 1)) || !start_stream) 
	line_cnt <= 0;
else if (send_cnt == WORDS) 
	line_cnt <= line_cnt + 1'b1;
	
endmodule
