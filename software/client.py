#!/usr/bin/env python
# coding: utf-8

from ctypes import *
import numpy as np
import cv2
import threading
import usb1

#
#Press "s" to save the frame. Press "q" to quit. 
#


#RGB565 to RGB888
def ProcessImageRGB(im_to_show, im_array):
    mask = [0X1F, 0X7E0, 0XF800]
    shift = [3, 3, 8]
    shift2 = [2, 9, 13]
    for i in range(3):
        im = (im_array & mask[i])
        if (i == 0):
            im_to_show[:,:,i] = (im << shift[i]) |  (im >> shift2[i])
        else:
            im_to_show[:,:,i] = (im >> shift[i]) |  (im >> shift2[i])
            
      

        
def ShowImage(im_type, IM_X, IM_Y, DataReady, SecondFrame, im_array1, im_array2, LineError):
       
    im_cnt = 0
    if (im_type == 2):
        im_to_show = np.zeros((IM_Y,IM_X,3),np.uint8)
        win_name = "FPGA video - " + str(IM_X) + "x" + str(IM_Y) + " RGB"
    elif (im_type == 1):
        im_to_show = np.zeros((IM_Y,IM_X),np.uint8)
        win_name = "FPGA video - " + str(IM_X) + "x" + str(IM_Y) + " grayscale"
   
    while (True):
        if (DataReady.isSet()):
            if (SecondFrame.isSet()):
                if (im_type == 2):
                    ProcessImageRGB(im_to_show, im_array1)
                elif (im_type == 1):
                    im_to_show = im_array1
            else:
                if (im_type == 2):
                    ProcessImageRGB(im_to_show, im_array2)
                elif (im_type == 1):
                    im_to_show = im_array2
            DataReady.clear()                 
        
        cv2.imshow(win_name, im_to_show)
                    
        key = cv2.waitKey(5)
            
        if key == ord('s'):
            filename = "Img_" + str(im_cnt)+".png"
            im_to_save = np.array(im_to_show).copy()
            cv2.imwrite(filename,im_to_save)
            im_cnt += 1
            print ("Saved image " + filename)
            
        if key == ord('q') or LineError.isSet():
            break

def main():
    #FSM commands
    GET_CFG = create_string_buffer(b'\x01\x01') #Get image params
    STRT_ST = create_string_buffer(b'\x11\x11') #Start stream
    STOP_ST = create_string_buffer(b'\x0f\x0f') #Stop stream
    #Number of usb transfers
    USB_NUM_TRANSFERS = 64
    #Device name
    init_string = "FPGA Video Stream"
    im_type = 0
    started = False
    r_buf = create_string_buffer(16384)
    handle = None
    context = usb1.USBContext()
    #CYUSB3014
    idVendor = 0x04b4
    idProduct = 0x00f1
    
    for device in context.getDeviceIterator(skip_on_error=True):
        if (device.getVendorID() == idVendor and device.getProductID() == idProduct):
            handle = device.open()
            if (handle.getProduct() == init_string): #Check device name
                break
            else:
                handle.close()
                handle = None
    
    if (handle is None):
        print ("Failed to open device")
        return
    handle.resetDevice()
    handle.claimInterface(0)
    
    handle._bulkTransfer(0x02, byref(GET_CFG),2, 1000)#send 
        
    r_cnt = handle._bulkTransfer(0x81, byref(r_buf),6, 1000)#receive     
    recv_data = r_buf[0:r_cnt]  
      
    if (recv_data[0] == 0xAA):
        im_type = 1
    elif (recv_data[0] == 0xBB):
        im_type = 2
    else:
        print ("Invalid image type")
        return
    
    print ("Im type", im_type)
    IM_X = recv_data[2] + (recv_data[3] << 8)
    print ("Im X", IM_X)
    IM_Y = recv_data[4] + (recv_data[5] << 8)
    print ("Im Y", IM_Y)
        
    if (im_type == 1):
        im_array1 = np.zeros((IM_Y,IM_X),np.uint8)
        im_array2 = np.zeros((IM_Y,IM_X),np.uint8)
        
    elif (im_type == 2):
        im_array1 = np.zeros((IM_Y,IM_X),np.uint16)
        im_array2 = np.zeros((IM_Y,IM_X),np.uint16)
    
    SecondFrame = threading.Event()
    DataReady = threading.Event()
    LineError = threading.Event()
    #Start show image thread
    ShowImageThread = threading.Thread(target=ShowImage, args = (im_type, IM_X, IM_Y, DataReady, SecondFrame, im_array1, im_array2, LineError))
    ShowImageThread.daemon = True
    ShowImageThread.start()
    
    
    transfer_list = []
    #Buffer processing callback
    cb = ProcessImage(IM_X, IM_Y, im_type, DataReady, ShowImageThread, SecondFrame, im_array1, im_array2, LineError)
        
    while (True):
        if (not started):
            handle._bulkTransfer(0x02, byref(STRT_ST),2 , 1000)#send 
            print("Starting stream")
            started = True
            LineError.clear()
        else:
            for _ in range(USB_NUM_TRANSFERS): #fill the transfer queue 
                transfer = handle.getTransfer()
                transfer.setBulk(
                    0x81,
                    16384,
                    callback=cb.ProcessData, #Buffer processing callback 
                    timeout = 1000)
                transfer.submit()
                transfer_list.append(transfer)
        
        
            while  any(x.isSubmitted() for x in transfer_list) and not LineError.isSet():
                context.handleEvents()
            break    
                    
    handle._bulkTransfer(0x02, byref(STOP_ST),2, 1000)#send 
    handle.resetDevice()
    handle.releaseInterface(0)
    handle.close()

class ProcessImage:
    def __init__ (self, IM_X, IM_Y, im_type, DataReady, ShowImageThread, SecondFrame, im_array1, im_array2, LineError):
        self.IM_X = IM_X
        self.IM_Y = IM_Y
        self.im_type = im_type
        self.line_cnt = 0
        self.im_ptr = 0
        self.rem_ptr = 0
        self.DataReady = DataReady
        self.ShowImageThread = ShowImageThread
        self.SecondFrame = SecondFrame
        self.im_array1 = im_array1
        self.im_array2 = im_array2
        self.LineError = LineError
    
    #Buffer processing callback   
    def ProcessData(self, transfer):
        
        buflen = transfer.getActualLength()
        data = transfer.getBuffer()[:buflen]
        buf_step = self.IM_X * self.im_type + 2
        line_in_buf = (buflen - self.im_ptr) // buf_step
        curr_line_in_buf = 0
        if (buflen == 16384):
            if (self.im_ptr != 0):
                if (self.SecondFrame.isSet()):
                    im_array = self.im_array2
                else:
                    im_array = self.im_array1
                im_array[self.line_cnt, (self.rem_ptr - 2) // self.im_type : ] = np.frombuffer(data[0: self.im_ptr],  dtype='>u2' if self.im_type == 2 else np.uint8)
                
                    
            for pack_ptr in range(self.im_ptr, buflen, buf_step):
                if (self.SecondFrame.isSet()):
                    im_array = self.im_array2
                else:
                    im_array = self.im_array1
                line_cnt_old = self.line_cnt
                self.line_cnt = data[pack_ptr] + (data[pack_ptr + 1] << 8)
                
                if (self.line_cnt > self.IM_Y - 1):
                    self.LineError.set()
                    print("Error in line counter", self.line_cnt)
                    print("Previous line counter", line_cnt_old)
                    print("Pack ptr", pack_ptr)
                    return
                
                if (curr_line_in_buf < line_in_buf):
                    im_array[self.line_cnt] = np.frombuffer(data[(pack_ptr + 2)  : (pack_ptr + buf_step) ],  dtype='>u2' if self.im_type == 2 else np.uint8)
                    if ((pack_ptr + buf_step) == 16384):
                        self.rem_ptr = 0
                        self.im_ptr = 0
                else:
                    self.rem_ptr = (buflen - self.im_ptr) % buf_step
                    self.im_ptr = buf_step - self.rem_ptr
                    im_array[self.line_cnt, 0 : (self.rem_ptr - 2) // self.im_type] = np.frombuffer(data[buflen - self.rem_ptr + 2 : buflen],  dtype='>u2' if self.im_type == 2 else np.uint8)
                   
                if (self.line_cnt == self.IM_Y - 1):
                        if (self.SecondFrame.isSet()):
                            self.SecondFrame.clear()
                        else:
                            self.SecondFrame.set()
                        
                        self.DataReady.set()
                                    
                curr_line_in_buf += 1
        
        if (self.ShowImageThread.is_alive() and not self.LineError.isSet()):
            transfer.submit()   


if __name__ == '__main__':
    main()
    
    
