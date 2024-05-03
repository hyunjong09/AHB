`include "ahb_macro_h.v"
`include "amba_h.v"
module ahb_test(HCLK, HRESETn, 
      //inputs from masters   
      m0_HTRANS, m0_HBURST, m0_HSIZE, m0_HPROT, m0_HADDR, m0_HWRITE, m0_HWDATA,      //Master_0    //Master_1
	  
      m0_HBUSREQ, m2_HBUSREQ,
      //outputs to masters
      HREADY, HRESP, HRDATA,
      //outputs to slaves
      HSEL, HTRANS, HBURST, HSIZE, HADDR, HWRITE, HWDATA, HSPLIT
      );
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
   
   //signal declarations
   //bus clock
   input HCLK;
   //asynchronous reset: active-low
   input HRESETn;
      
   //master 0
   input [`W_TRANS-1:0] m0_HTRANS;
   input [`W_BURST-1:0] m0_HBURST;
   input [`W_SIZE-1:0]  m0_HSIZE;
   input [`W_PROT-1:0]  m0_HPROT;
   input [W_ADDR-1:0]   m0_HADDR;
   input                m0_HWRITE;
   input [W_DATA-1:0]   m0_HWDATA;
   input m0_HBUSREQ;
   input m2_HBUSREQ;
   wire m1_HBUSREQ;
   wire [2:0] HBUSREQ;
   wire [2:0] HGRANT;
   
   
   wire [`W_TRANS-1:0] m1_HTRANS;
   wire [`W_BURST-1:0] m1_HBURST;
   wire [`W_SIZE-1:0]  m1_HSIZE;
   wire [`W_PROT-1:0]  m1_HPROT;
   wire [W_ADDR-1:0]   m1_HADDR;
   wire                m1_HWRITE;
   wire [W_DATA-1:0]   m1_HWDATA;

   wire [`W_TRANS-1:0] m2_HTRANS;
   wire [`W_BURST-1:0] m2_HBURST;
   wire [`W_SIZE-1:0]  m2_HSIZE;
   wire [`W_PROT-1:0]  m2_HPROT;
   wire [W_ADDR-1:0]   m2_HADDR;
   wire                m2_HWRITE;
   wire [W_DATA-1:0]   m2_HWDATA;
   
   //inputs from slaves
   wire                s0_HREADY;
   wire [`W_RESP-1:0]  s0_HRESP;
   wire [W_DATA-1:0]   s0_HRDATA;
   wire [N_MASTER-1:0] s0_HSPLIT;
   //slave 6
   wire                s1_HREADY;
   wire [`W_RESP-1:0]  s1_HRESP;
   wire [W_DATA-1:0]   s1_HRDATA;
   wire [N_MASTER-1:0] s1_HSPLIT;
   //slave 7
   wire                s2_HREADY;
   wire [`W_RESP-1:0]  s2_HRESP;
   wire [W_DATA-1:0]   s2_HRDATA;
   wire [N_MASTER-1:0] s2_HSPLIT;
   
   //slave 7
   wire                s3_HREADY;
   wire [`W_RESP-1:0]  s3_HRESP;
   wire [W_DATA-1:0]   s3_HRDATA;
   wire [N_MASTER-1:0] s3_HSPLIT;
   
   //slave 4
   wire                s4_HREADY;
   wire [`W_RESP-1:0]  s4_HRESP;
   wire [W_DATA-1:0]   s4_HRDATA;
   wire [N_MASTER-1:0] s4_HSPLIT;
   //slave 6
   wire                s5_HREADY;
   wire [`W_RESP-1:0]  s5_HRESP;
   wire [W_DATA-1:0]   s5_HRDATA;
   wire [N_MASTER-1:0] s5_HSPLIT;
   //slave 7
   wire                s6_HREADY;
   wire [`W_RESP-1:0]  s6_HRESP;
   wire [W_DATA-1:0]   s6_HRDATA;
   wire [N_MASTER-1:0] s6_HSPLIT;
   
   //slave 7
   wire                s7_HREADY;
   wire [`W_RESP-1:0]  s7_HRESP;
   wire [W_DATA-1:0]   s7_HRDATA;
   wire [N_MASTER-1:0] s7_HSPLIT;
   
   //outputs to masters
   output                HREADY;
   output [`W_RESP-1:0]  HRESP;
   output [W_DATA-1:0]   HRDATA;
   //outputs to slaves
   output [N_SLAVE-1:0]  HSEL;
   output [`W_TRANS-1:0] HTRANS;
   output [`W_BURST-1:0] HBURST;
   output [`W_SIZE-1:0]  HSIZE;
   output [W_ADDR-1:0]   HADDR;
   output                HWRITE;
   output [W_DATA-1:0]   HWDATA;
   output [N_MASTER-1:0] HSPLIT;
   wire [1:0] HMASTER;
   wire [1:0] HMASTER_del;
   wire HMASTLOCK;


assign HBUSREQ = {m2_HBUSREQ, m1_HBUSREQ, m0_HBUSREQ};

// AHB 버스 인터페이스 모듈 인스턴스화
DRAM dram_instance (
    .HCLK(HCLK), 
    .HRESETn(HRESETn),
    .HSEL(HSEL[6]), 
    .HADDR(HADDR), 
    .HWRITE(HWRITE), 
    .HTRANS(HTRANS), 
    .HSIZE(HSIZE), 
    .HBURST(HBURST), 
    .HWDATA(HWDATA), 
    .HREADY(HREADY),
    .s6_HREADY(s6_HREADY), 
    .s6_HRESP(s6_HRESP), 
    .s6_HRDATA(s6_HRDATA)
);

SRAM sram_instance (
    .HCLK(HCLK), 
    .HRESETn(HRESETn),
    .HSEL(HSEL[5]), 
    .HADDR(HADDR), 
    .HWRITE(HWRITE), 
    .HTRANS(HTRANS), 
    .HSIZE(HSIZE), 
    .HBURST(HBURST), 
    .HWDATA(HWDATA), 
    .HREADY(HREADY),
    .s5_HREADY(s5_HREADY), 
    .s5_HRESP(s5_HRESP), 
    .s5_HRDATA(s5_HRDATA)
);

DMAC dmac_instance (
    .HCLK(HCLK), 
    .HRESETn(HRESETn), 
    .HREADY(HREADY),
    .HTRANS(HTRANS), 
    .HSEL(HSEL[4]), 
    .HWRITE(HWRITE), 
    .HADDR(HADDR), 
    .HWDATA(HWDATA),
    .HSIZE(HSIZE), 
    .HBURST(HBURST),
    .s_out_HRDATA(s4_HRDATA), // 예를 들어 HRDATA 신호를 s_out_HRDATA 포트에 연결
    .s_out_HRESP(s4_HRESP), 
    .s_out_HREADY(s4_HREADY),
    .HRESP(HRESP), 
    .HRDATA(HRDATA), 
    .HGRANT(HGRANT[1]),
    .m_HTRANS(m1_HTRANS), 
    .m_HBURST(m1_HBURST), 
    .m_HSIZE(m1_HSIZE), 
    .m_HADDR(m1_HADDR),
    .m_HWRITE(m1_HWRITE), 
    .m_HWDATA(m1_HWDATA), 
    .m_HPROT(m1_HPROT), 
    .m_HLOCK(m1_HLOCK), 
    .m_HBUSREQ(m1_HBUSREQ), 
    .DMACINTR(DMACINTR)
);

ahb_arbiter_fixed arbiter_instance (
    .HCLK(HCLK), 
    .HRESETn(HRESETn),
    .HBUSREQ(HBUSREQ),
    .HTRANS(HTRANS),
    .HREADY(HREADY),
    .HBURST(HBURST),
    .HGRANT(HGRANT),
    .HMASTER(HMASTER),
    .HMASTER_del(HMASTER_del)
);

ahb ahb_inst(
    .HCLK(HCLK), 
    .HRESETn(HRESETn), 
    .m0_HTRANS(m0_HTRANS), .m0_HBURST(m0_HBURST), .m0_HSIZE(m0_HSIZE), .m0_HPROT(m0_HPROT), .m0_HADDR(m0_HADDR), .m0_HWRITE(m0_HWRITE), .m0_HWDATA(m0_HWDATA),
    .m1_HTRANS(m1_HTRANS), .m1_HBURST(m1_HBURST), .m1_HSIZE(m1_HSIZE), .m1_HPROT(m1_HPROT), .m1_HADDR(m1_HADDR), .m1_HWRITE(m1_HWRITE), .m1_HWDATA(m1_HWDATA),
    .m2_HTRANS(m2_HTRANS), .m2_HBURST(m2_HBURST), .m2_HSIZE(m2_HSIZE), .m2_HPROT(m2_HPROT), .m2_HADDR(m2_HADDR), .m2_HWRITE(m2_HWRITE), .m2_HWDATA(m2_HWDATA),
    .s0_HREADY(s0_HREADY), .s0_HRESP(s0_HRESP), .s0_HRDATA(s0_HRDATA), .s0_HSPLIT(s0_HSPLIT),
    .s1_HREADY(s1_HREADY), .s1_HRESP(s1_HRESP), .s1_HRDATA(s1_HRDATA), .s1_HSPLIT(s1_HSPLIT),
	.s2_HREADY(s2_HREADY), .s2_HRESP(s2_HRESP), .s2_HRDATA(s2_HRDATA), .s2_HSPLIT(s2_HSPLIT),
    .s3_HREADY(s3_HREADY), .s3_HRESP(s3_HRESP), .s3_HRDATA(s3_HRDATA), .s3_HSPLIT(s3_HSPLIT),
	.s4_HREADY(s4_HREADY), .s4_HRESP(s4_HRESP), .s4_HRDATA(s4_HRDATA), .s4_HSPLIT(s4_HSPLIT),
    .s5_HREADY(s5_HREADY), .s5_HRESP(s5_HRESP), .s5_HRDATA(s5_HRDATA), .s5_HSPLIT(s5_HSPLIT),
	.s6_HREADY(s6_HREADY), .s6_HRESP(s6_HRESP), .s6_HRDATA(s6_HRDATA), .s6_HSPLIT(s6_HSPLIT),
    .s7_HREADY(s7_HREADY), .s7_HRESP(s7_HRESP), .s7_HRDATA(s7_HRDATA), .s7_HSPLIT(s7_HSPLIT),
    .HMASTER(HMASTER), .HMASTER_del(HMASTER_del),
    .HREADY(HREADY), .HRESP(HRESP), .HRDATA(HRDATA),
    .HSEL(HSEL), .HTRANS(HTRANS), .HBURST(HBURST), .HSIZE(HSIZE), .HADDR(HADDR), .HWRITE(HWRITE), .HWDATA(HWDATA), .HSPLIT(HSPLIT)
);

endmodule