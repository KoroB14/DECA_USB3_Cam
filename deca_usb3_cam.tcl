
package require ::quartus::project



set_instance_assignment -name IO_STANDARD "1.5 V SCHMITT TRIGGER" -to rst_n
set_location_assignment PIN_H21 -to rst_n

set_location_assignment PIN_J9 -to sioc
set_location_assignment PIN_H3 -to siod
set_location_assignment PIN_AA7 -to VSYNC_cam
set_location_assignment PIN_AB6 -to HREF_cam
set_location_assignment PIN_AB7 -to PCLK_cam
set_location_assignment PIN_R11 -to XCLK_cam
set_location_assignment PIN_V7 -to data_cam[7]
set_location_assignment PIN_AB8 -to data_cam[6]
set_location_assignment PIN_V8 -to data_cam[5]
set_location_assignment PIN_W8 -to data_cam[4]
set_location_assignment PIN_W7 -to data_cam[3]
set_location_assignment PIN_W6 -to data_cam[2]
set_location_assignment PIN_Y6 -to data_cam[1]
set_location_assignment PIN_Y5 -to data_cam[0]
set_location_assignment PIN_K5 -to on_off_cam
set_location_assignment PIN_P11 -to clk_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_50
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to siod
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to sioc

set_location_assignment PIN_J4 -to res_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to HREF_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to PCLK_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to VSYNC_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to XCLK_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to data_cam[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to on_off_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to res_cam
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to sioc
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to siod

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DMA0_Ready
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DMA0_Watermark
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DMA1_Ready
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DMA1_Watermark
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DQ[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to RD
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to USB_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to WR
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to OE
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LastWRData

set_location_assignment PIN_V15 -to DMA0_Ready
set_location_assignment PIN_AB16 -to DMA0_Watermark
set_location_assignment PIN_Y14 -to DMA1_Ready
set_location_assignment PIN_AB13 -to DMA1_Watermark
set_location_assignment PIN_U15 -to DQ[15]
set_location_assignment PIN_V13 -to DQ[14]
set_location_assignment PIN_W12 -to DQ[13]
set_location_assignment PIN_Y11 -to DQ[12]
set_location_assignment PIN_AB10 -to DQ[11]
set_location_assignment PIN_AB12 -to DQ[10]
set_location_assignment PIN_AB14 -to DQ[9]
set_location_assignment PIN_AB15 -to DQ[8]
set_location_assignment PIN_AB17 -to DQ[7]
set_location_assignment PIN_V16 -to DQ[6]
set_location_assignment PIN_AB19 -to DQ[5]
set_location_assignment PIN_AB21 -to DQ[4]
set_location_assignment PIN_AA20 -to DQ[3]
set_location_assignment PIN_AA17 -to DQ[2]
set_location_assignment PIN_Y18 -to DQ[1]
set_location_assignment PIN_W18 -to DQ[0]
set_location_assignment PIN_AB11 -to LastWRData
set_location_assignment PIN_AB20 -to RD
set_location_assignment PIN_Y19 -to USB_CLK
set_location_assignment PIN_AA19 -to WR
set_location_assignment PIN_Y16 -to OE

set_instance_assignment -name FAST_INPUT_REGISTER ON -to DMA0_Ready
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DMA1_Ready
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DMA0_Watermark
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DMA1_Watermark
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[0]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[1]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[2]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[3]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[4]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[5]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[6]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[7]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[8]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[9]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[10]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[11]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[12]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[13]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[14]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to DQ[15]