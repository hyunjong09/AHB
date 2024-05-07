`include "ahb_macro_h.v"
module DMAC_top (
    //slave input
    HCLK,
    HRESETn,
    HTRANS,
    HSEL,
    HREADY,
    HWRITE,
    HADDR,
    HWDATA,
    HSIZE,
    HBURST,

    //slave output
    s_out_HRDATA,
    s_out_HRESP,
    s_out_HREADY,

    //master input
    HRESP,
    HRDATA,
    HGRANT,

    //master output
    m_HTRANS,
    m_HBURST, 
    m_HSIZE,
    m_HADDR,
    m_HWRITE, 
    m_HWDATA, 
    m_HPROT,
    m_HLOCK, 
    m_HBUSREQ, 
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

//wire 선언
wire [31:0] out_HRDATA;
wire [1:0] out_HRESP;
wire out_HREADY;
wire write_out_reg;
wire load_ahb_addr;

wire [31:0] DMAC_Configuration;
wire [31:0] DMAC_C0_SrcAddr;
wire [31:0] DMAC_C0_DestAddr;
wire [31:0] DMAC_C0_Control;
wire [31:0] DMAC_C0_Configuration;

wire [11:0] DMAC_HADDR_REG;

wire CHANNEL_dis_flag;
wire buffer_zero_flag;
wire buffer_idx_inc;
wire load_DMAC_C0_Addr;
wire TransferSize_dec_flag;
wire src_burst_zero_flag;
wire dest_burst_zero_flag;
wire set_DMACINTR_status;
wire src_addr_inc;
wire dest_addr_inc;
wire load_fir_src_img;
wire m_HGRANT;

wire [11:0] TS;
wire [2:0] BS;
wire CHANNEL_enable;
wire DMACINTR_mask;
wire DMACINTR_pend;
wire sync_grant;
wire dmac_buffer_idx;
wire [31:0] DMAC_C0_SrcAddr_Master;
wire [31:0] DMAC_C0_DestAddr_Master;
wire src_burst_cnt;
wire dest_burst_cnt;


//instance
DMAC_SLAVE slave_uut (	.s_HCLK(HCLK), 
						.s_HRESETn(HRESETn), 
						.s_HTRANS(HTRANS), 
						.s_HSEL(HSEL), 
							
						.s_HREADY(HREADY), 
						.s_HWRITE(HWRITE), 
						.s_HSIZE(HSIZE), 
						.s_HBURST(HBURST), 
						.DMAC_HADDR_REG(DMAC_HADDR_REG), 
						.s_out_HRDATA(out_HRDATA), 
						.s_out_HRESP(out_HRESP), 
						.s_out_HREADY(out_HREADY), 
						.write_out_reg(write_out_reg), 
						.load_ahb_addr(load_ahb_addr)	);
					
REG_BANK bank_uut (	.r_HCLK(HCLK),
					.r_HRESETn(HRESETn),
					.r_HWDATA(HWDATA),
					.r_HADDR(HADDR),

					.write_out_reg(write_out_reg),
					.load_ahb_addr(load_ahb_addr),

					.CHANNEL_dis_flag(CHANNEL_dis_flag),
					.buffer_zero_flag(buffer_zero_flag),
					.buffer_idx_inc(buffer_idx_inc),
					.load_DMAC_C0_Addr(load_DMAC_C0_Addr),
					.TransferSize_dec_flag(TransferSize_dec_flag),
					.src_burst_zero_flag(src_burst_zero_flag),
					.dest_burst_zero_flag(dest_burst_zero_flag),
					.set_DMACINTR_status(set_DMACINTR_status),
					.src_addr_inc(src_addr_inc),
					.dest_addr_inc(dest_addr_inc),
					.load_fir_src_img(load_fir_src_img),
					.m_HGRANT(m_HGRANT),

					.DMAC_HADDR_REG(DMAC_HADDR_REG),

					.DMAC_Configuration(DMAC_Configuration),
					.DMAC_C0_SrcAddr(DMAC_C0_SrcAddr),
					.DMAC_C0_DestAddr(DMAC_C0_DestAddr),
					.DMAC_C0_Control(DMAC_C0_Control),
					.DMAC_C0_Configuration(DMAC_C0_Configuration),

					.TS(TS),
					.BS(BS),
					.CHANNEL_enable(CHANNEL_enable),
					.DMACINTR_mask(DMACINTR_mask),
					.DMACINTR_pend(DMACINTR_pend),
					.sync_grant(sync_grant),
					.dmac_buffer_idx(dmac_buffer_idx),
					.DMAC_C0_SrcAddr_Master(DMAC_C0_SrcAddr_Master),
					.DMAC_C0_DestAddr_Master(DMAC_C0_DestAddr_Master),
					.src_burst_cnt(src_burst_cnt),
					.dest_burst_cnt(dest_burst_cnt)
);

DMAC_MASTER master_uut (	.m_HCLK(HCLK),
							.m_HRESTn(HRESETn),
							.m_HREADY(HREADY),
							.m_HGRANT(m_HGRANT),
							.TS(TS),
							.BS(BS),
							.CHANNEL_enable(CHANNEL_enable),
							.DMACINTR_mask(DMACINTR_mask),
							.DMACINTR_pend(DMACINTR_pend),
							.sync_grant(sync_grant),
							.dmac_buffer_idx(dmac_buffer_idx),
							.DMAC_C0_SrcAddr_Master(DMAC_C0_SrcAddr_Master),
							.DMAC_C0_DestAddr_Master(DMAC_C0_DestAddr_Master),
							.src_burst_cnt(src_burst_cnt),
							.dest_burst_cnt(dest_burst_cnt),

							.CHANNEL_dis_flag(CHANNEL_dis_flag),
							.buffer_zero_flag(buffer_zero_flag),
							.buffer_idx_inc(buffer_idx_inc),
							.load_DMAC_C0_Addr(load_DMAC_C0_Addr),
							.TransferSize_dec_flag(TransferSize_dec_flag),
							.src_burst_zero_flag(src_burst_zero_flag),
							.dest_burst_zero_flag(dest_burst_zero_flag),
							.set_DMACINTR_status(set_DMACINTR_status),
							.src_addr_inc(src_addr_inc),
							.dest_addr_inc(dest_addr_inc),
							.load_fir_src_img(load_fir_src_img),
							.m_HTRANS(m_HTRANS),
							.m_HBURST(m_HBURST),
							.m_HSIZE(m_HSIZE),
							.m_HADDR(m_HADDR),
							.m_HWRITE(m_HWRITE), 
							.m_HWDATA(m_HWDATA),
							.m_HPROT(m_HPROT),
							.m_HLOCK(m_HLOCK),
							.m_HBUSREQ(m_HBUSREQ), 
							.DMACINTR(DMACINTR)
);

always @(*)
begin
	s_out_HRDATA <= out_HRDATA;
	s_out_HREADY <= out_HREADY;
	s_out_HRESP <= out_HRESP;
end

endmodule