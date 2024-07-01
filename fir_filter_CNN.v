module fir_filter_CNN( clk, rst_n, tc_data, input_data0, input_data1, input_data2, valid_dmac, tc_set,  output_data, valid_core);
   //-------------------------parameters---------------------------//
   //FSM
   //-------------------------------------------------------------//
   //---------------------Signal & Registers----------------------//
   //Clock 
   input clk;
   input rst_n;
   input tc_set, valid_dmac;
   //Input
   input [31:0] input_data0, input_data1, input_data2;
   input [23:0] tc_data;
   
   //FSM
   parameter IDLE = 3'b000;
   parameter TC_SET = 3'b001;
   parameter COL_0 = 3'b010;
   parameter COL_1 = 3'b011;
   parameter CALC_0 = 3'b100;
   parameter CALC_1 = 3'b101;
   parameter CALC = 3'b110;
   reg [2:0] present_state, next_state;
   
   
   //Outputs
    output reg [31:0]output_data;
    output reg valid_core;
   //wire&reg
	reg [23:0] tc_data_t0, tc_data_t1, tc_data_t2, tc_data_t3, tc_data_t4, tc_data_t5, tc_data_t6, tc_data_t7, tc_data_t8;
	wire [23:0] IO_data_p0_t0, IO_data_p0_t1, IO_data_p0_t2, IO_data_p0_t3, IO_data_p0_t4, IO_data_p0_t5, IO_data_p0_t6, IO_data_p0_t7, IO_data_p0_t8,
				IO_data_p1_t0, IO_data_p1_t1, IO_data_p1_t2, IO_data_p1_t3, IO_data_p1_t4, IO_data_p1_t5, IO_data_p1_t6, IO_data_p1_t7, IO_data_p1_t8,
				IO_data_p2_t0, IO_data_p2_t1, IO_data_p2_t2, IO_data_p2_t3, IO_data_p2_t4, IO_data_p2_t5, IO_data_p2_t6, IO_data_p2_t7, IO_data_p2_t8;
				
	wire signed [16:0] filter_r_p0_t0, filter_r_p0_t1, filter_r_p0_t2, filter_r_p0_t3, filter_r_p0_t4, filter_r_p0_t5, filter_r_p0_t6, filter_r_p0_t7, filter_r_p0_t8,
				filter_r_p1_t0, filter_r_p1_t1, filter_r_p1_t2, filter_r_p1_t3, filter_r_p1_t4, filter_r_p1_t5, filter_r_p1_t6, filter_r_p1_t7, filter_r_p1_t8,
				filter_r_p2_t0, filter_r_p2_t1, filter_r_p2_t2, filter_r_p2_t3, filter_r_p2_t4, filter_r_p2_t5, filter_r_p2_t6, filter_r_p2_t7, filter_r_p2_t8;
	wire signed [16:0] filter_g_p0_t0, filter_g_p0_t1, filter_g_p0_t2, filter_g_p0_t3, filter_g_p0_t4, filter_g_p0_t5, filter_g_p0_t6, filter_g_p0_t7, filter_g_p0_t8,
				filter_g_p1_t0, filter_g_p1_t1, filter_g_p1_t2, filter_g_p1_t3, filter_g_p1_t4, filter_g_p1_t5, filter_g_p1_t6, filter_g_p1_t7, filter_g_p1_t8,
				filter_g_p2_t0, filter_g_p2_t1, filter_g_p2_t2, filter_g_p2_t3, filter_g_p2_t4, filter_g_p2_t5, filter_g_p2_t6, filter_g_p2_t7, filter_g_p2_t8;
	wire signed [16:0] filter_b_p0_t0, filter_b_p0_t1, filter_b_p0_t2, filter_b_p0_t3, filter_b_p0_t4, filter_b_p0_t5, filter_b_p0_t6, filter_b_p0_t7, filter_b_p0_t8,
				filter_b_p1_t0, filter_b_p1_t1, filter_b_p1_t2, filter_b_p1_t3, filter_b_p1_t4, filter_b_p1_t5, filter_b_p1_t6, filter_b_p1_t7, filter_b_p1_t8,
				filter_b_p2_t0, filter_b_p2_t1, filter_b_p2_t2, filter_b_p2_t3, filter_b_p2_t4, filter_b_p2_t5, filter_b_p2_t6, filter_b_p2_t7, filter_b_p2_t8;
	wire [23:0] output_data_pipe_p0, output_data_pipe_p1, output_data_pipe_p2;
	
	
	// parameters---------------------------//
	reg [1:0] cnt_mod, cnt_output_mod;
	integer cnt, cnt_output;
	// Signal
	reg tc_write, tc_en, mac_clr, cnt_clr, mac_en, output_en;

   //------------------------------- instance cacl module ------------------------------/
fir_filter_input_control input_control( .clk(clk), .rst_n(rst_n), .tc_write(tc_wirte), .cnt_mod(cnt_mod), .input_data0(input_data0), .input_data1(input_data1), .input_data2(input_data2),
				.IO_data_p0_t0(IO_data_p0_t0), .IO_data_p0_t1(IO_data_p0_t1), .IO_data_p0_t2(IO_data_p0_t2), .IO_data_p0_t3(IO_data_p0_t3), 
				.IO_data_p0_t4(IO_data_p0_t4), .IO_data_p0_t5(IO_data_p0_t5), .IO_data_p0_t6(IO_data_p0_t6), .IO_data_p0_t7(IO_data_p0_t7), .IO_data_p0_t8(IO_data_p0_t8),
				.IO_data_p1_t0(IO_data_p1_t0), .IO_data_p1_t1(IO_data_p1_t1), .IO_data_p1_t2(IO_data_p1_t2), .IO_data_p1_t3(IO_data_p1_t3), 
				.IO_data_p1_t4(IO_data_p1_t4), .IO_data_p1_t5(IO_data_p1_t5), .IO_data_p1_t6(IO_data_p1_t6), .IO_data_p1_t7(IO_data_p1_t7), .IO_data_p1_t8(IO_data_p1_t8),
				.IO_data_p2_t0(IO_data_p2_t0), .IO_data_p2_t1(IO_data_p2_t1), .IO_data_p2_t2(IO_data_p2_t2), .IO_data_p2_t3(IO_data_p2_t3), 
				.IO_data_p2_t4(IO_data_p2_t4), .IO_data_p2_t5(IO_data_p2_t5), .IO_data_p2_t6(IO_data_p2_t6), .IO_data_p2_t7(IO_data_p2_t7), .IO_data_p2_t8(IO_data_p2_t8));
	
   //------------------------------- instance cacl module ------------------------------//
   //------------------------------- instance acc module ------------------------------//
fir_filter_calc calc_p0_t0( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t0), .tc_data(tc_data_t0),
                     .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                     .filter_r(filter_r_p0_t0), .filter_g(filter_g_p0_t0), 
                     .filter_b(filter_b_p0_t0));

fir_filter_calc calc_p0_t1( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t1), .tc_data(tc_data_t1),
                     .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                     .filter_r(filter_r_p0_t1), .filter_g(filter_g_p0_t1), 
                     .filter_b(filter_b_p0_t1));

fir_filter_calc calc_p0_t2( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t2), .tc_data(tc_data_t2),
                     .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                     .filter_r(filter_r_p0_t2), .filter_g(filter_g_p0_t2), 
                     .filter_b(filter_b_p0_t2));

fir_filter_calc calc_p0_t3( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t3), .tc_data(tc_data_t3),
                     .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                     .filter_r(filter_r_p0_t3), .filter_g(filter_g_p0_t3), 
                     .filter_b(filter_b_p0_t3));   
fir_filter_calc calc_p0_t4( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t4), .tc_data(tc_data_t4),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p0_t4), .filter_g(filter_g_p0_t4), 
                            .filter_b(filter_b_p0_t4));

fir_filter_calc calc_p0_t5( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t5), .tc_data(tc_data_t5),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p0_t5), .filter_g(filter_g_p0_t5), 
                            .filter_b(filter_b_p0_t5));

fir_filter_calc calc_p0_t6( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t6), .tc_data(tc_data_t6),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p0_t6), .filter_g(filter_g_p0_t6), 
                            .filter_b(filter_b_p0_t6));

fir_filter_calc calc_p0_t7( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t7), .tc_data(tc_data_t7),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p0_t7), .filter_g(filter_g_p0_t7), 
                            .filter_b(filter_b_p0_t7));

fir_filter_calc calc_p0_t8( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p0_t8), .tc_data(tc_data_t8),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p0_t8), .filter_g(filter_g_p0_t8), 
                            .filter_b(filter_b_p0_t8));
                     
fir_filter_calc calc_p1_t0( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t0), .tc_data(tc_data_t0),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t0), .filter_g(filter_g_p1_t0), 
                            .filter_b(filter_b_p1_t0));

fir_filter_calc calc_p1_t1( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t1), .tc_data(tc_data_t1),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t1), .filter_g(filter_g_p1_t1), 
                            .filter_b(filter_b_p1_t1));

fir_filter_calc calc_p1_t2( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t2), .tc_data(tc_data_t2),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t2), .filter_g(filter_g_p1_t2), 
                            .filter_b(filter_b_p1_t2));

fir_filter_calc calc_p1_t3( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t3), .tc_data(tc_data_t3),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t3), .filter_g(filter_g_p1_t3), 
                            .filter_b(filter_b_p1_t3));

fir_filter_calc calc_p1_t4( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t4), .tc_data(tc_data_t4),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t4), .filter_g(filter_g_p1_t4), 
                            .filter_b(filter_b_p1_t4));

fir_filter_calc calc_p1_t5( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t5), .tc_data(tc_data_t5),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t5), .filter_g(filter_g_p1_t5), 
                            .filter_b(filter_b_p1_t5));

fir_filter_calc calc_p1_t6( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t6), .tc_data(tc_data_t6),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t6), .filter_g(filter_g_p1_t6), 
                            .filter_b(filter_b_p1_t6));

fir_filter_calc calc_p1_t7( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t7), .tc_data(tc_data_t7),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t7), .filter_g(filter_g_p1_t7), 
                            .filter_b(filter_b_p1_t7));

fir_filter_calc calc_p1_t8( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p1_t8), .tc_data(tc_data_t8),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p1_t8), .filter_g(filter_g_p1_t8), 
                            .filter_b(filter_b_p1_t8));
                     
fir_filter_calc calc_p2_t0( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t0), .tc_data(tc_data_t0),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t0), .filter_g(filter_g_p2_t0), 
                            .filter_b(filter_b_p2_t0));
                     
fir_filter_calc calc_p2_t1( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t1), .tc_data(tc_data_t1),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t1), .filter_g(filter_g_p2_t1), 
                            .filter_b(filter_b_p2_t1));

fir_filter_calc calc_p2_t2( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t2), .tc_data(tc_data_t2),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t2), .filter_g(filter_g_p2_t2), 
                            .filter_b(filter_b_p2_t2));

fir_filter_calc calc_p2_t3( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t3), .tc_data(tc_data_t3),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t3), .filter_g(filter_g_p2_t3), 
                            .filter_b(filter_b_p2_t3));

fir_filter_calc calc_p2_t4( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t4), .tc_data(tc_data_t4),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t4), .filter_g(filter_g_p2_t4), 
                            .filter_b(filter_b_p2_t4));

fir_filter_calc calc_p2_t5( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t5), .tc_data(tc_data_t5),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t5), .filter_g(filter_g_p2_t5),
                            .filter_b(filter_b_p2_t5));

fir_filter_calc calc_p2_t6( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t6), .tc_data(tc_data_t6),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t6), .filter_g(filter_g_p2_t6),
              .filter_b(filter_b_p2_t6));

fir_filter_calc calc_p2_t7( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t7), .tc_data(tc_data_t7),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t7), .filter_g(filter_g_p2_t7),
             .filter_b(filter_b_p2_t7));

fir_filter_calc calc_p2_t8( .clk(clk), .rst_n(rst_n), .io_data(IO_data_p2_t8), .tc_data(tc_data_t8),
                            .tc_write(tc_write), .tc_en(tc_en), .mac_en(mac_en), .mac_clr(mac_clr),
                            .filter_r(filter_r_p2_t8), .filter_g(filter_g_p2_t8),
             .filter_b(filter_b_p2_t8));

fir_filter_acc_output acc_p0( .clk(clk), .rst_n(rst_n), .mac_en(mac_en), .mac_clr(mac_clr), .output_en(output_en),
.filter_r_t0(filter_r_p0_t0), .filter_g_t0(filter_b_p0_t0), .filter_b_t0(filter_b_p0_t0),
.filter_r_t1(filter_r_p0_t1), .filter_g_t1(filter_b_p0_t1), .filter_b_t1(filter_b_p0_t1),
.filter_r_t2(filter_r_p0_t2), .filter_g_t2(filter_b_p0_t2), .filter_b_t2(filter_b_p0_t2),
.filter_r_t3(filter_r_p0_t3), .filter_g_t3(filter_b_p0_t3), .filter_b_t3(filter_b_p0_t3),
.filter_r_t4(filter_r_p0_t4), .filter_g_t4(filter_b_p0_t4), .filter_b_t4(filter_b_p0_t4),
.filter_r_t5(filter_r_p0_t5), .filter_g_t5(filter_b_p0_t5), .filter_b_t5(filter_b_p0_t5),
.filter_r_t6(filter_r_p0_t6), .filter_g_t6(filter_b_p0_t6), .filter_b_t6(filter_b_p0_t6),
.filter_r_t7(filter_r_p0_t7), .filter_g_t7(filter_b_p0_t7), .filter_b_t7(filter_b_p0_t7),
.filter_r_t8(filter_r_p0_t8), .filter_g_t8(filter_b_p0_t8), .filter_b_t8(filter_b_p0_t8),
.output_data_pipe(output_data_pipe_p0));
	
fir_filter_acc_output acc_p1( .clk(clk), .rst_n(rst_n), .mac_en(mac_en), .mac_clr(mac_clr), .output_en(output_en),
.filter_r_t0(filter_r_p1_t0), .filter_g_t0(filter_b_p1_t0), .filter_b_t0(filter_b_p1_t0),
.filter_r_t1(filter_r_p1_t1), .filter_g_t1(filter_b_p1_t1), .filter_b_t1(filter_b_p1_t1),
.filter_r_t2(filter_r_p1_t2), .filter_g_t2(filter_b_p1_t2), .filter_b_t2(filter_b_p1_t2),
.filter_r_t3(filter_r_p1_t3), .filter_g_t3(filter_b_p1_t3), .filter_b_t3(filter_b_p1_t3),
.filter_r_t4(filter_r_p1_t4), .filter_g_t4(filter_b_p1_t4), .filter_b_t4(filter_b_p1_t4),
.filter_r_t5(filter_r_p1_t5), .filter_g_t5(filter_b_p1_t5), .filter_b_t5(filter_b_p1_t5),
.filter_r_t6(filter_r_p1_t6), .filter_g_t6(filter_b_p1_t6), .filter_b_t6(filter_b_p1_t6),
.filter_r_t7(filter_r_p1_t7), .filter_g_t7(filter_b_p1_t7), .filter_b_t7(filter_b_p1_t7),
.filter_r_t8(filter_r_p1_t8), .filter_g_t8(filter_b_p1_t8), .filter_b_t8(filter_b_p1_t8),
.output_data_pipe(output_data_pipe_p1));
	
fir_filter_acc_output acc_p2( .clk(clk), .rst_n(rst_n), .mac_en(mac_en), .mac_clr(mac_clr), .output_en(output_en),
.filter_r_t0(filter_r_p2_t0), .filter_g_t0(filter_b_p2_t0), .filter_b_t0(filter_b_p2_t0),
.filter_r_t1(filter_r_p2_t1), .filter_g_t1(filter_b_p2_t1), .filter_b_t1(filter_b_p2_t1),
.filter_r_t2(filter_r_p2_t2), .filter_g_t2(filter_b_p2_t2), .filter_b_t2(filter_b_p2_t2),
.filter_r_t3(filter_r_p2_t3), .filter_g_t3(filter_b_p2_t3), .filter_b_t3(filter_b_p2_t3),
.filter_r_t4(filter_r_p2_t4), .filter_g_t4(filter_b_p2_t4), .filter_b_t4(filter_b_p2_t4),
.filter_r_t5(filter_r_p2_t5), .filter_g_t5(filter_b_p2_t5), .filter_b_t5(filter_b_p2_t5),
.filter_r_t6(filter_r_p2_t6), .filter_g_t6(filter_b_p2_t6), .filter_b_t6(filter_b_p2_t6),
.filter_r_t7(filter_r_p2_t7), .filter_g_t7(filter_b_p2_t7), .filter_b_t7(filter_b_p2_t7),
.filter_r_t8(filter_r_p2_t8), .filter_g_t8(filter_b_p2_t8), .filter_b_t8(filter_b_p2_t8),
.output_data_pipe(output_data_pipe_p2));
   //------------------------------- instance acc module ------------------------------//


   //------------------------------- Top module ------------------------------//
	always@(posedge clk)
	begin
	if(cnt==1)
	tc_data_t0 = tc_data;
	else if(cnt==2)
	tc_data_t1 = tc_data;
	else if(cnt==3)
	tc_data_t2 = tc_data;
	else if(cnt==4)
	tc_data_t3 = tc_data;
	else if(cnt==5)
	tc_data_t4 = tc_data;
	else if(cnt==6)
	tc_data_t5 = tc_data;
	else if(cnt==7)
	tc_data_t6 = tc_data;
	else if(cnt==8)
	tc_data_t7 = tc_data;
	else if(cnt==9)
	tc_data_t8 = tc_data;
	end 
	// cnt modulo
	always@(*) 
	begin 
	cnt_mod = cnt % 3 ;
	cnt_output_mod = cnt_output % 3 ;
	end
	// count clk
	always@(posedge clk) 
	begin
		if (cnt_clr)
		begin
		cnt = 0;
		end
		else
		begin
		cnt = cnt + 1;
		end
	end
	
	always @(posedge clk)
	begin
	if (cnt_output==1925)
	cnt_output = 6;
	else
	cnt_output = cnt_output + 1;
	end
	//FSM
	always@(posedge clk or negedge rst_n)
	begin
  	  if(!rst_n) begin
        present_state <= 2'b00; // ?? ??

    end
    else begin
        present_state <= next_state;
    end
	end
	// FSM STATE LOGIC
	always @(*)
	begin
		case ( present_state )
		IDLE : if(tc_set==1&&valid_dmac==1)
				next_state = TC_SET;
				else
				next_state = IDLE;
		TC_SET : if( tc_set == 0 && valid_dmac == 1)
				next_state = COL_0;
				 else if ( tc_set == 1 && valid_dmac == 1)
				next_state = TC_SET;
				 else
				next_state = TC_SET;
		COL_0 : if ( tc_set == 0 && valid_dmac == 1)
				next_state = COL_1;
				else
				next_state = COL_0;
    		COL_1 : if ( tc_set == 0 && valid_dmac == 1)
    	        		next_state = CALC_0;
    	     	   		else
    		       		next_state = COL_1;
    		CALC_0 : if ( tc_set == 0 && valid_dmac == 1)
    	   	     		next_state = CALC_1;
    	   	     		else 
    	        		next_state = CALC_0;
    		CALC_1 : if ( tc_set == 0 && valid_dmac == 1)
    	   	     		next_state = CALC;
    	   	     		else 
    	        		next_state = CALC_1 ;
    		CALC : if ( valid_dmac == 1 && cnt == 1919 )
    	   	     		next_state = COL_0;
    	   	     		else 
    	        		next_state = CALC;
		endcase
	end
	//FSM OUTPUT
	always @ (*)
	begin
				case ( present_state )
		IDLE : if(tc_set==1&&valid_dmac==1)
			begin
			tc_write = 1; tc_en =1; mac_en = 0; mac_clr = 1; output_en = 0; valid_core = 0; cnt_clr =1;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 1; output_en = 0; valid_core = 0; cnt_clr =1;
			end
		TC_SET : if(tc_set==0&&valid_dmac==1)
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 0; output_en = 1; valid_core = 1; cnt_clr =0;
			end
			else if ( tc_set == 1 && valid_dmac == 1 )
			begin
			tc_write = 1; tc_en =1; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end
			else if (tc_set == 0 && valid_dmac == 0)
			begin
			tc_write = 0; tc_en =1; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =1; cnt_output = 2;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 0; output_en = 1; valid_core = 1; cnt_clr =0;
			end
		COL_0 : if (tc_set == 0 && valid_dmac == 1)
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 1; output_en = 1; valid_core = 1; cnt_clr =0;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end
		COL_1 : if ( tc_set == 0 && valid_dmac == 1)
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 0; output_en = 1; valid_core = 1; cnt_clr =0;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end
		CALC_0 : if ( tc_set == 0 && valid_dmac == 1)
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 0; output_en = 1; valid_core = 1; cnt_clr =0;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end
		CALC_1 : if ( tc_set == 0 && valid_dmac == 1)
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end

		CALC :  if ( valid_dmac == 1 && cnt == 1919 )
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 0; output_en = 1; valid_core = 1; cnt_clr =1;
			end
			else if ( valid_dmac == 1 && tc_set == 0)
			begin
			tc_write = 0; tc_en =1; mac_en = 1; mac_clr = 0; output_en = 1; valid_core = 1; cnt_clr =0;
			end
			else
			begin
			tc_write = 0; tc_en =0; mac_en = 0; mac_clr = 0; output_en = 0; valid_core = 0; cnt_clr =0;
			end
		endcase
		
	end
    //output FSM
/*
	always @(negedge clk)
	if (cnt == 3 || cnt == 4)
	begin
	output_en = 0;
	valid_core = 0;
	end
	else
	ouput_en = 1
*/
	// output_serial_out
	always@(negedge clk)//tb ??? input count timing?? output timing? ??? ??
	begin
		if (valid_core)
		begin
			case (cnt_output_mod)
			2'b00 : output_data <= output_data_pipe_p0;
			2'b01 : output_data <= output_data_pipe_p1;
			2'b10 : output_data <= output_data_pipe_p2; 
			default output_data <= 1'bz;
			endcase
		end
		else output_data <= output_data;
	end
	
endmodule