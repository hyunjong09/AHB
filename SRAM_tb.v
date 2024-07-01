`timescale 1ns / 1ps

module SRAM_tb;

// Parameters
parameter MEM_WIDTH = 8;
parameter MEM_DEPTH = 256;
parameter HADDR_MAX = MEM_DEPTH - 1;

// Inputs
reg HCLK;
reg HRESETn;
reg HSEL;
reg [31:0] HADDR;
reg HWRITE;
reg [1:0] HTRANS;
reg [2:0] HSIZE;
reg [2:0] HBURST;
reg [31:0] HWDATA;
reg HREADY;

// s5puts
wire s5_HREADY;
wire [31:0] s5_HRDATA;
wire [1:0] s5_HRESP;

// Instantiate the Unit Under Test (UUT)
SRAM uut (
    .HCLK(HCLK), 
    .HRESETn(HRESETn), 
    .HSEL(HSEL), 
    .HADDR(HADDR), 
    .HWRITE(HWRITE), 
    .HTRANS(HTRANS), 
    .HSIZE(HSIZE), 
    .HBURST(HBURST), 
    .HWDATA(HWDATA), 
    .HREADY(HREADY), 
    .s5_HREADY(s5_HREADY), 
    .s5_HRDATA(s5_HRDATA), 
    .s5_HRESP(s5_HRESP)
);

// Clock generation
always #20 HCLK = !HCLK; 

initial begin
    // Initialize Inputs
	HCLK <=1;
    HRESETn <= 0;
    HSEL <= 0;
    HADDR <= 0;
    HWRITE <= 0;
    HBURST <= 3'b000;
    HWDATA <= 0;
	#20;
	HRESETn <=1;
	HSEL <=1;
end

initial begin
    HSIZE <= 3'b010;
	#440 HSIZE <=3'b000;
	#400 HSIZE <=3'b001;
end
initial begin
	HREADY <=1;
	//#120 HREADY <=0;
	//#80 HREADY <=1;
end


initial begin
	#40 HADDR <= 32'h00000000;
	#40 HADDR <= 32'h00000004;
	#40 HADDR <= 32'h00000008;
	#40 HADDR <= 32'h0000000C;
	#80 HADDR <= 32'h00000000;
	#40 HADDR <= 32'h00000004;
	#40 HADDR <= 32'h00000008;
	#40 HADDR <= 32'h0000000C;
	#80 HADDR <= 32'h00000010;
	#40 HADDR <= 32'h00000011;
	#40 HADDR <= 32'h00000012;
	#40 HADDR <= 32'h00000013;
	#80 HADDR <= 32'h00000010;
	#40 HADDR <= 32'h00000011;
	#40 HADDR <= 32'h00000012;
	#40 HADDR <= 32'h00000013;
	#80 HADDR <= 32'h00000020;
	#40 HADDR <= 32'h00000022;
	#40 HADDR <= 32'h00000024;
	#40 HADDR <= 32'h00000026;
	#80 HADDR <= 32'h00000020;
	#40 HADDR <= 32'h00000022;
	#40 HADDR <= 32'h00000024;
	#40 HADDR <= 32'h00000026;
end

initial begin
	#80 HWDATA <= 32'h12345678;
	#40 HWDATA <= 32'h34567812;
	#40 HWDATA <= 32'h56781234;
	#40 HWDATA <= 32'h78123456;
	#280 HWDATA <= 32'h12345678;
	#40 HWDATA <= 32'h34567812;
	#40 HWDATA <= 32'h56781234;
	#40 HWDATA <= 32'h78123456;
	#280 HWDATA <= 32'h12345678;
	#40 HWDATA <= 32'h34567812;
	#40 HWDATA <= 32'h56781234;
	#40 HWDATA <= 32'h78123456;
end

initial begin
	#40 HWRITE <= 1;
	#160 HWRITE <= 0;
	#240 HWRITE <= 1;
	#160 HWRITE <=0;
	#240 HWRITE <=1;
	#160 HWRITE <=0;

end

initial begin
	#40 HTRANS <= 2'b10;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b00;
	#40 HTRANS <= 2'b10;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b00;
	#40 HTRANS <= 2'b10;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b00;
	#40 HTRANS <= 2'b10;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b00;
	#40 HTRANS <= 2'b10;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b00;
	#40 HTRANS <= 2'b10;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
	#40 HTRANS <= 2'b11;
end

endmodule