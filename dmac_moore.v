`include "ahb_macro_h.v"
module DMAC_moore(

                  HCLK, HRESETn, HREADY,
                  //Inputs of DMAC Slave Interface
                  HTRANS, HSEL, HWRITE, HADDR, HWDATA,
                  HSIZE, HBURST,
              //Outputs of DMAC slave Interface
                  s_out_HRDATA, s_out_HRESP, s_out_HREADY,
              
                  //Inputs of DMAC master Interface
                  HRESP, HRDATA, HGRANT,
              
                  //outputs of DMAC master Interface
                  m_HTRANS, m_HBURST, m_HSIZE, m_HADDR,
                  m_HWRITE, m_HWDATA, m_HPROT, m_HLOCK, m_HBUSREQ, 
                  DMACINTR
);
//slave input
input HCLK;
input HRESETn;
input [1:0] HTRANS;
input HSEL;
input HREADY;
input HWRITE;
input [31:0] HADDR;
input [31:0] HWDATA;
input [2:0] HSIZE;
input [3:0] HBURST;
//master input
input [1:0] HRESP;
input [31:0] HRDATA;
input HGRANT;

//slave output
output reg [31:0] s_out_HRDATA;
output reg [1:0] s_out_HRESP;
output reg s_out_HREADY;
//master output
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

reg [3:0] ns, ps;
reg [2:0] sns, sps;

//Slave
reg [11:0] DMAC_HADDR_REG;
reg write_out_reg;
reg load_ahb_addr;



//master
integer src_burst_cnt; 
integer dest_burst_cnt; //한번 read를 했을 때 1 증가하는 카운터
integer ahb_burst_size;  //burst에 맞게 할당 되는 수
reg src_addr_inc;
reg dest_addr_inc;
reg load_fir_src_img;
reg [2:0] ahb_burst;

reg CHANNEL_dis_flag;
reg buffer_zero_flag;
reg load_DMAC_C0_Addr;
reg TransferSize_dec_flag;
reg src_burst_zero_flag;
reg dest_burst_zero_flag;
reg set_DMACINTR_status;
reg [31:0] DMAC_C0_SrcAddr_Master;
reg [31:0] DMAC_C0_DestAddr_Master;
reg [15:0] [31:0]DMAC_buffer ;

//register bank
reg [31:0] DMAC_Configuration;
reg [31:0] DMAC_C0_SrcAddr;
reg [31:0] DMAC_C0_DestAddr;
reg [31:0] DMAC_C0_Control;
reg [31:0] DMAC_C0_Configuration;
reg sync_grant;
reg [11:0] TS;
reg [2:0] BS;
reg CHANNEL_enable;
reg DMACINTR_mask;
reg DMACINTR_pend;
integer dmac_buffer_idx;
reg buffer_idx_inc;

//parameter
parameter MA_IDLE_S = 13;
parameter MA_REQ_S  = 0;
parameter MA_READ_S = 1;
parameter MA_READ_WAIT_S = 2;
parameter MA_RDATA_S = 3;
parameter MA_RDATA_NR_S = 4;
parameter MA_WRITE_GR_S = 5;
parameter MA_WRITE_WAIT_S = 6;
parameter MA_WRITE_GR_NR_S = 7;
parameter MA_WDATA_S = 8;
parameter MA_WDATA_NR_S = 9;
parameter MA_WDATA_FIN_NR_S = 10;
parameter MA_TS_LEFT_S = 11;
parameter MA_TS_FIN_S = 12;

parameter SDMAC_IDLE_S = 4;
parameter SDMAC_ADDR_S = 0;
parameter SDMAC_WRITE_S = 1;
parameter SDMAC_READ_S = 2;
parameter SDMAC_ERROR_S = 3;


////-----------------------------------------FSM external logic---------------------------------------------------------------------//// 

//sequencial logic(DMAC_HADDR_REG를 update 해 줌)
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      DMAC_HADDR_REG <= 0;
   end
    else begin
      if(load_ahb_addr == 1'b1) begin
         DMAC_HADDR_REG <= HADDR[11:0];
      end 
      else begin
         DMAC_HADDR_REG <= DMAC_HADDR_REG;
      end
   end
end

//sequencial logic(Register Bank 내부의 register 5개의 각 비트에 값 update)
always @(posedge HCLK or negedge HRESETn)
begin
   if(write_out_reg == 1'b1) begin
        case(DMAC_HADDR_REG)
         12'h030 : DMAC_Configuration <= {31'b0,HWDATA[0]};
            12'h100 : DMAC_C0_SrcAddr <= HWDATA;
            12'h104 : DMAC_C0_DestAddr <= HWDATA;
            12'h10C : DMAC_C0_Control <= {17'b0,HWDATA[14:0]}; 
            12'h110 : DMAC_C0_Configuration <= {29'b0,HWDATA[2:0]};
            default : begin
            DMAC_Configuration <= 0;
            DMAC_C0_SrcAddr <= 0;
            DMAC_C0_DestAddr <= 0;
            DMAC_C0_Control <= 0;
            DMAC_C0_Configuration <= 0;
            end
        endcase
    end
    else begin
        DMAC_Configuration <= DMAC_Configuration;
        DMAC_C0_SrcAddr <= DMAC_C0_SrcAddr;
        DMAC_C0_DestAddr <= DMAC_C0_DestAddr;
        DMAC_C0_Control <= DMAC_C0_Control;
        DMAC_C0_Configuration <= DMAC_C0_Configuration;
    end
end

//Register Bank의 각 비트의 offset에 맞게 assign 해 줌
always @(*)
begin
   DMACINTR_pend<=DMAC_C0_Configuration[2];
   DMACINTR_mask<=DMAC_C0_Configuration[1];
   CHANNEL_enable <= DMAC_C0_Configuration[0];
end

//Register Bank의 각 비트의 offset에 맞게 assign 해 줌
always @(*)
begin
   TS <= DMAC_C0_Control[11:0];
   BS <= DMAC_C0_Control[14:12];
end

//Read가 끝나거나 Write가 끝났을 때 CHANNEL_enable을 0 으로 꺼줌.
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      CHANNEL_enable <= 1'b0;
   end
    else begin
      if((CHANNEL_dis_flag==1'b1)&&!((write_out_reg==1'b1)&&(DMAC_HADDR_REG==12'h10C))) begin
         CHANNEL_enable <= 1'b0;
      end 
      else begin
         CHANNEL_enable <= CHANNEL_enable;
      end
   end
end


always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      TS <= 0;
   end
   else begin
      if((TransferSize_dec_flag==1'b1)&&!((write_out_reg==1'b1)&&(DMAC_HADDR_REG==12'h10C))) begin
         TS <= (TS - 4);
      end 
      else begin
         TS<= TS;
      end
   end
end

//sequencial logic(sync_grant)
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      sync_grant <= 1'b0;
   end
    else begin
      if(HGRANT == 1'b1) begin
         sync_grant <= 1'b1;
      end 
      else begin
         sync_grant <= 1'b0;
      end
   end
end

//sequencial logic(dmac_buffer_idx)
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      dmac_buffer_idx <= 1'b0;
   end
    else begin
      if(buffer_zero_flag==1'b1) begin
         dmac_buffer_idx <= 1'b0;
      end 
      else begin
         if(buffer_idx_inc) begin
            dmac_buffer_idx <= dmac_buffer_idx + 1'b1;
         end
         else begin
            dmac_buffer_idx <= dmac_buffer_idx;
         end
      end
   end
end

//sequencial logic(src)
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      src_burst_cnt <= 1'b0;
   end
    else begin
      if(src_burst_zero_flag == 1'b1) begin
         src_burst_cnt <= 1'b0;
      end 
      else begin
         if(src_addr_inc == 1'b1) begin
            src_burst_cnt <= src_burst_cnt + 1'b1;
            DMAC_C0_SrcAddr_Master <= DMAC_C0_SrcAddr_Master + 4;
         end
         else begin
            src_burst_cnt <= src_burst_cnt;
            DMAC_C0_SrcAddr_Master <= DMAC_C0_SrcAddr_Master;      
         end
      end
   end
end

//sequencial logic(dest)
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      dest_burst_cnt <= 1'b0;
   end
    else begin
      if(dest_burst_zero_flag == 1'b1) begin
         dest_burst_cnt <= 1'b0;
      end 
      else begin
         if(dest_addr_inc == 1'b1) begin
            dest_burst_cnt <= dest_burst_cnt + 1'b1;
            DMAC_C0_DestAddr_Master <= DMAC_C0_DestAddr_Master + 4;
         end
         else begin
            dest_burst_cnt <= dest_burst_cnt;
            DMAC_C0_DestAddr_Master <= DMAC_C0_DestAddr_Master;      
         end
      end
   end
end

//sequencial logic(load_master_addr)
always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) begin
      DMAC_C0_DestAddr_Master <= 32'b0;
      DMAC_C0_SrcAddr_Master <= 32'b0;
   end
    else begin
      if(load_DMAC_C0_Addr == 1'b1) begin
      DMAC_C0_DestAddr_Master <= {DMAC_C0_DestAddr[31:2],2'b0};
      DMAC_C0_SrcAddr_Master <= {DMAC_C0_SrcAddr[31:2],2'b0};
      end 
   end
end

//sequencial logic(dmac_buffer_idx
always @(posedge HCLK)
begin
   if(ps==MA_RDATA_S) begin
      DMAC_buffer[dmac_buffer_idx] <= HRDATA;
   end
   else begin
      DMAC_buffer[dmac_buffer_idx] <= DMAC_buffer[dmac_buffer_idx];
   end
end

always @(*)
begin
   if(ps==MA_WDATA_S) begin
      m_HWDATA <= DMAC_buffer[dmac_buffer_idx];
   end
   else begin
      m_HWDATA <= m_HWDATA;
   end
end

////------------------------------------------------------FSM 2개 시작 ------------------------------------------////

//slave fsm

always @(posedge HCLK or negedge HRESETn)
begin
   if(!HRESETn) sps <= SDMAC_IDLE_S; 
   else sps <= sns;
   
end

always @( * ) // state block
begin
   s_out_HRESP <= `OKAY;
    s_out_HREADY <= 1'b1;
    s_out_HRDATA <= 32'b0; 
   load_ahb_addr <= 1'b0; //DMAC_HADDR_REG = HADDR[6:5]
    write_out_reg <= 1'b0;
   case(sps)
      SDMAC_IDLE_S : begin
         if((HSEL == 1'b1) && (HTRANS[1] == 1'b1) && (HREADY == 1'b1)) sns <= SDMAC_ADDR_S;
         else sns <= sps;
      end
      SDMAC_ADDR_S : begin
         if(HREADY == 0) // 추가: HREADY가 0이면 현재 상태 유지
            sns <= sps;
         else if((HREADY == 1) && (HSEL == 1) && (HTRANS[1] == 1) && (HWRITE == 0)) 
            sns <= SDMAC_READ_S;
         else if((HREADY == 1) && (HSEL == 1) && (HTRANS[1] == 1) && (HWRITE == 1)) 
            sns <= SDMAC_WRITE_S;
         else 
            sns <= SDMAC_ADDR_S;
      end
      SDMAC_WRITE_S : begin
         if(HREADY == 0) // 추가: HREADY가 0이면 현재 상태 유지
            sns <= sps;
         else if(HSEL == 1 && HTRANS[1] == 1 && HWRITE == 1) 
            sns <= SDMAC_WRITE_S;
         else if(HSEL == 1 && HTRANS[1] == 1 && HWRITE == 0) 
            sns <= SDMAC_READ_S;
         else 
            sns <= SDMAC_ADDR_S;
         if(!((DMAC_HADDR_REG == 12'h030)||
            (DMAC_HADDR_REG == 12'h100)||
            (DMAC_HADDR_REG == 12'h104)||
            (DMAC_HADDR_REG == 12'h10C)||
            (DMAC_HADDR_REG == 12'h110))) begin
               sns <= SDMAC_ERROR_S;
         end
      end
      SDMAC_READ_S : begin
         if(HREADY == 0) // 추가: HREADY가 0이면 현재 상태 유지
            sns <= sps;
         else if(HSEL == 1 && HTRANS[1] == 1 && HWRITE == 0) 
            sns <= SDMAC_READ_S;
         else if(HSEL == 1 && HTRANS[1] == 1 && HWRITE == 1) 
            sns <= SDMAC_WRITE_S;
         else 
            sns <= SDMAC_ADDR_S;
      end
      SDMAC_ERROR_S : begin
         if(HREADY == 0) // 추가: HREADY가 0이면 현재 상태 유지
            sns <= SDMAC_ERROR_S;
         else
            sns <= SDMAC_ADDR_S;
      end
      default : sns <= SDMAC_IDLE_S;
   endcase
end


always @(*) //output block
begin  
    s_out_HRESP <= `OKAY;
    s_out_HREADY <= 1'b1;
    s_out_HRDATA <= 32'b0; 
    load_ahb_addr <= 1'b0; //DMAC_HADDR_REG = HADDR[6:5]
    write_out_reg <= 1'b0;
   case(sps)
      SDMAC_IDLE_S : begin
         //default
      end
      SDMAC_ADDR_S : begin
         load_ahb_addr <= 1'b1;
      end
      SDMAC_WRITE_S : begin
         load_ahb_addr <= 1'b1; 
         write_out_reg <= 1'b1;
      end
      SDMAC_READ_S : begin
         case(DMAC_HADDR_REG)
            12'h030 : s_out_HRDATA <= {31'b0,DMAC_Configuration[0]};
            12'h100 : s_out_HRDATA <= DMAC_C0_SrcAddr;
            12'h104 : s_out_HRDATA <= DMAC_C0_DestAddr;
            12'h10C : s_out_HRDATA <= {17'b0,DMAC_C0_Control[14:0]};
            12'h110 : s_out_HRDATA <= {29'b0,DMAC_C0_Configuration[2:0]};
         endcase
      end
      SDMAC_ERROR_S : begin
         s_out_HRESP <= `ERROR;
         s_out_HREADY <= 1'b0;
      end
      default: begin
         s_out_HRESP <= `OKAY;
         s_out_HREADY <= 1'b1;
         s_out_HRDATA <= 32'b0;
         load_ahb_addr <= 1'b0;
         write_out_reg <= 1'b0;
      end
   endcase
end

//master fsm
always @(posedge HCLK or negedge HRESETn) 
begin
   if(!HRESETn)  ps <= MA_IDLE_S; 
   else ps <= ns; 
end

always @(*) // next state 결정 블록
begin
   case(ps)
      MA_IDLE_S : begin
         if((CHANNEL_enable == 1'b1)) ns <= MA_REQ_S;
         else ns <= ps;
      end
      MA_REQ_S : begin
         if(HREADY == 1'b1) ns <= MA_READ_S;
         else ns <= ps;
      end
      MA_READ_S : begin
         if((HREADY == 1'b1) && (sync_grant == 1'b1)) ns <= MA_RDATA_S;
         else ns <= MA_READ_WAIT_S;
      end
      MA_READ_WAIT_S : begin
         if((sync_grant == 1'b1) && (HREADY == 1'b1)) ns <= MA_RDATA_S;
         else ns <= ps;
      end
      MA_RDATA_S : begin
         if((src_burst_cnt < ahb_burst_size) && (HREADY == 1'b1)) ns <= ps;
         else if((src_burst_cnt < ahb_burst_size) && (HREADY == 1'b0)) ns <= MA_RDATA_NR_S;
         else if((src_burst_cnt >= ahb_burst_size) && (sync_grant == 1'b1) && (HREADY == 1'b1)) ns <= MA_WRITE_GR_S;
         else ns <= MA_WRITE_WAIT_S;
      end
      MA_RDATA_NR_S : begin
         if(HREADY == 1'b1) ns <= MA_RDATA_S;
         else ns <= ps;
      end
      MA_WRITE_GR_S : begin
         if(HREADY == 1'b1) ns <= MA_WDATA_S;
         else ns <= MA_WRITE_GR_NR_S;
      end
      MA_WRITE_WAIT_S : begin
         if((HREADY == 1'b1) && (sync_grant == 1'b1)) ns <= MA_WRITE_GR_S;
         else ns <= ps;
      end
      MA_WRITE_GR_NR_S : begin
         if(HREADY == 1'b1) ns <= MA_WDATA_S;
         else ns <= ps;
      end
      MA_WDATA_S : begin
         if((HREADY == 1'b1) && (dest_burst_cnt < ahb_burst_size)) ns <= ps;
         else if((HREADY == 1'b0) && (dest_burst_cnt < ahb_burst_size)) ns <= MA_WDATA_NR_S;  //transfer가 안끝났는데 ready가 0으로 떨어져서 가는 state
         else if((HREADY == 1'b0) && (dest_burst_cnt >= ahb_burst_size)) ns <= MA_WDATA_FIN_NR_S;  //transfer가 끝났는데, ready가 0으로 떨어져서 가는 state
         else if((HREADY == 1'b1) && (dest_burst_cnt >= ahb_burst_size) && (TS != 0)) ns <= MA_TS_LEFT_S; 
         else if((HREADY == 1'b1) && (dest_burst_cnt >= ahb_burst_size) && (TS == 0)) ns <= MA_TS_FIN_S;
         else ns <= ps;  
      end
      MA_WDATA_NR_S : begin
         if(HREADY == 1'b1) begin ns <= MA_WDATA_S; end
         else begin ns <= ps; end
      end
      MA_WDATA_FIN_NR_S : begin
         if((HREADY == 1'b1) && (TS != 0)) ns <= MA_TS_LEFT_S; 
         else if((HREADY == 1'b1) && (TS == 0)) ns <= MA_TS_FIN_S;
         else ns <= ps;
      end
      MA_TS_LEFT_S : begin
         if(HREADY == 1'b1) ns <= MA_READ_S;
         else ns <= ps;
      end
      MA_TS_FIN_S : begin
         if(HREADY == 1) ns <= MA_REQ_S;
         else ns <= ps;
      end
      default : ns <= MA_REQ_S; // default가 REQ state로 가야할 지 ? ps 유지해야 할 지?
   endcase
end

always @(*) //output block
begin  
   src_addr_inc <= 0;
   dest_addr_inc <= 0;
   m_HBUSREQ <= 1'b1;
   m_HLOCK <= 1'b0;
   m_HTRANS <= `IDLE;
   m_HADDR <= 32'b0;
   m_HWRITE <= 1'b0;
   m_HSIZE <= `AHB_WORD;  
   m_HBURST <= ahb_burst;

   CHANNEL_dis_flag <= 0; 
   buffer_zero_flag <= 0; 
   load_DMAC_C0_Addr <= 0;      
   TransferSize_dec_flag <= 0;
   src_burst_zero_flag <= 0;
   dest_burst_zero_flag <= 0;
   buffer_idx_inc <= 1'b0;
   load_fir_src_img <= 1'b0;
   set_DMACINTR_status <= 1'b0;
   case(ps)
      MA_IDLE_S : begin
         m_HBUSREQ <= 1'b0;
      end
      MA_REQ_S : begin
         src_burst_zero_flag <= 1'b1;
         dest_burst_zero_flag <= 1'b1;
         load_DMAC_C0_Addr <= 1'b1;
         m_HWDATA <= 32'b0;
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
      end
      MA_READ_S : begin
         //READ function
         m_HADDR <= DMAC_C0_SrcAddr_Master;
         m_HTRANS <= `NONSEQ;
         m_HWDATA <= 32'b0;
         buffer_zero_flag <= 1'b1;
         src_addr_inc <= 1'b1;
      end
      MA_READ_WAIT_S : begin
         //값 유지
         m_HADDR <= DMAC_C0_SrcAddr_Master;
         m_HTRANS <= `NONSEQ;
         m_HWDATA <= 32'b0;
      end
      MA_RDATA_S : begin
         //RDATA function
         m_HADDR <= DMAC_C0_SrcAddr_Master;
         m_HTRANS <= `SEQ;
         m_HWDATA <= 32'b0;
         src_addr_inc <= 1'b1;
         load_fir_src_img <= 1'b1;
         buffer_idx_inc <= 1'b1;
      end
      MA_RDATA_NR_S : begin
         m_HADDR <= DMAC_C0_SrcAddr_Master;
         m_HTRANS <= `SEQ;
         m_HWDATA <= 32'b0;
      end
      MA_WRITE_GR_S : begin
         //RDATA fin function
         src_burst_zero_flag <= 1'b1;
         load_fir_src_img <= 1'b1;
         buffer_zero_flag <= 1'b1;
         //WRITE function
         m_HADDR <= DMAC_C0_DestAddr_Master;
         m_HTRANS <= `NONSEQ;
         m_HWRITE <= 1'b1;
         //m_HWDATA <= DMAC_BUFFER[dmac_buffer_idx];
         buffer_idx_inc <= 1'b1;
         TransferSize_dec_flag <= 1'b1;
         dest_addr_inc <= 1'b1;
      end
      MA_WRITE_WAIT_S : begin
         //default
      end
      MA_WRITE_GR_NR_S : begin
         //RDATA fin function
         src_burst_zero_flag <= 1'b1;
         load_fir_src_img <= 1'b1;
         buffer_zero_flag <= 1'b1;
         //WRITE function(non ready)
         m_HADDR <= DMAC_C0_DestAddr_Master;
         m_HTRANS <= `NONSEQ;
         m_HWRITE <= 1'b1;
         m_HWDATA <= 32'b0;
      end
      MA_WDATA_S : begin
         //WDATA fuction
         m_HADDR <= DMAC_C0_DestAddr_Master;
         m_HTRANS <= `SEQ;
         m_HWRITE <= 1'b1;
         //m_HWDATA <= DMAC_BUFFER[dmac_buffer_idx];
         buffer_idx_inc <= 1'b1;
         TransferSize_dec_flag <= 1'b1;
         dest_addr_inc <= 1'b1;
         if(TS == 4) begin
            m_HBUSREQ <= 1'b0;
         end
      end
      MA_WDATA_NR_S : begin
         m_HADDR <= DMAC_C0_DestAddr_Master;
         m_HTRANS <= `SEQ;
         m_HWRITE <= 1'b1;
         m_HWDATA <= 32'b0;
         //m_HWDATA <= DMAC_BUFFER[dmac_buffer_idx];
         if(TS == 4) begin
            m_HBUSREQ <= 1'b0;
         end
      end
      MA_WDATA_FIN_NR_S : begin
         //default
         if(TS == 4) begin
            m_HBUSREQ <= 1'b0;
         end
         m_HWDATA <= 32'b0;
      end
      MA_TS_LEFT_S : begin
         dest_burst_zero_flag <= 1'b1;
         m_HWDATA <= 32'b0;
         if(TS[11:2] < ahb_burst_size) begin
            ahb_burst_size <= TS[11:2];
            ahb_burst <= `INCR;
         end
      end
      MA_TS_FIN_S : begin
         dest_burst_zero_flag <= 1'b1;
         CHANNEL_dis_flag <= 1'b1;
         set_DMACINTR_status <= 1'b1;
         m_HBUSREQ <= 0;
         m_HWDATA <= 32'b0;
      end
      default : begin
            src_addr_inc <= 0;
            dest_addr_inc <= 0;
            m_HBUSREQ <= 1'b1;
            m_HLOCK <= 1'b0;
            m_HTRANS <= `IDLE;
            m_HADDR <= 1'b0;
            m_HWRITE <= 1'b0;
            m_HSIZE <= `AHB_WORD;
            m_HBURST <= ahb_burst;
            m_HWDATA <= 32'b0;
            CHANNEL_dis_flag <= 0;
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