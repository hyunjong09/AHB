module fir_filter_acc_output( clk, rst_n, mac_en, output_en, mac_clr,
filter_r_t0, filter_g_t0, filter_b_t0, 
filter_r_t1, filter_g_t1, filter_b_t1, 
filter_r_t2, filter_g_t2, filter_b_t2, 
filter_r_t3, filter_g_t3, filter_b_t3, 
filter_r_t4, filter_g_t4, filter_b_t4, 
filter_r_t5, filter_g_t5, filter_b_t5, 
filter_r_t6, filter_g_t6, filter_b_t6, 
filter_r_t7, filter_g_t7, filter_b_t7,
filter_r_t8, filter_g_t8, filter_b_t8,
output_data_pipe);
   //-------------------------parameters---------------------------//
   //FSM
   //-------------------------------------------------------------//
   //---------------------Signal & Registers----------------------//
   //Clock 
   input clk;
   input rst_n;
   
   //Input
   input mac_en, output_en, mac_clr;
   input signed [16:0] filter_r_t0, filter_g_t0, filter_b_t0, 
	filter_r_t1, filter_g_t1, filter_b_t1, 
	filter_r_t2, filter_g_t2, filter_b_t2, 
	filter_r_t3, filter_g_t3, filter_b_t3, 
	filter_r_t4, filter_g_t4, filter_b_t4, 
	filter_r_t5, filter_g_t5, filter_b_t5, 
	filter_r_t6, filter_g_t6, filter_b_t6, 
	filter_r_t7, filter_g_t7, filter_b_t7,
	filter_r_t8, filter_g_t8, filter_b_t8;
   //Output

   output reg [23:0] output_data_pipe;
   //wire&reg
   reg signed [20:0] filter_out_r, filter_out_g, filter_out_b;

	// integer
	reg [3:0] i ;
   //ACC_RGB
   always@(posedge clk, negedge rst_n)
/*      if(!rst_n) begin filter_out_r<=20'b0; filter_out_g<=20'b0; filter_out_b<=20'b0; end
      else if(mac_clr==1) begin filter_out_r<=20'b0; filter_out_g<=20'b0; filter_out_b<=20'b0;
      end
      
      else*/ if (mac_en==1) begin
		begin
		filter_out_r <=  filter_r_t0 + filter_r_t1 + filter_r_t2 + filter_r_t3 + filter_r_t4 + filter_r_t5 + filter_r_t6 + filter_r_t7 + filter_r_t8;
		filter_out_g <=  filter_g_t0 + filter_g_t1 + filter_g_t2 + filter_g_t3 + filter_g_t4 + filter_g_t5 + filter_g_t6 + filter_g_t7 + filter_g_t8;
		filter_out_b <=  filter_b_t0 + filter_b_t1 + filter_b_t2 + filter_b_t3 + filter_b_t4 + filter_b_t5 + filter_b_t6 + filter_b_t7 + filter_b_t8; 
		end
	  end
      else begin filter_out_r<= filter_out_r; filter_out_g<= filter_out_g; filter_out_b<= filter_out_b; end         

   //Saturation & Output module
      always @(posedge clk, negedge rst_n)
/*      if(!rst_n) output_data_pipe<=24'b0;
      else */if(mac_en==1) 
	  begin 
         //red
		if(filter_out_r[20] == 1) output_data_pipe[23:16]<= 0;
		else if(filter_out_r[19:0]>8'b11111111) output_data_pipe[23:16]<= 8'b11111111;
		else output_data_pipe[23:16]<= filter_out_r[7:0];
         //green
		if (filter_out_g[20]==1) output_data_pipe[15:8]<= 0;
		else if (filter_out_g[19:0]>8'b1111_1111) output_data_pipe[15:8]<=8'b11111111;
		else output_data_pipe[15:8] <= filter_out_g[7:0];
         //blue
		if (filter_out_b[20]==1) output_data_pipe[7:0]<= 0;
		else if (filter_out_b[19:0]>8'b1111_1111) output_data_pipe[7:0]<=8'b11111111;
		else output_data_pipe[7:0] <= filter_out_b[7:0];
      end
   else output_data_pipe<=output_data_pipe;
      
endmodule