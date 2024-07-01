module fir_filter_input_control( clk, rst_n, tc_write, cnt_mod, input_data0, input_data1, input_data2, IO_data_p0_t0, IO_data_p0_t1, IO_data_p0_t2, IO_data_p0_t3, IO_data_p0_t4, IO_data_p0_t5, IO_data_p0_t6, IO_data_p0_t7, IO_data_p0_t8,
				IO_data_p1_t0, IO_data_p1_t1, IO_data_p1_t2, IO_data_p1_t3, IO_data_p1_t4, IO_data_p1_t5, IO_data_p1_t6, IO_data_p1_t7, IO_data_p1_t8,
				IO_data_p2_t0, IO_data_p2_t1, IO_data_p2_t2, IO_data_p2_t3, IO_data_p2_t4, IO_data_p2_t5, IO_data_p2_t6, IO_data_p2_t7, IO_data_p2_t8);
   //-------------------------parameters---------------------------//
   //FSM
   //-------------------------------------------------------------//
   //---------------------Signal & Registers----------------------//
   //Clock 
   input clk;
   input rst_n;
   input [1:0]cnt_mod;
   //Input
    input [23:0] input_data0, input_data1, input_data2;
   input tc_write;

   
   //wire&reg
	output reg [23:0] IO_data_p0_t0, IO_data_p0_t1, IO_data_p0_t2, IO_data_p0_t3, IO_data_p0_t4, IO_data_p0_t5, IO_data_p0_t6, IO_data_p0_t7, IO_data_p0_t8,
				IO_data_p1_t0, IO_data_p1_t1, IO_data_p1_t2, IO_data_p1_t3, IO_data_p1_t4, IO_data_p1_t5, IO_data_p1_t6, IO_data_p1_t7, IO_data_p1_t8,
				IO_data_p2_t0, IO_data_p2_t1, IO_data_p2_t2, IO_data_p2_t3, IO_data_p2_t4, IO_data_p2_t5, IO_data_p2_t6, IO_data_p2_t7, IO_data_p2_t8;
			
	
	// parameters---------------------------//

	
   //------------------------------- instance cacl module ------------------------------//
	
   //------------------------------- instance acc module ------------------------------//

    //demux_input / pipelinning
	always @(posedge clk) // posedge clk?? ??? ??????? cnt modulo ??? ?????
	 begin
	if (cnt_mod == 0)
		begin
		IO_data_p0_t2 <= input_data0;
		IO_data_p0_t5 <= input_data1;
		IO_data_p0_t8 <= input_data2;
		end
	else if (cnt_mod == 1)
		begin
		IO_data_p1_t2 <= input_data0;
		IO_data_p1_t5 <= input_data1;
		IO_data_p1_t8 <= input_data2;
		end
	else 
		begin
		IO_data_p2_t2 <= input_data0;
		IO_data_p2_t5 <= input_data1;
		IO_data_p2_t8 <= input_data2;
		end
	end
	//IO reg Input data reuse
	always @(posedge clk)
		begin
		//2-1-0
		IO_data_p2_t1 <= IO_data_p1_t2; 
		IO_data_p2_t0 <= IO_data_p1_t1; 
		IO_data_p1_t1 <= IO_data_p0_t2; 
		IO_data_p1_t0 <= IO_data_p0_t1; 
		IO_data_p0_t1 <= IO_data_p2_t2;
		IO_data_p0_t0 <= IO_data_p2_t1;
		// 5-4-3
		IO_data_p2_t4 <= IO_data_p1_t5; 
		IO_data_p2_t3 <= IO_data_p1_t4;
		IO_data_p1_t4 <= IO_data_p0_t5; 
		IO_data_p1_t3 <= IO_data_p0_t4; 
		IO_data_p0_t4 <= IO_data_p2_t5;
		IO_data_p0_t3 <= IO_data_p2_t4;
		// 8-7-6
		IO_data_p2_t7 <= IO_data_p1_t8; 
		IO_data_p2_t6 <= IO_data_p1_t7;
		IO_data_p1_t7 <= IO_data_p0_t8; 
		IO_data_p1_t6 <= IO_data_p0_t7; 
		IO_data_p0_t7 <= IO_data_p2_t8;
		IO_data_p0_t6 <= IO_data_p2_t7;	
		end
	// output_serial_out

endmodule