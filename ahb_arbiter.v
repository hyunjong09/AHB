//////////////////////////////////////////////////////////////
// AMBA Fixed Priority Arbiter
// Soonisil Univ.
// File Name : ahb_arbiter_fixed.v
// Date : 2005. 06. 10
// Author : Sanghun, Lee (Ph.D Candidate of SoEE, SSU)
// Copyright 2005  Soongsil University, Seoul, Korea
// Modified Date : 2008.11.08
// Modifier : SeoHoon, Yang
// ALL RIGHTS RESERVED
//////////////////////////////////////////////////////////////

module ahb_arbiter_fixed
       (
       HCLK, 
       HRESETn, 
       HBUSREQ, 
       HTRANS, 
       HREADY, 
       HBURST, 
       HGRANT, 
       HMASTER,
       HMASTER_del
       );


`include "amba_h.v"
`include "ahb_include.v"

//parameters specified by user for AHB
//the number of masters, which can be up to 16
parameter N_MASTER=3;
//W_MASTER=ceil(log2(N_MASTER))
parameter W_MASTER=2;
//the number of slaves
parameter N_SLAVE=8;
//W_SLAVE=ceil(log2(N_SLAVE))
parameter W_SLAVE=3;
//the width of address bus
parameter W_ADDR=32;
//the width of data bus
parameter W_DATA=32;

//the number of default master
parameter NUM_DEF_MASTER = 0;
//the number of default slave
parameter NUM_DEF_SLAVE = 0;

parameter EN_DOWN_CNT_INIT = 0;
parameter EN_DOWN_CNT_INSERT = 1;
parameter EN_DOWN_CNT_DEC = 2;
parameter EN_DOWN_CNT_HOLD = 3;

parameter M0 = 3'b001;
parameter M1 = 3'b010;
parameter M2 = 3'b100;
               
// Port Declaration
input                     HCLK;
input                     HRESETn;
input      [N_MASTER-1:0] HBUSREQ;
input      [`W_TRANS-1:0] HTRANS;
input                     HREADY;
input      [`W_BURST-1:0] HBURST;
output reg [N_MASTER-1:0] HGRANT;
output reg [W_MASTER-1:0] HMASTER;
output reg [W_MASTER-1:0] HMASTER_del;

//down counter
reg [3:0] down_cnt;
reg [1:0] en_down_cnt;

reg [N_MASTER-1:0] HGRANT_reg;
reg [N_MASTER-1:0] q_HBUSREQ;

//q_HBUSREQ REG OUTPUT
always @(posedge HCLK or negedge HRESETn)
   begin
      if (HRESETn ==1'b0) begin
         q_HBUSREQ <= 2'b00;
      end
      else begin
      if (HREADY == 1'b1) // 조건 확인
      begin
         q_HBUSREQ <= HBUSREQ;
      end else begin
         q_HBUSREQ <= q_HBUSREQ;
      end
   end
end


//en_down_cnt(combintaion)
always @(*)
begin
    if (!HREADY)
   begin
        en_down_cnt = 2'b11;
   end 
   else if (HREADY && HTRANS == `NONSEQ)
   begin
        en_down_cnt = 2'b01;
    end 
   else if (HREADY && HTRANS != `NONSEQ)
   begin
        en_down_cnt = 2'b10; 
    end
end

//down counter(Register)
always @(posedge HCLK or negedge HRESETn) 
begin
   if(!HRESETn)
   begin
      down_cnt<=0;
   end
   else
   begin
      case(en_down_cnt)
         2'b00:down_cnt <=0;
         2'b01:
         begin
            case(HBURST)
               `SINGLE:down_cnt <=4'b0000;
               `INCR:down_cnt <=4'b1111;
               `WRAP4:down_cnt <=4'b0010;
               `INCR4: down_cnt<=4'b0010;
               `WRAP8: down_cnt<=4'b0110;
               `INCR8: down_cnt<=4'b0110;
               `WRAP16: down_cnt<=4'b1110;
               `INCR16: down_cnt<=4'b1110;
            endcase
         end
         2'b10:
         begin
            if(!down_cnt)
            begin
               down_cnt <=0;
            end
            else
            begin
               if(HBURST==`INCR)
               begin
                  down_cnt <=down_cnt;
               end
               else
               begin
                  down_cnt<=down_cnt-1'b1;
               end
            end
         end   
         2'b11:down_cnt<=down_cnt;
      endcase
   end
end
               



//Fixed Priority(REG OUTPUT)
always@(posedge HCLK or negedge HRESETn) 
begin
   if(!HRESETn) begin HGRANT_reg <= 3'b001; end
   else begin
      if(HTRANS == `SEQ) begin 
         casex(HBUSREQ) 
            3'bxx1 : begin
               if(down_cnt==4'b0000) begin HGRANT_reg <= 3'b001; end
               else begin HGRANT_reg <= HGRANT_reg; end
            end
            3'bx10 : begin
               if(down_cnt == 4'b0000) begin HGRANT_reg <= 3'b010; end
               else begin HGRANT_reg <= HGRANT_reg; end
            end
            3'b100 : begin
               if(down_cnt == 4'b0000) begin HGRANT_reg <= 3'b100; end
               else begin HGRANT_reg <= HGRANT_reg; end
            end
            default : begin HGRANT_reg <= HGRANT_reg; end
         endcase
      end
      if(HREADY == 1'b1) begin
         case (HTRANS)
            `IDLE : begin
               casex (HBUSREQ) 
                  3'bxx1 : HGRANT_reg <= 3'b001;
                  3'bx10 : HGRANT_reg <= 3'b010;
                  3'b100 : HGRANT_reg <= 3'b100;
                  default : HGRANT_reg <= 3'b001;  // default : HGRANT_reg <= HGRANT_reg 에서 수정하여 default master를 가리키게 함              
               endcase
            end
            `NONSEQ : begin
            if(HBURST ==`SINGLE)
            begin
               casex (q_HBUSREQ) 
               3'bxx1 : HGRANT_reg <= 3'b001;
               3'bx10 : HGRANT_reg <= 3'b010;
               3'b100 : HGRANT_reg <= 3'b100;
               default : HGRANT_reg <= 3'b001;   // default : HGRANT_reg <= HGRANT_reg 에서 수정하여 default master를 가리키게 함
               endcase
            end
            else
            begin
               HGRANT_reg <=HGRANT_reg;
            end
            end
         endcase
      end
      else begin HGRANT_reg <= HGRANT_reg; end
   end
end
      

//Fixed Priority(COMBINATION OUTPUT)
always @(*) begin
   if(HTRANS == `SEQ && down_cnt == 4'b0000) begin
      casex(q_HBUSREQ) 
         3'bxx1 : HGRANT <= 3'b001;
         3'bx10 : HGRANT <= 3'b010;
         3'b100 : HGRANT <= 3'b100;
       default : HGRANT <= 3'b001;  //default : HGRANT <= 3'b001 신호 추가를 하여 default master를 가리키게 함
      endcase
   end
   else if((HREADY == 1'b1)&&(HBURST==`SINGLE)&&(HTRANS==`NONSEQ)) begin
      casex(q_HBUSREQ) 
         3'bxx1 : HGRANT <= 3'b001;
         3'bx10 : HGRANT <= 3'b010;
         3'b100 : HGRANT <= 3'b100;
       default : HGRANT <= 3'b001;
      endcase
   end
   else begin
      HGRANT <= HGRANT_reg;
   end
end
      

//Generate HMASTER(REG)
always @(posedge HCLK or negedge HRESETn)
   begin
      if (HRESETn == 1'b0) begin
         HMASTER <= 2'b00;
      end
      else begin
         if(HREADY == 1'b0) begin
            HMASTER <= HMASTER;
         end
         else if(HREADY == 1'b1) begin
            casex(HGRANT)
               3'bxx1 : HMASTER <= 2'b00;
               3'bx10 : HMASTER <= 2'b01;
               3'b100 : HMASTER <= 2'b10;
            endcase
         end
         else begin
            HMASTER <= 2'b00;
         end
   end
end


//HMASTER_del REG OUTPUT
always @( posedge HCLK or negedge HRESETn)
   begin
      if (HRESETn ==1'b0) begin
         HMASTER_del <= 2'b00;
      end
      else begin
      if (HREADY == 1'b1)
      begin
         HMASTER_del <= HMASTER;
      end else begin
         HMASTER_del <= HMASTER_del;
      end
   end
end
         
endmodule