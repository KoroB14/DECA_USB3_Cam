#include "cyu3types.h"
#include "cyu3system.h"
#include "cyu3pib.h"
#include "cyu3gpif.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3usbconst.h"
#include "cyu3lpp.h"
#include "cyu3gpio.h"
#include "cyu3usb.h"
#include "cyu3uart.h"
#include "cyu3utils.h"
#include "cyu3externcstart.h"

#define MAXCLOCKVALUE		(8)	// 800/MAXCLOCKVALUE = 100MHz


#define STANDARD_REQUEST	(0)

#define APPLICATION_THREAD_STACK	(0x1000)
#define APPLICATION_THREAD_PRIORITY	(8)

#define USB_CONSUMER_ENDPOINT			(0x81)    /* EP 1 IN */
#define USB_CONSUMER_ENDPOINT_SOCKET	(CY_U3P_UIB_SOCKET_CONS_1)
#define USB_PRODUCER_ENDPOINT			(0x02)    /* EP 2 OUT */
#define USB_PRODUCER_ENDPOINT_SOCKET	(CY_U3P_UIB_SOCKET_PROD_2)

#define GPIF_PRODUCER_SOCKET			(CY_U3P_PIB_SOCKET_0)
#define GPIF_CONSUMER_SOCKET			(CY_U3P_PIB_SOCKET_1)

/* Burst length in 1 KB packets. Only applicable to USB 3.0. */
#define ENDPOINT_BURST_LENGTH	(8)

/* DMA buffers used by the application. */
#define DMA_BUFFER_SIZE			(16384)
#define DMA_BUFFER_COUNT		(4)

#include "cyu3externcend.h"
