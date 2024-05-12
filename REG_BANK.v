`include "ahb_macro_h.v"
module REG_BANK (
    r_HCLK,
    r_HRESETn,
    r_HWDATA,
    r_HADDR,

    write_out_reg,
    load_ahb_addr,

    CHANNEL_dis_flag,
    buffer_zero_flag,
	buffer_idx_inc,
    load_DMAC_C0_Addr,
    TransferSize_dec_flag,
    src_burst_zero_flag,
    dest_burst_zero_flag,
    src_addr_inc,
    dest_addr_inc,
    m_HGRANT,
	load_fir_src_img,

    DMAC_Configuration,
    DMAC_C0_SrcAddr,
    DMAC_C0_DestAddr,
    DMAC_C0_Control,
    DMAC_C0_Configuration,

    TS,
    BS,
    CHANNEL_enable,
	clr_DMACINTR_pend, // 인터럽트 fsm에서 출력으로 나옴.
    DMACINTR_mask,
    DMACINTR_pend,
    sync_grant,
    dmac_buffer_idx,
    DMAC_C0_SrcAddr_Master,
    DMAC_C0_DestAddr_Master,
    src_burst_cnt,
    dest_burst_cnt,
	DMAC_HADDR_REG
);

//top 모듈에서 instance되는 input (tb에서 들어오는 거)
input r_HCLK;
input r_HRESETn;
input [31:0] r_HWDATA;
input [31:0] r_HADDR;

//slave에서 들어오는 input
input write_out_reg;
input load_ahb_addr;

//master에서 들어오는 input
input CHANNEL_dis_flag;
input buffer_zero_flag;
input buffer_idx_inc;
input load_DMAC_C0_Addr;
input TransferSize_dec_flag;
input src_burst_zero_flag;
input dest_burst_zero_flag;
input src_addr_inc;
input dest_addr_inc;
input m_HGRANT;
input load_fir_src_img;

input clr_DMACINTR_pend;
//input set_DMACINTR_status; // 인터럽트 출력으로 나옴.

output reg [11:0] DMAC_HADDR_REG;

output reg [31:0] DMAC_Configuration;
output reg [31:0] DMAC_C0_SrcAddr;
output reg [31:0] DMAC_C0_DestAddr;
output reg [31:0] DMAC_C0_Control;
output reg [31:0] DMAC_C0_Configuration;

output reg [11:0] TS;
output reg [2:0] BS;
output reg CHANNEL_enable;
output reg DMACINTR_mask;
output reg DMACINTR_pend;
output reg sync_grant;
output reg [4:0] dmac_buffer_idx;
output reg [31:0] DMAC_C0_SrcAddr_Master;
output reg [31:0] DMAC_C0_DestAddr_Master;
output reg [4:0] src_burst_cnt;
output reg [4:0] dest_burst_cnt;

//sequencial logic(DMAC_HADDR_REG)
always @(posedge r_HCLK or negedge r_HRESETn)
begin
   if(!r_HRESETn) begin
      DMAC_HADDR_REG <= 0;
   end
    else begin
      if(load_ahb_addr == 1'b1) begin
         DMAC_HADDR_REG <= r_HADDR[11:0];
      end 
      else begin
         DMAC_HADDR_REG <= DMAC_HADDR_REG;
      end
   end
end

//sequencial logic(reg_bank)
always @(posedge r_HCLK or negedge r_HRESETn)
begin
    if(write_out_reg == 1'b1) begin
		case(DMAC_HADDR_REG)
			12'h030 : DMAC_Configuration <= r_HWDATA[0];
            12'h100 : DMAC_C0_SrcAddr <= r_HWDATA;
            12'h104 : DMAC_C0_DestAddr <= r_HWDATA;
            12'h10C : DMAC_C0_Control <= r_HWDATA[14:0]; 
            12'h110 : DMAC_C0_Configuration <= r_HWDATA[2:0];
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

always @(*)
begin
   CHANNEL_enable <= DMAC_C0_Configuration[0];
   DMACINTR_pend<=DMAC_C0_Configuration[2];
   DMACINTR_mask<=DMAC_C0_Configuration[1];
end

always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
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


//DMACINTR_pend sequencial logic
always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
		DMACINTR_pend <= 1'b0;
	end
	else begin
		if((clr_DMACINTR_pend==1'b1)&&!((write_out_reg==1'b1)&&(DMAC_HADDR_REG==12'h110))) begin
			DMACINTR_pend <= 1'b0;
		end 
		else begin
			DMACINTR_pend <= DMACINTR_pend;
		end
	end
end


always @(*)
begin
	TS <= DMAC_C0_Control[11:0];
	BS <= DMAC_C0_Control[14:12];
end

always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
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

/*always @(posedge r_HCLK or negedge r_HRESETn)
begin
   if(!r_HRESETn) begin
      DMACINTR_pend <= 1'b1;
   end
    else begin
      if((set_DMACINTR_status==1'b1)&&!((write_out_reg==1'b1)&&(DMAC_HADDR_REG==12'h10C))) begin
         CHANNEL_enable <= 1'b0;
      end 
      else begin
         CHANNEL_enable <= CHANNEL_enable;
      end
   end
end*/
// 위 로직이 어디서 나왔는지 확인이 안됨.


//sequencial logic(sync_grant)
always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
		sync_grant <= 1'b0;
	end
    else begin
		if(m_HGRANT == 1'b1) begin
			sync_grant <= 1'b1;
		end 
		else begin
			sync_grant <= 1'b0;
		end
	end
end

//sequencial logic(dmac_buffer_idx)
always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
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

//sequencial logic(load_master_addr)
always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
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

//sequencial logic(src)
always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
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
always @(posedge r_HCLK or negedge r_HRESETn)
begin
	if(!r_HRESETn) begin
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

endmodule