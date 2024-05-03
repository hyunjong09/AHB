`include "ahb_macro_h.v"
`include "amba_h.v"
`timescale 1ns / 1ps
module ahb_test_tb;

// Inputs
reg HCLK;
reg HRESETn;
reg [1:0] m0_HTRANS;
reg [2:0] m0_HBURST;
reg [2:0] m0_HSIZE;
reg [3:0] m0_HPROT;
reg [31:0] m0_HADDR;
reg m0_HWRITE;
reg [31:0] m0_HWDATA;
reg m0_HBUSREQ;
reg m2_HBUSREQ;

// Outputs
wire HREADY;
wire [1:0] HRESP;
wire [31:0] HRDATA;
wire [7:0] HSEL;
wire [1:0] HTRANS;
wire [2:0] HBURST;
wire [2:0] HSIZE;
wire [31:0] HADDR;
wire HWRITE;
wire [31:0] HWDATA;
wire [7:0] HSPLIT;

// Instantiate the Unit Under Test (UUT)
ahb_test uut (
    .HCLK(HCLK), 
    .HRESETn(HRESETn),
    .m0_HTRANS(m0_HTRANS), .m0_HBURST(m0_HBURST), .m0_HSIZE(m0_HSIZE), .m0_HPROT(m0_HPROT), 
    .m0_HADDR(m0_HADDR), .m0_HWRITE(m0_HWRITE), .m0_HWDATA(m0_HWDATA),
    .m0_HBUSREQ(m0_HBUSREQ), .m2_HBUSREQ(m2_HBUSREQ),
    .HREADY(HREADY), .HRESP(HRESP), .HRDATA(HRDATA),
    .HSEL(HSEL), .HTRANS(HTRANS), .HBURST(HBURST), .HSIZE(HSIZE), .HADDR(HADDR), .HWRITE(HWRITE), .HWDATA(HWDATA), .HSPLIT(HSPLIT)
);

initial begin
	m2_HBUSREQ <=1'b0;
end

assign HREADY =1'b1;

always #20 HCLK = !HCLK; // Clock period of 10 ns

initial begin
    // Initialize Inputs
    HCLK <= 1;
    HRESETn <= 0;
	#20 HRESETn <=1;
end



initial begin
	m0_HBUSREQ <=1;
	#200 m0_HBUSREQ <=0;
end

initial begin
	#40 m0_HSIZE <= 3'b010;
end

initial begin
	#40 m0_HTRANS <= 2'b10;
	#200 m0_HTRANS <= 2'b00;
end
initial begin
    m0_HPROT = 0;
end
initial begin
   #40 m0_HADDR <= 32'h04006030;
   #40 m0_HADDR <= 32'h0400610C;
   #40 m0_HADDR <= 32'h04006100;
   #40 m0_HADDR <= 32'h04006104;
   #40 m0_HADDR <= 32'h04006110;
   #40 m0_HADDR <= 32'h00000000;
end

initial begin
	#40 m0_HBURST <= 3'b000;
end

initial begin
    #40 m0_HWRITE <= 1;
	#200 m0_HWRITE <= 0;
end

initial
begin
   #80 m0_HWDATA <= 32'h00000001;
   #40 m0_HWDATA <= 32'h00001010;
   #40 m0_HWDATA <= 32'h3C001000;
   #40 m0_HWDATA <= 32'h38002000;
   #40 m0_HWDATA <= 32'h00000001;
end


endmodule
