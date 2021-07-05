/******************************************************************************
 *
 * Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */
#include <stdbool.h>
#include <stdio.h>

#include "platform.h"
#include "xaxidma.h"
#include "xbasic_types.h"
#include "xdebug.h"
#include "xparameters.h"

#ifdef __aarch64__
#include "xil_mmu.h"
#endif

#if defined(XPAR_UARTNS550_0_BASEADDR)
#include "xuartns550_l.h" /* to use uartns550 */
#endif

#ifndef DEBUG
extern void xil_printf(const char *format, ...);
#endif

/******************** Constant Definitions **********************************/
/*********************** TEMPORARY ******************************************/
/*
 * Device hardware build related constants.
 */
#define DMA_BASE_ADDR XPAR_AXIDMA_0_BASEADDR
#define DMA_DEV_ID XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif defined(XPAR_MIG7SERIES_0_BASEADDR)
#define DDR_BASE_ADDR XPAR_MIG7SERIES_0_BASEADDR
#elif defined(XPAR_MIG_0_BASEADDR)
#define DDR_BASE_ADDR XPAR_MIG_0_BASEADDR
#elif defined(XPAR_PSU_DDR_0_S_AXI_BASEADDR)
#define DDR_BASE_ADDR XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
		DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR 0x01000000
#else
#define MEM_BASE_ADDR (DDR_BASE_ADDR + 0x1000000)
#endif

#define TX_BD_SPACE_BASE (MEM_BASE_ADDR)
#define TX_BD_SPACE_HIGH (MEM_BASE_ADDR + 0x00000FFF)
#define RX_BD_SPACE_BASE (MEM_BASE_ADDR + 0x00001000)
#define RX_BD_SPACE_HIGH (MEM_BASE_ADDR + 0x00001FFF)
#define TX_BUFFER_BASE (MEM_BASE_ADDR + 0x00020000)
#define RX_BUFFER_BASE (MEM_BASE_ADDR + 0x00030000)
#define RX_BUFFER_HIGH (MEM_BASE_ADDR + 0x0003FFFF)

#define MAX_U32_PKT_LEN 4194304
//#define MAX_U16_PKT_LEN 4096*8
#define MAX_PKT_LEN MAX_U32_PKT_LEN * 4
#define NUMBER_OF_PACKETS 5
#define NUMBER_OF_TRANSFERS 40

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/
#if defined(XPAR_UARTNS550_0_BASEADDR)
static void Uart550_Setup(void);
#endif

int XAxiDma_SimplePollRxSetup(u16 DeviceId);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XAxiDma AxiDma;
/*
 * Buffer for transmit packet.
 */
u32 *Packet = (u32 *)TX_BUFFER_BASE;

static XAxiDma_Bd *LastRxBdPtr = NULL;

/****************************** Main function *********************************/

Xuint32 *baseaddr_p = (Xuint32 *)XPAR_MUX_RO_VARIANCE_0_S00_AXI_BASEADDR;

int main(void) {

  init_platform();
  // u16 *RxPacket;
  u32 *RxPacket;
  int Index = 0;
  u8 *RxBufferPtr;
  int Status;
  // RxPacket = (u16 *) RX_BUFFER_BASE;
  RxPacket = (u32 *)RX_BUFFER_BASE;
  Status = XAxiDma_SimplePollRxSetup(DMA_DEV_ID);

  int i;
  int j;
  int k;

  /* map between hw <-> sw:
   * data_from_ps0  <-> base_addr_p + 0
   * data_from_ps1  <-> base_addr_p + 1
   * data_to_ps0    <-> base_addr_p + 3
   * data_to_ps1    <-> base_addr_p + 2
   */

  int count = 0;
  const nb_sets = 32;
  const nb_params = 64;
  const nb_results = 1;
  int result;

  int enable_mask = 0b10000000000000000000000000000000;
  int disable_mask = ~enable_mask;

  int select_ro1_mask = 0b00000000000000000010000000000000;
  int select_ro0_mask = ~select_ro1_mask;

  int select_cscnt_mask = 0b00000000000000000001000000000000;
  int deselect_cscnt_mask = ~select_cscnt_mask;

  int dma_done_mask = 0b10000000000000000000000000000000;

  int matched_mask = 0b01000000000000000000000000000000;
  int failed_mask = 0b00100000000000000000000000000000;

  RxBufferPtr = (u8 *)RX_BUFFER_BASE;

  /* Invalidate the DestBuffer before receiving the data, in case the
   * Data Cache is enabled
   */
  Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);

  xil_printf("Start test\n");

  const trng = 0;
  const control_0 = 1;
  const control_1 = 33;

  for (i = trng; i < trng + 1; ++i) {

    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)RxBufferPtr, MAX_PKT_LEN,
                                    XAXIDMA_DEVICE_TO_DMA);

    if (Status != XST_SUCCESS) {
      xil_printf("Error %d\r\n", Status);
      return XST_FAILURE;
    }

    *(baseaddr_p + 0) =
        i << 25 | ((j << 6) + k) | enable_mask | select_cscnt_mask;

    while ((*(baseaddr_p + 3) & dma_done_mask) == 0) {
      if ((*(baseaddr_p + 3) & failed_mask) >> 29 == 1) {
        xil_printf("Failed\r\n");
        break;
      }
      /* Wait */
    }

    while (XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA)) {
      /* Wait */
    }

    xil_printf("Time passed\r\n");
    xil_printf("%d\r\n", *(baseaddr_p + 2));
    xil_printf("Start cscnt %d\r\n", i);

    /* Invalidate the DestBuffer before receiving the data, in case the
     * Data Cache is enabled
     */
    Xil_DCacheInvalidateRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);

    for (Index = 0; Index < MAX_U32_PKT_LEN; Index++) {
      xil_printf("%x\n", RxPacket[Index]);
    }

    *(baseaddr_p + 0) = i << 25 | j << 6 & enable_mask & deselect_cscnt_mask;
    while ((*(baseaddr_p + 3) & dma_done_mask) == dma_done_mask) {
      /* Wait */
    }
  }

  xil_printf("End test\r\n");

  return 0;
}

int XAxiDma_SimplePollRxSetup(u16 DeviceId) {
  XAxiDma_Config *CfgPtr;
  int Status;
  u8 *RxBufferPtr;

  RxBufferPtr = (u8 *)RX_BUFFER_BASE;

  /* Initialize the XAxiDma device.
   */
  CfgPtr = XAxiDma_LookupConfig(DeviceId);
  if (!CfgPtr) {
    xil_printf("No config found for %d\r\n", DeviceId);
    return XST_FAILURE;
  }

  Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
  if (Status != XST_SUCCESS) {
    xil_printf("Initialization failed %d\r\n", Status);
    return XST_FAILURE;
  }

  if (XAxiDma_HasSg(&AxiDma)) {
    xil_printf("Device configured as SG mode \r\n");
    return XST_FAILURE;
  }

  /* Disable interrupts, we use polling mode
   */
  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

  /* Flush the buffers before the DMA transfer, in case the Data Cache
   * is enabled
   */
  Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);

  /* Test finishes successfully
   */
  return XST_SUCCESS;
}
