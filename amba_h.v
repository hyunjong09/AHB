//`defines specified by AMBA
//for masters
//the maximum number of masters
`define N_MAX_MASTER 16
//W_MAX_MASTERS logs(N_MAX_MASTER)
`define W_MAX_MASTER 4
//the width of signals
`define W_TRANS 2
	`define TRANS_IDLE 0
	`define TRANS_BUSY 1
	`define TRANS_NONSEQ 2
	`define TRANS_SEQ 3
`define W_BURST 3 
	`define BURST_SINGLE 0
	`define BURST_INCR 1
	`define BURST_WRAP4 2
	`define BURST_INCR4 3
	`define BURST_WRAP8 4
	`define BURST_INCR8 5
	`define BURST_WRAP16 6
	`define BURST_INCR16 7
`define W_SIZE 3
	`define SIZE_BYTE 0
	`define SIZE_HALFWORD 1
	`define SIZE_WORD 2
	`define SIZE_DWORD 3
	`define SIZE_DDWORD 4
	`define SIZE_TDWORD 5
	`define SIZE_QDWORD 6
	`define SIZE_FDWORD 7
`define W_PROT 4
	//HPROT[0]
	`define IX_PROT_DATA 0
	`define PROT_OPCODE 1'b0
	`define PROT_DATA 1'b1
	//HPROT[1]
	`define IX_PROT_PREVILEGED 1
	`define PROT_USER 1'b0
	`define PROT_PREVILEGED 1'b1
	//HPROT[2]
	`define IX_PROT_BUF 2
	`define PROT_UNBUF 1'b0
	`define PROT_BUF 1'b1
	//HPROT[3]
	`define IX_PROT_CACHEABLE 3
	`define PROT_NOTCACHE 1'b0
	`define PROT_CACHEABLE 1'b1
`define W_RESP 2
	`define RESP_OKAY 0
	`define RESP_ERROR 1
	`define RESP_RETRY 2
	`define RESP_SPLIT 3