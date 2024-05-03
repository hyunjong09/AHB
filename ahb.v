module ahb(HCLK, HRESETn, 
      //inputs from masters   
      m0_HTRANS, m0_HBURST, m0_HSIZE, m0_HPROT, m0_HADDR, m0_HWRITE, m0_HWDATA,      //Master_0
      m1_HTRANS, m1_HBURST, m1_HSIZE, m1_HPROT, m1_HADDR, m1_HWRITE, m1_HWDATA,      //Master_1
      m2_HTRANS, m2_HBURST, m2_HSIZE, m2_HPROT, m2_HADDR, m2_HWRITE, m2_HWDATA,    //Master_2
      
      //inputs from slaves
      s0_HREADY, s0_HRESP, s0_HRDATA, s0_HSPLIT,            //Slave_0
      s1_HREADY, s1_HRESP, s1_HRDATA, s1_HSPLIT,            //Slave_1
      s2_HREADY, s2_HRESP, s2_HRDATA, s2_HSPLIT,            //Slave_2
      s3_HREADY, s3_HRESP, s3_HRDATA, s3_HSPLIT,            //Slave_3
      s4_HREADY, s4_HRESP, s4_HRDATA, s4_HSPLIT,            //Slave_4
      s5_HREADY, s5_HRESP, s5_HRDATA, s5_HSPLIT,            //Slave_5
      s6_HREADY, s6_HRESP, s6_HRDATA, s6_HSPLIT,            //Slave_6
      s7_HREADY, s7_HRESP, s7_HRDATA, s7_HSPLIT,            //Slave_7
      
      //input from arbiter
      HMASTER, HMASTER_del,
      
      //outputs to masters
      HREADY, HRESP, HRDATA,
      //outputs to slaves
      HSEL, HTRANS, HBURST, HSIZE, HADDR, HWRITE, HWDATA, HSPLIT
      );
   `include "amba_h.v"
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
      
   input [W_MASTER-1:0] HMASTER;
   input [W_MASTER-1:0] HMASTER_del;
   //inputs from masters
   //master 0
   input [`W_TRANS-1:0] m0_HTRANS;
   input [`W_BURST-1:0] m0_HBURST;
   input [`W_SIZE-1:0]  m0_HSIZE;
   input [`W_PROT-1:0]  m0_HPROT;
   input [W_ADDR-1:0]   m0_HADDR;
   input                m0_HWRITE;
   input [W_DATA-1:0]   m0_HWDATA;
   //master 1
   input [`W_TRANS-1:0] m1_HTRANS;
   input [`W_BURST-1:0] m1_HBURST;
   input [`W_SIZE-1:0]  m1_HSIZE;
   input [`W_PROT-1:0]  m1_HPROT;
   input [W_ADDR-1:0]   m1_HADDR;
   input                m1_HWRITE;
   input [W_DATA-1:0]   m1_HWDATA;
   //master 2
   input [`W_TRANS-1:0] m2_HTRANS;
   input [`W_BURST-1:0] m2_HBURST;
   input [`W_SIZE-1:0]  m2_HSIZE;
   input [`W_PROT-1:0]  m2_HPROT;
   input [W_ADDR-1:0]   m2_HADDR;
   input                m2_HWRITE;
   input [W_DATA-1:0]   m2_HWDATA;
   
   //inputs from slaves
   //slave 0
   input                s0_HREADY;
   input [`W_RESP-1:0]  s0_HRESP;
   input [W_DATA-1:0]   s0_HRDATA;
   input [N_MASTER-1:0] s0_HSPLIT;
   //slave 1
   input                s1_HREADY;
   input [`W_RESP-1:0]  s1_HRESP;
   input [W_DATA-1:0]   s1_HRDATA;
   input [N_MASTER-1:0] s1_HSPLIT;
   //slave 2
   input                s2_HREADY;
   input [`W_RESP-1:0]  s2_HRESP;
   input [W_DATA-1:0]   s2_HRDATA;
   input [N_MASTER-1:0] s2_HSPLIT;
   //slave 3
   input                s3_HREADY;
   input [`W_RESP-1:0]  s3_HRESP;
   input [W_DATA-1:0]   s3_HRDATA;
   input [N_MASTER-1:0] s3_HSPLIT;
   //slave 4
   input                s4_HREADY;
   input [`W_RESP-1:0]  s4_HRESP;
   input [W_DATA-1:0]   s4_HRDATA;
   input [N_MASTER-1:0] s4_HSPLIT;
   //slave 6
   input                s5_HREADY;
   input [`W_RESP-1:0]  s5_HRESP;
   input [W_DATA-1:0]   s5_HRDATA;
   input [N_MASTER-1:0] s5_HSPLIT;
   //slave 7
   input                s6_HREADY;
   input [`W_RESP-1:0]  s6_HRESP;
   input [W_DATA-1:0]   s6_HRDATA;
   input [N_MASTER-1:0] s6_HSPLIT;
   
   //slave 7
   input                s7_HREADY;
   input [`W_RESP-1:0]  s7_HRESP;
   input [W_DATA-1:0]   s7_HRDATA;
   input [N_MASTER-1:0] s7_HSPLIT;
   
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
   
   //outputs to masters
   reg                 HREADY;
   reg [`W_RESP-1:0]   HRESP;
   reg [W_DATA-1:0]    HRDATA;
   //outputs to slaves
   reg [N_SLAVE-1:0]   HSEL;
   reg [W_SLAVE-1:0]   HSLAVE;
   reg [`W_TRANS-1:0]  HTRANS;
   reg [`W_BURST-1:0]  HBURST;
   reg [`W_SIZE-1:0]   HSIZE;
   reg [W_ADDR-1:0]    HADDR;
   reg                 HWRITE;
   reg [W_DATA-1:0]    HWDATA;
   
   wire HMASTLOCK;
   
   //registers
   reg [N_SLAVE-1:0]   q_HSEL;

   //internal
   reg [`W_PROT-1:0]  HPROT;
   
   
   // Address & Control Multiplexer
   always @(*) 
   begin
      case (HMASTER)
         0: begin
            HADDR = m0_HADDR;
            HTRANS = m0_HTRANS;
            HBURST = m0_HBURST;
            HSIZE = m0_HSIZE;
            HPROT = m0_HPROT;
            HWRITE = m0_HWRITE;
         end
         1: begin
            HADDR = m1_HADDR;
            HTRANS = m1_HTRANS;
            HBURST = m1_HBURST;
            HSIZE = m1_HSIZE;
            HPROT = m1_HPROT;
            HWRITE = m1_HWRITE;
         end
         2: begin
            HADDR = m2_HADDR;
            HTRANS = m2_HTRANS;
            HBURST = m2_HBURST;
            HSIZE = m2_HSIZE;
            HPROT = m2_HPROT;
            HWRITE = m2_HWRITE;
         end
         // ... 다른 마스터에 대해서도 같은 패턴으로 추가 ...
      endcase
   end

   always@(*)
   begin
      case(HMASTER_del)
         2'b00 : HWDATA = m0_HWDATA;
         2'b01 : HWDATA = m1_HWDATA;
         2'b10 : HWDATA = m2_HWDATA;
      default : HWDATA = m0_HWDATA;
      endcase
   end

   always@(*)
   begin
      case(HSLAVE)
         0 : begin
            HREADY = s0_HREADY;
            HRESP = s0_HRESP;
            HRDATA = s0_HRDATA;
         end
         1 : begin
            HREADY = s1_HREADY;
            HRESP = s1_HRESP;
            HRDATA = s1_HRDATA;
         end
         2 : begin
            HREADY = s2_HREADY;
            HRESP = s2_HRESP;
            HRDATA = s2_HRDATA;
         end
         3 : begin
            HREADY = s3_HREADY;
            HRESP = s3_HRESP;
            HRDATA = s3_HRDATA;
         end
         4 : begin
            HREADY = s4_HREADY;
            HRESP = s4_HRESP;
            HRDATA = s4_HRDATA;
         end
         5 : begin
            HREADY = s5_HREADY;
            HRESP = s5_HRESP;
            HRDATA = s5_HRDATA;
         end
         6: begin
            HREADY = s6_HREADY;
            HRESP = s6_HRESP;
            HRDATA = s6_HRDATA;
         end
         7 : begin
            HREADY = s7_HREADY;
            HRESP = s7_HRESP;
            HRDATA = s7_HRDATA;
         end
      endcase
   end
   
   always@(*)
   begin
      if(HADDR[28:26] >= 3'b000 && HADDR[28:26] < 3'b100) begin
         case(HADDR[15:12])
            4'b0001 : begin
               HSEL = 8'b0000_0001;
            end
            4'b0010 : begin
               HSEL = 8'b0000_0010;
            end
            4'b0100 : begin
               HSEL = 8'b0000_0100;
            end
            4'b0101: begin
               HSEL = 8'b0000_1000;
            end
            4'b0110 : begin
               HSEL = 8'b0001_0000;
            end
            default : begin
               HSEL = 8'b1000_0000;
            end
         endcase
      end

      else begin
         case(HADDR[28:26]) 
            3'b110 : begin
               HSEL = 8'b0010_0000;
         end
            3'b111 : begin
               HSEL = 8'b0100_0000;
         end
            default : begin
               HSEL = 8'b1000_0000;
         end
         endcase
      end
   end
   
   always@(posedge HCLK or negedge HRESETn)
   begin
      if(!HRESETn) begin
         q_HSEL = 8'b0000_0000;
         HSLAVE = 3'b111;
      end
      q_HSEL = HSEL;
      case(q_HSEL)
         8'b0000_0001 : HSLAVE = 0;
         8'b0000_0010 : HSLAVE = 1;
         8'b0000_0100 : HSLAVE = 2;
         8'b0000_1000 : HSLAVE = 3;
         8'b0001_0000 : HSLAVE = 4;
         8'b0010_0000 : HSLAVE = 5;
         8'b0100_0000 : HSLAVE = 6;
         8'b1000_0000 : HSLAVE = 7;
      endcase
         
         
   end
endmodule