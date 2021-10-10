module dc_data_fifo
#(
	parameter ADDR_W = 10,
   parameter DATA_IN_W = 8,
	parameter DATA_OUT_W = 16
	
)
(
	input wire 								rdclk,
	input wire 								wrclk,
	input wire 								rst_n,
	input wire 								rdreq,
	input wire 								wrreq,
	input wire 	[DATA_IN_W - 1:0] 	data_in,
	output wire [DATA_OUT_W - 1:0]	data_out,
	output wire 							rdempty,
	output wire 							wrfull,
	output wire [ADDR_W - 1 : 0]		rdusedw
);


dcfifo_mixed_widths  dcfifo_component (
				.aclr (~rst_n),
				.data (data_in),
				.rdclk (rdclk),
				.rdreq (rdreq),
				.wrclk (wrclk),
				.wrreq (wrreq),
				.q (data_out),
				.rdempty (rdempty),
				.rdusedw (rdusedw),
				.wrfull (wrfull),
				.eccstatus (),
				.rdfull (),
				.wrempty (),
				.wrusedw ());
	defparam
		dcfifo_component.intended_device_family = "MAX 10",
		dcfifo_component.lpm_numwords = (2**(ADDR_W))*(DATA_OUT_W / DATA_IN_W),
		dcfifo_component.lpm_showahead = "OFF",
		dcfifo_component.lpm_type = "dcfifo",
		dcfifo_component.lpm_width = DATA_IN_W,
		dcfifo_component.lpm_width_r = DATA_OUT_W,
		dcfifo_component.lpm_widthu = ADDR_W + (DATA_OUT_W / DATA_IN_W) - 1,
		dcfifo_component.lpm_widthu_r = ADDR_W,
		dcfifo_component.overflow_checking = "ON",
		dcfifo_component.rdsync_delaypipe = 4,
		dcfifo_component.read_aclr_synch = "OFF",
		dcfifo_component.underflow_checking = "ON",
		dcfifo_component.use_eab = "ON",
		dcfifo_component.write_aclr_synch = "OFF",
		dcfifo_component.wrsync_delaypipe = 4;
		
	
endmodule
