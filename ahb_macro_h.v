/*----------------------------------------------------------------------------
 AHB transfer type macros
----------------------------------------------------------------------------*/
`define IDLE 2'b00
`define BUSY 2'b01
`define NONSEQ 2'b10
`define SEQ 2'b11
/*----------------------------------------------------------------------------
 AHB burst type macros
----------------------------------------------------------------------------*/
`define SINGLE 3'b000	// Single Transfer
`define INCR 3'b001	// Unspecified incrementing
`define WRAP4 3'b010	// 4-beat wrapping
`define INCR4 3'b011	// 4-beat incrementing
`define WRAP8 3'b100	// 8-beat wrapping
`define INCR8 3'b101	// 8-beat incrementing
`define WRAP16 3'b110	// 16-beat wrapping
`define INCR16 3'b111	// 16-beat incrementing
/*----------------------------------------------------------------------------
 AHB hresp macros
----------------------------------------------------------------------------*/
`define OKAY 2'b00
`define ERROR 2'b01
`define RETRY 2'b10
`define SPLIT 2'b11
/*----------------------------------------------------------------------------
 AHB transfer size macros
----------------------------------------------------------------------------*/
`define AHB_BYTE 3'b000
`define AHB_HALF 3'b001
`define AHB_WORD 3'b010
/*----------------------------------------------------------------------------
 AHB hwrite macros
----------------------------------------------------------------------------*/
`define AHB_WRITE 1'b1
`define AHB_READ 1'b0
/*----------------------------------------------------------------------------
 AHB hprot macros
----------------------------------------------------------------------------*/
//HPROT[0]
`define PROT_OPCODE 1'b0
`define PROT_DATA 1'b1
//HPROT[1]
`define PROT_USER 1'b0
`define PROT_PREVILEGED 1'b1
//HPROT[2]
`define PROT_UNBUF 1'b0
`define PROT_BUF 1'b1
//HPROT[3]
`define PROT_NOTCACHE 1'b0
`define PROT_CACHEABLE 1'b1
