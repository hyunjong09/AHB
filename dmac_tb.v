`timescale 1ns / 1ps

module DMAC_tb;

// DMAC Module Inputs
reg HCLK;
reg HRESETn;
reg [1:0] HTRANS;
reg HSEL;
reg HREADY;
reg HWRITE;
reg [31:0] HADDR;
reg [31:0] HWDATA;
reg [2:0] HSIZE;
reg [3:0] HBURST;
reg [1:0] HRESP;
reg [31:0] HRDATA;
reg HGRANT;

// DMAC Module Outputs
wire [31:0] s_out_HRDATA;
wire [1:0] s_out_HRESP;
wire s_out_HREADY;
wire [1:0] m_HTRANS;
wire [2:0] m_HBURST; 
wire [2:0] m_HSIZE;
wire [31:0] m_HADDR;
wire m_HWRITE; 
wire [31:0] m_HWDATA; 
wire [3:0] m_HPROT;
wire m_HLOCK; 
wire m_HBUSREQ; 
wire DMACINTR;

// Instantiate the DMAC module
DMAC uut (
    .HCLK(HCLK), 
    .HRESETn(HRESETn), 
    .HTRANS(HTRANS), 
    .HSEL(HSEL), 
    .HREADY(HREADY), 
    .HWRITE(HWRITE), 
    .HADDR(HADDR), 
    .HWDATA(HWDATA), 
    .HSIZE(HSIZE), 
    .HBURST(HBURST), 
    .s_out_HRDATA(s_out_HRDATA), 
    .s_out_HRESP(s_out_HRESP), 
    .s_out_HREADY(s_out_HREADY), 
    .HRESP(HRESP), 
    .HRDATA(HRDATA), 
    .HGRANT(HGRANT), 
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

// Initialize Inputs and Generate Clock
initial begin
    // Initialize Inputs
    HCLK <= 1;
    HRESETn <= 0;
    HTRANS <= 0;
    HSEL <= 1;
    HREADY <= 1; // Assuming ready by default
    HWRITE <= 1;
    HADDR <= 0;
    HWDATA <= 0;
    HSIZE <= 0;
    HBURST <= 0;
    HRESP <= 0;
    HRDATA <= 0;
    HGRANT <= 0;
   #20 HRESETn <= 1;
end

initial
begin
   #40 HTRANS <= 2'b10;
   #200 HTRANS <= 2'b00;
end

initial
begin
   #320 HGRANT <=1;
   #160 HGRANT <=0;
   #40 HGRANT <=1;
   #240 HGRANT <=1;
   #40 HGRANT <=1;
end


initial
begin
   #40 HADDR <= 32'h20000030;
   #40 HADDR <= 32'h2000010C;
   #40 HADDR <= 32'h20000100;
   #40 HADDR <= 32'h20000104;
   #40 HADDR <= 32'h20000110;
   #40 HADDR <= 32'h00000000;
end

initial
begin
   #80 HWDATA <= 32'h00000001;
   #40 HWDATA <= 32'h00003078;
   #40 HWDATA <= 32'h38001000;
   #40 HWDATA <= 32'h38002000;
   #40 HWDATA <= 32'h00000001;
end

initial
begin
   #400 HRDATA <= 32'h00000001;
   #40 HRDATA <= 32'h00000002;
   #40 HRDATA <= 32'h00000003;
   #40 HRDATA <= 32'h00000004;
   #40 HRDATA <= 32'h00000005;
   #40 HRDATA <= 32'h00000006;
   #40 HRDATA <= 32'h00000007;
   #40 HRDATA <= 32'h00000008;
   #40 HRDATA <= 32'h00000009;
   #40 HRDATA <= 32'h0000000A;
   #40 HRDATA <= 32'h0000000B;
   #40 HRDATA <= 32'h0000000C;
   #40 HRDATA <= 32'h0000000D;
   #40 HRDATA <= 32'h0000000E;
   #40 HRDATA <= 32'h0000000F;
   #40 HRDATA <= 32'h00000010;
   #720 HRDATA <= 32'h00000011;
   #40 HRDATA <= 32'h00000012;
   #40 HRDATA <= 32'h00000013;
   #40 HRDATA <= 32'h00000014;
   #40 HRDATA <= 32'h00000015;
   #40 HRDATA <= 32'h00000016;
   #40 HRDATA <= 32'h00000017;
   #40 HRDATA <= 32'h00000018;
   #40 HRDATA <= 32'h00000019;
   #40 HRDATA <= 32'h0000001A;
   #40 HRDATA <= 32'h0000001B;
   #40 HRDATA <= 32'h0000001C;
   #40 HRDATA <= 32'h0000001D;
   #40 HRDATA <= 32'h0000001E;
end

// Clock generation
always #20 HCLK = ~HCLK; // 50MHz clock

// Test Cases
endmodule