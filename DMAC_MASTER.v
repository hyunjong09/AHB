`include "ahb_macro_h.v"
module DMAC_MASTER (
    // 입력 포트
    m_HCLK,
    m_HRESETn,
    m_HREADY,
	m_HRDATA,
    TS,
    BS,
    CHANNEL_enable,
    DMACINTR_mask,
    DMACINTR_pend,
	DMACINTR_status,
    sync_grant,
    dmac_buffer_idx,
    DMAC_C0_SrcAddr_Master,
    DMAC_C0_DestAddr_Master,
    src_burst_cnt,
    dest_burst_cnt,

    // 출력 포트
    CHANNEL_dis_flag,
    buffer_zero_flag,
	buffer_idx_inc,
    load_DMAC_C0_Addr,
    TransferSize_dec_flag,
    src_burst_zero_flag,
    dest_burst_zero_flag,
    src_addr_inc,  
    dest_addr_inc,
	load_fir_src_img,
    m_HTRANS,
    m_HBURST,
    m_HSIZE,
    m_HADDR,
    m_HWRITE,
    m_HWDATA,
    m_HPROT,
    m_HLOCK,
    m_HBUSREQ,
	
    DMACINTR,
	clr_DMACINTR_status,
	set_DMACINTR_status
);

// 입력 포트
input m_HCLK;
input m_HRESETn;
input m_HREADY;
input [31:0] m_HRDATA;
input [11:0] TS;
input [2:0] BS;
input CHANNEL_enable;
input DMACINTR_mask;
input DMACINTR_pend;
input sync_grant;
input [4:0] dmac_buffer_idx;
input [31:0] DMAC_C0_SrcAddr_Master;
input [31:0] DMAC_C0_DestAddr_Master;
input [4:0] src_burst_cnt;
input [4:0] dest_burst_cnt;

// 출력 포트
output reg CHANNEL_dis_flag;
output reg buffer_zero_flag;
output reg buffer_idx_inc;
output reg load_DMAC_C0_Addr;
output reg TransferSize_dec_flag;
output reg src_burst_zero_flag;
output reg dest_burst_zero_flag;
output reg set_DMACINTR_status;
output reg src_addr_inc;
output reg dest_addr_inc;
output reg load_fir_src_img;
output reg clr_DMACINTR_status;

output reg [1:0] m_HTRANS;
output reg [2:0] m_HBURST; 
output reg [2:0] m_HSIZE;
output reg [31:0] m_HADDR;
output reg m_HWRITE; 
output reg [31:0] m_HWDATA; 
output reg [3:0] m_HPROT;
output reg m_HLOCK; 
output reg m_HBUSREQ; 
output reg DMACINTR;
output reg DMACINTR_status;

reg [2:0] mns, mps;
integer ahb_burst_size;
reg [2:0] ahb_burst;
reg [31:0] DMAC_buffer[15:0]  ;

reg clr_DMACINTR_pend;

//master state parameter 설정
parameter MA_IDLE_S =0;
parameter MA_REQ_S = 1;
parameter MA_READ_S = 2;
parameter MA_RDATA_S = 3;
parameter MA_WRITE_S = 4;
parameter MA_WDATA_S = 5;


//DMACINTR block1
always @(posedge m_HCLK or negedge m_HRESETn) 
begin
	if(DMACINTR_pend==1'b1) begin
		clr_DMACINTR_status <=1'b1;
		clr_DMACINTR_pend <= 1'b1;
	end
	else begin
		clr_DMACINTR_pend <=1'b0;
		clr_DMACINTR_status <=1'b0;
	end
end

//DMACINTR block2
always @(posedge m_HCLK or negedge m_HRESETn) 
begin
	if((DMACINTR_status==1'b1 && DMACINTR_mask==1'b1)) begin
		DMACINTR <=1'b1;
	end
	else begin
		DMACINTR <=1'b0;
	end
end

//DMACINTR block3
always @(posedge m_HCLK or negedge m_HRESETn) 
begin
	if(clr_DMACINTR_status==1'b1) begin
		DMACINTR_status <=1'b0;
	end
	else if((set_DMACINTR_status==1'b1 && clr_DMACINTR_status!=1'b1)) begin
		DMACINTR_status <=1'b1;
	end else begin
		DMACINTR_status <= 1'b0;
	end
end



//sequencial logic(dmac_buffer_idx
always @(posedge m_HCLK)
begin
	if(mps==MA_RDATA_S) begin
		DMAC_buffer[dmac_buffer_idx] <= m_HRDATA;
	end
	else begin
		DMAC_buffer[dmac_buffer_idx] <= DMAC_buffer[dmac_buffer_idx];
	end
end

always @(*)
begin
	if(mps==MA_WDATA_S) begin
		m_HWDATA <= DMAC_buffer[dmac_buffer_idx];
	end
	else begin
		m_HWDATA <= m_HWDATA;
	end
end

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
			if(CHANNEL_enable ==1'b1)
				mns <= MA_REQ_S;
			else mns <= mps;
		end
		MA_REQ_S : begin
			if(m_HREADY == 1'b1) mns <= MA_READ_S;
			else mns <= mps;
		end
		MA_READ_S : begin
			if((sync_grant == 1'b1) && (m_HREADY == 1'b1)) mns <= MA_RDATA_S;
			else mns <= mps;
		end
		MA_RDATA_S : begin
			if((src_burst_cnt >= ahb_burst_size) && (sync_grant != 1'b1) && (m_HREADY == 1'b1)) mns <= MA_WRITE_S;
			else if((src_burst_cnt >= ahb_burst_size) && (sync_grant == 1'b1) && (m_HREADY == 1'b1)) mns <= MA_WDATA_S;
			else mns <= mps; 
		end
		MA_WRITE_S : begin
			if((sync_grant == 1'b1) && (m_HREADY == 1'b1)) mns <= MA_WDATA_S;
			else mns <= mps;
		end
		MA_WDATA_S : begin
			if((m_HREADY == 1'b1) && (TS!=0) &&(dest_burst_cnt >=ahb_burst_size)) mns <= MA_READ_S;
			else if((m_HREADY == 1'b1) &&(TS == 0)) mns <= MA_REQ_S;
			else mns <= mps;  
		end
		default : mns <= MA_REQ_S; 
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
               if(m_HREADY == 1'b1) begin
                  src_addr_inc <= 1'b1;
                  load_fir_src_img <= 1'b1;
                  buffer_idx_inc <= 1'b1;
               end
               else begin //src_burst_cnt < ahb_burst_size ?? ????? m_HREADY? 0? ??
                  src_addr_inc <= 1'b0;
                  load_fir_src_img <= 1'b0;
                  buffer_idx_inc <= 1'b0;
               end
            end 
            else begin  //src_burst_cnt < ahb_burst_size ?? ??? ???? m_HREADY? 0? ?? ??
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
            if(m_HREADY == 1) begin
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



endmodule