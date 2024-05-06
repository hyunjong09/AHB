`include "ahb_macro_h.v"
module DMAC_MASTER (
    // 입력 포트
	input m_HCLK,
	input m_HRESETn,
    input [11:0] TS,
    input [2:0] BS,
    input CHANNEL_enable,
    input DMACINTR_mask,
    input DMACINTR_pend,
    input sync_grant,
    input dmac_buffer_idx,
    input src_addr_inc,
    input [31:0] DMAC_C0_SrcAddr_Master,
    input [31:0] DMAC_C0_DestAddr_Master,
    input src_burst_cnt,
    input dest_burst_cnt,

    // 출력 포트
    output reg CHANNEL_dis_flag,
    output reg buffer_zero_flag,
    output reg load_DMAC_C0_Addr,
    output reg TransferSize_dec_flag,
    output reg src_burst_zero_flag,
    output reg dest_burst_zero_flag,
    output reg set_DMACINTR_status,
    output reg src_addr_inc,
    output reg dest_addr_inc,
    output reg m_HGRANT
);

// 입력 포트
input m_HCLK;
input m_HRESETn;
input [11:0] TS;
input [2:0] BS;
input CHANNEL_enable;
input DMACINTR_mask;
input DMACINTR_pend;
input sync_grant;
input dmac_buffer_idx;
input src_addr_inc;
input [31:0] DMAC_C0_SrcAddr_Master;
input [31:0] DMAC_C0_DestAddr_Master;
input src_burst_cnt;
input dest_burst_cnt;

// 출력 포트
output reg CHANNEL_dis_flag;
output reg buffer_zero_flag;
output reg load_DMAC_C0_Addr;
output reg TransferSize_dec_flag;
output reg src_burst_zero_flag;
output reg dest_burst_zero_flag;
output reg set_DMACINTR_status;
output reg src_addr_inc;
output reg dest_addr_inc;
output reg m_HGRANT;

reg [2:0] mns, mps;

//master state parameter 설정
parameter MA_IDLE_S =0;
parameter MA_REQ_S = 1;
parameter MA_READ_S = 2;
parameter MA_RDATA_S = 3;
parameter MA_WRITE_S = 4;
parameter MA_WDATA_S = 5;

//master fsm 시작
always @(posedge m_HCLK or negedge m_HRESETn) 
begin
	if(!m_HRESETn)  mps <= MA_IDLE_S; 
	else  mps <= mns; 
end

//FSM next state
always @(*) 
begin
	case(mps)
		MA_IDLE_S : begin
			if((CHANNEL_enable ==1'b1) && (DMAC_Configuration[0] ==1'b1))
				mns <= MA_REQ_S;
			else mns <= mps;
		end
		MA_REQ_S : begin
			if(HREADY == 1'b1) mns <= MA_READ_S;
			else mns <= mps;
		end
		MA_READ_S : begin
			if((sync_grant == 1'b1) && (HREADY == 1'b1)) mns <= MA_RDATA_S;
			else mns <= mps;
		end
		MA_RDATA_S : begin
			if((src_burst_cnt >= ahb_burst_size) && (sync_grant != 1'b1) && (HREADY == 1'b1)) mns <= MA_WRITE_S;
			else if((src_burst_cnt >= ahb_burst_size) && (sync_grant == 1'b1) && (HREADY == 1'b1)) mns <= MA_WDATA_S;
			else mns <= mps; //m_HREADY? 0??? src_burst_cnt < ahb_burst_size ?? ?? ?. ??? output ???? ??? ?? ? ?? ?.
		end
      MA_WRITE_S : begin
         if((sync_grant == 1'b1) && (HREADY == 1'b1)) mns <= MA_WDATA_S;
         else mns <= mps;
      end
      MA_WDATA_S : begin
         if((HREADY == 1'b1) && (TS!=0) &&(dest_burst_cnt >=ahb_burst_size)) mns <= MA_READ_S;
         else if((HREADY == 1'b1) &&(TS == 0)) mns <= MA_REQ_S;
         else mns <= mps;  //m_HREADY? 0 ??? dest_burst_cnt < ahb_burst_size ??? TramnsferSize? 0? ??.
      end
      default : mns <= MA_REQ_S; // default? REQ state? ??? ? ? mps ???? ? ??
   endcase
end

//FSM output block
always @(*) 
begin  
   case(mps)
     MA_IDLE_S : begin
      if(mns== MA_REQ_S) begin
            m_HBUSREQ <= 1'b1;
      end
      else begin
         m_HBUSREQ <=1'b0;
      end
      end  
      MA_REQ_S : begin
         if(mns == MA_READ_S) begin
            //REQFunc;
            case(BS)
               3'b000 : begin
                  ahb_burst <= `SINGLE;
                  ahb_burst_size <= 1;
               end
               3'b001 : begin
                  ahb_burst <= `INCR4;
                  ahb_burst_size <= 4;
               end
               3'b010 : begin
                  ahb_burst <= `INCR8;
                  ahb_burst_size <= 8;
               end
               default : begin
                  ahb_burst <= `INCR16;
                  ahb_burst_size <= 16;
               end
            endcase
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 32'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;  //parameter ?? ?? 
            m_HBURST <= ahb_burst; //?? ???? ??? ?? loop ???
            m_HWDATA <= 32'b0;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 1;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 1;
            dest_burst_zero_flag <= 1;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
         end
         else begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 32'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            m_HWDATA <= 32'b0;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
         end
      end
      MA_READ_S : begin
         if(mns == MA_RDATA_S) begin
            src_addr_inc <= 1;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `NONSEQ;
            m_HADDR <= DMAC_C0_SrcAddr_Master;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            m_HWDATA <= 32'b0;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 1; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
            //READfunc;
         end
         else begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 32'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            m_HWDATA <= 32'b0;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
         end
      end
      MA_RDATA_S : begin
         if(mns == MA_WRITE_S) begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 32'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 1;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b1;
            load_fir_src_img <= 1'b1;
            set_DMACINTR_status <= 1'b0;
            //RDATA function
         end   
         else if(mns==MA_WDATA_S) begin
            src_addr_inc <= 0;
            dest_addr_inc <= 1;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `NONSEQ;
            m_HADDR <= DMAC_C0_DestAddr_Master;
            m_HWRITE <= 1'b1;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 1; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 1;
            src_burst_zero_flag <= 1;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b1;
            load_fir_src_img <= 1'b1;
            set_DMACINTR_status <= 1'b0;
            //RDATA function WRITE function
         end
         else begin //?? ????? RDATA ????? ??
            if(src_burst_cnt < ahb_burst_size) begin
               dest_addr_inc <= 0;
               m_HBUSREQ <= 1'b1;
               m_HLOCK <= 1'b0;
               m_HTRANS <= `SEQ;
               m_HADDR <= DMAC_C0_SrcAddr_Master;
               m_HWRITE <= 1'b0;
               m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
               m_HBURST <= ahb_burst;
               m_HWDATA <= 32'b0;
               CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
               buffer_zero_flag <= 0; 
               load_DMAC_C0_Addr <= 0;
               TransferSize_dec_flag <= 0;
               src_burst_zero_flag <= 0;
               dest_burst_zero_flag <= 0;
               set_DMACINTR_status <= 1'b0;
               if(HREADY == 1'b1) begin
                  src_addr_inc <= 1'b1;
                  load_fir_src_img <= 1'b1;
                  buffer_idx_inc <= 1'b1;
               end
               else begin //src_burst_cnt < ahb_burst_size ?? ????? HREADY? 0? ??
                  src_addr_inc <= 1'b0;
                  load_fir_src_img <= 1'b0;
                  buffer_idx_inc <= 1'b0;
               end
            end 
            else begin  //src_burst_cnt < ahb_burst_size ?? ??? ???? HREADY? 0? ?? ??
               dest_addr_inc <= 0;
               m_HBUSREQ <= 1'b1;
               m_HLOCK <= 1'b0;
               m_HTRANS <= `SEQ;
               m_HADDR <= DMAC_C0_SrcAddr_Master;
               m_HWRITE <= 1'b0;
               m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
               m_HBURST <= ahb_burst;
               m_HWDATA <= 32'b0;
               CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
               buffer_zero_flag <= 0; 
               load_DMAC_C0_Addr <= 0;
               TransferSize_dec_flag <= 0;
               src_burst_zero_flag <= 0;
               dest_burst_zero_flag <= 0;
               set_DMACINTR_status <= 1'b0;
               src_addr_inc <= 1'b0;
               load_fir_src_img <= 1'b0;
               buffer_idx_inc <= 1'b0;
            end
         end
      end
      MA_WRITE_S : begin
         if(mns == MA_WDATA_S) begin
            src_addr_inc <= 0;
            dest_addr_inc <= 1;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `NONSEQ;
            m_HADDR <= DMAC_C0_DestAddr_Master;
            m_HWRITE <= 1'b1;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 1; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 1;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
            //WRITE function
         end
         else begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 32'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
         end
      end
      MA_WDATA_S : begin
         if(mns == MA_READ_S) begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 32'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 1;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
            if(TS[11:2]<ahb_burst_size) begin
               ahb_burst_size <= TS[11:2];
               ahb_burst <= `INCR;
            end
            else begin
               ahb_burst_size <= ahb_burst_size;
               ahb_burst <= ahb_burst;
            end
         end
         else if(mns == MA_REQ_S) begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b0;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 1'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 1; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 1'b1;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b1;
         end
         else begin  //dest_burst_cnt < ahb_burst_size ???  
            src_addr_inc <= 0;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `SEQ;
            m_HADDR <= DMAC_C0_DestAddr_Master;
            m_HWRITE <= 1'b1;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;   
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
            if(HREADY == 1) begin
               dest_addr_inc <= 1'b1;
               buffer_idx_inc <= 1'b1;
               TransferSize_dec_flag <= 1'b1;
            end
            else begin
               dest_addr_inc <= 1'b0;
               buffer_idx_inc <= 1'b0;
               TransferSize_dec_flag <= 1'b0;
            end
            if(TS == 4) begin
               m_HBUSREQ <= 1'b0;
            end
            else begin
               m_HBUSREQ <= 1'b1;
            end
         end
      end
      default : begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 1'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;//parameter ?? ?? 
            m_HBURST <= ahb_burst;
            m_HWDATA <= 32'b0;
            CHANNEL_dis_flag <= 0; //?? register? ? ? bit???
            buffer_zero_flag <= 0; 
            load_DMAC_C0_Addr <= 0;
            TransferSize_dec_flag <= 0;
            src_burst_zero_flag <= 0;
            dest_burst_zero_flag <= 0;
            buffer_idx_inc <= 1'b0;
            load_fir_src_img <= 1'b0;
            set_DMACINTR_status <= 1'b0;
      end
   endcase
end