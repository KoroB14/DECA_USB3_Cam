
#Sys clock
create_clock -name clk_50 -period "50.0 MHz" [get_ports clk_50]
#USB clock
create_clock -name clk_usb -period "100.0 MHz" [get_ports USB_CLK]
create_clock -name virt_clk_usb -period "100 MHz"
#OV5642 camera clock
set PCLK_FREQ "96MHz"
create_clock -name {PCLK_cam} -period $PCLK_FREQ [get_ports {PCLK_cam}]
create_clock -name {virt_clk_cam} -period $PCLK_FREQ
set CAM_DATA_DELAY 2.500

derive_clock_uncertainty

set_clock_groups -exclusive -group [get_clocks {clk_usb virt_clk_usb}]
set_clock_groups -exclusive -group [get_clocks {PCLK_cam virt_clk_cam}] 
set_clock_groups -asynchronous -group [get_clocks {PCLK_cam}] -group [get_clocks {clk_usb}] -group [get_clocks {clk_50}] 

#USB len
set Len 70
#create the input delay referencing the virtual clock
#specify the maximum external clock delay from the external
#device
set CLKAs_max 0.0
#specify the minimum external clock delay from the external
#device
set CLKAs_min 0.0
#specify the maximum external clock delay to the FPGA
set CLKAd_max [expr $Len*0.007]
#specify the minimum external clock delay to the FPGA
set CLKAd_min [expr $Len*0.007]
#specify the maximum clock-to-out of the external device
set tCOa_max 7
#specify the minimum clock-to-out of the external device
set tCOa_min 0.5
#specify the maximum board delay
set BDa_max [expr $Len*0.007]
#specify the minimum board delay
set BDa_min [expr $Len*0.007]

set_input_delay -clock virt_clk_usb -max [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {DQ[*]}]
set_input_delay -clock virt_clk_usb -max [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {DMA0_Ready}]
set_input_delay -clock virt_clk_usb -max [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {DMA0_Watermark}]
set_input_delay -clock virt_clk_usb -max [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {DMA1_Ready}]
set_input_delay -clock virt_clk_usb -max [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {DMA1_Watermark}]

set_input_delay -clock virt_clk_usb -min [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {DQ[*]}]
set_input_delay -clock virt_clk_usb -min [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {DMA0_Ready}]
set_input_delay -clock virt_clk_usb -min [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {DMA0_Watermark}]
set_input_delay -clock virt_clk_usb -min [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {DMA1_Ready}]
set_input_delay -clock virt_clk_usb -min [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {DMA1_Watermark}]


#creating the output delay referencing the virtual clock
#specify the maximum external clock delay to the FPGA
set CLKBs_max [expr $Len*0.007]
#specify the minimum external clock delay to the FPGA
set CLKBs_min [expr $Len*0.007]
#specify the maximum external clock delay to the external device
set CLKBd_max 0.0
#specify the minimum external clock delay to the external device
set CLKBd_min 0.0
#specify the maximum setup time of the external device
set tSUb 2
#specify the hold time of the external device
set tHb 0.5
#specify the maximum board delay
set BDb_max [expr $Len*0.007]
#specify the minimum board delay
set BDb_min [expr $Len*0.007]

set_output_delay -clock virt_clk_usb -max [expr $CLKBs_max + $tSUb + $BDb_max - $CLKBd_min] [get_ports {DQ[*]}]
set_output_delay -clock virt_clk_usb -max [expr $CLKBs_max + $tSUb + $BDb_max - $CLKBd_min] [get_ports {RD}]
set_output_delay -clock virt_clk_usb -max [expr $CLKBs_max + $tSUb + $BDb_max - $CLKBd_min] [get_ports {WR}]
set_output_delay -clock virt_clk_usb -max [expr $CLKBs_max + $tSUb + $BDb_max - $CLKBd_min] [get_ports {LastWRData}]
set_output_delay -clock virt_clk_usb -max [expr $CLKBs_max + $tSUb + $BDb_max - $CLKBd_min] [get_ports {OE}]

set_output_delay -clock virt_clk_usb -min [expr $CLKBs_min - $tHb + $BDb_min - $CLKBd_max] [get_ports {DQ[*]}]
set_output_delay -clock virt_clk_usb -min [expr $CLKBs_min - $tHb + $BDb_min - $CLKBd_max] [get_ports {RD}]
set_output_delay -clock virt_clk_usb -min [expr $CLKBs_min - $tHb + $BDb_min - $CLKBd_max] [get_ports {WR}]
set_output_delay -clock virt_clk_usb -min [expr $CLKBs_min - $tHb + $BDb_min - $CLKBd_max] [get_ports {LastWRData}]
set_output_delay -clock virt_clk_usb -min [expr $CLKBs_min - $tHb + $BDb_min - $CLKBd_max] [get_ports {OE}]


#CAM len
set LEN_CAM 70

#create the input delay referencing the virtual clock
#specify the maximum external clock delay from the external
#device
set CLKAs_max 0.0
#specify the minimum external clock delay from the external
#device
set CLKAs_min 0.0
#specify the maximum external clock delay to the FPGA
set CLKAd_max [expr $LEN_CAM*0.007]
#specify the minimum external clock delay to the FPGA
set CLKAd_min [expr $LEN_CAM*0.007]
#specify the maximum clock-to-out of the external device
set tCOa_max $CAM_DATA_DELAY
#specify the minimum clock-to-out of the external device
set tCOa_min 0
#specify the maximum board delay
set BDa_max [expr $LEN_CAM*0.007]
#specify the minimum board delay
set BDa_min [expr $LEN_CAM*0.007]

set_input_delay -add_delay -min -clock_fall -clock [get_clocks {virt_clk_cam}]  [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {HREF_cam}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {virt_clk_cam}]  [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {VSYNC_cam}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {virt_clk_cam}]  [expr $CLKAs_min + $tCOa_min + $BDa_min - $CLKAd_max] [get_ports {data_cam[*]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {virt_clk_cam}]  [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {HREF_cam}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {virt_clk_cam}]  [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {VSYNC_cam}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {virt_clk_cam}]  [expr $CLKAs_max + $tCOa_max + $BDa_max - $CLKAd_min] [get_ports {data_cam[*]}]

set_false_path -from [get_ports {rst_n}] 
set_false_path -to [get_ports {sioc}]
set_false_path -to [get_ports {siod}]
