module fir_filter_calc( clk, rst_n, io_data, tc_data, tc_write, tc_en, mac_en, mac_clr, filter_r, filter_g, filter_b);
   //-------------------------parameters---------------------------//
   //FSM
   //-------------------------------------------------------------//
   //---------------------Signal & Registers----------------------//
   //Clock 
   input clk;
   input rst_n;
   input [23:0]tc_data;
   //Input
   input tc_write, tc_en, mac_en, mac_clr;
   input [23:0] io_data;
  
   //Output
   output reg signed [16:0] filter_r, filter_g, filter_b;
   
   //wire&reg
   reg [23:0] demux_img, demux_tc;
   //reg [1:0] ps,ns;
   reg signed [7:0] tc_r, tc_g, tc_b;


   //demux
/*
   always@(*)begin   
      if (tc_write==0) begin 
         demux_img<=io_data;
         demux_tc<=24'bx; end
      else begin 
         demux_img<=24'bx; 
         demux_tc<=io_data; end
      end
   //TC_reg
   */
	always@(*)
	begin
	demux_img <= io_data;
	end

   always@(*)
	begin
	end

   always @(*)
   begin
      if ((tc_write == 1)&&(tc_en==1))
         begin
         tc_r = tc_data[23:16];
         tc_g = tc_data[15:8];
         tc_b = tc_data[7:0];   
         end
      else
      begin
         tc_r = tc_r;
         tc_g = tc_g;
         tc_b = tc_b;
   end
   end
 
// MUL
always @ (*)
/*if(!rst_n) begin filter_r<=20'b0; filter_g<=20'b0; filter_b<=20'b0; end
      else if(mac_clr==1) begin filter_r<=20'b0; filter_g<=20'b0; filter_b<=20'b0;
      end
      
      else */if (mac_en==1) begin
		begin
		filter_r <= tc_r * $signed( { 1'b0, demux_img[23:16] } );
	        filter_g <= tc_g * $signed( { 1'b0, demux_img[15:8] } );
	        filter_b <= tc_b * $signed( { 1'b0, demux_img[7:0] } ); 
		end
	  end
      else begin filter_r<= filter_r; filter_g<= filter_g; filter_b<= filter_b; end         


//output
endmodule