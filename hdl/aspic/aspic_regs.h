/** @file
 *
 * @brief Register description for
 * ASPIC - SPI controller for GRETA
 */

#ifndef _ASPIC_REGS_H_
#define _ASPIC_REGS_H_

#include <stdint.h>

/** @brief ASPIC registers
 *
 * Offset | Name   | Description
 * ------ | ------ | ----------------------------------------
 * 0x0000 | cap    | Capability register
 * 0x0002 | status | Status register
 * 0x0004 | ctrl   | Control register
 * 0x0006 | scaler | SPI clock scaler register
 * 0x0008 | txdata | SPI transmit data register
 * 0x000a | rxdata | SPI receive data register
 */

struct aspic_regs {
  /** @brief Capability register
   *
   * Bit    | Name   | Description
   * ------ | ------ | ----------------------------------------
   * 0      | dma    | DMA available (R)
   */
  uint16_t cap;  /* 0x0000 */

  /** @brief Status register
   *
   * Bit    | Name   | Description
   * ------ | ------ | ----------------------------------------
   * 0      | tip    | Transfer in progress (R)
   * 1      | tc     | Transfer complete (R, write '1' to clear)
   */
  uint16_t status;  /* 0x0002 */

  /** @brief Control register
   *
   * Bit    | Name   | Description
   * ------ | ------ | ----------------------------------------
   * 0      | ss     | Slave select (RW)
   * 1      | tcim   | Transfer complete interrupt mask (RW)
   */
  uint16_t ctrl;  /* 0x0004 */

  /** @brief SPI clock scaler register
   *
   * Bit    | Name   | Description
   * ------ | ------ | ----------------------------------------
   * 15-0   | reload | Scaler reload value (RW)
   */
  uint16_t scaler;  /* 0x0006 */

  /** @brief SPI transmit data register
   *
   * Bit    | Name   | Description
   * ------ | ------ | ----------------------------------------
   * 15-0   | txdata | Transmit data (RW)
   */
  uint16_t txdata;  /* 0x0008 */

  /** @brief SPI receive data register
   *
   * Bit    | Name   | Description
   * ------ | ------ | ----------------------------------------
   * 15-0   | rxdata | Receive data (R)
   */
  uint16_t rxdata;  /* 0x000a */

};

/* Capability register */
/* DMA available (R) */
#define ASPIC_CAP_DMA_BIT 0
#define ASPIC_CAP_DMA 0x00000001

/* Status register */
/* Transfer in progress (R) */
#define ASPIC_STATUS_TIP_BIT 0
#define ASPIC_STATUS_TIP 0x00000001
/* Transfer complete (R, write '1' to clear) */
#define ASPIC_STATUS_TC_BIT 1
#define ASPIC_STATUS_TC 0x00000002

/* Control register */
/* Slave select (RW) */
#define ASPIC_CTRL_SS_BIT 0
#define ASPIC_CTRL_SS 0x00000001
/* Transfer complete interrupt mask (RW) */
#define ASPIC_CTRL_TCIM_BIT 1
#define ASPIC_CTRL_TCIM 0x00000002

/* SPI clock scaler register */
/* Scaler reload value (RW) */
#define ASPIC_SCALER_RELOAD_BIT 0
#define ASPIC_SCALER_RELOAD 0x0000ffff

/* SPI transmit data register */
/* Transmit data (RW) */
#define ASPIC_TXDATA_TXDATA_BIT 0
#define ASPIC_TXDATA_TXDATA 0x0000ffff

/* SPI receive data register */
/* Receive data (R) */
#define ASPIC_RXDATA_RXDATA_BIT 0
#define ASPIC_RXDATA_RXDATA 0x0000ffff

#endif

