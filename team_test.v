`timescale 1ns/100ps
module fir_filter_CNN_tb;

parameter ALL = 102400;
//parameter ALL_O = 102400;

parameter COL =  320, ROW = 320;
//Clock 
reg clk;
reg rst_n;
reg tc_set;
reg valid_dmac;
reg [23:0] input_data0, input_data1, input_data2;
reg r;
//Output
wire valid_core;
wire [23:0] output_data;
//register
reg signed [7:0] tc [8:0];
reg [23:0] memory0[ALL-1:0];
reg [23:0] memory1[ALL-1:0];
reg [23:0] memory2[ALL-1:0];
reg [23:0] memory_w [ALL-1:0];
reg [23:0] read_data;
reg [12:0] Row_index, Col_index;
reg signed [23:0] tc_data;
reg [7:0] gray;
reg [23:0] gray_data;

parameter FILE_t = "C:/Users/82104/Desktop/SoC/team/AHB/image/filter_tap.dat";
parameter FILE_d = "C:/Users/82104/Desktop/SoC/team/AHB/image/fir_src_img_320x320.rgb";
parameter FILE_o = "fir_output.rgb";
//integer
integer dest_fd;
integer desto_fd;
integer i;
integer t,k;


fir_filter_CNN fir_filter_CNN_tb(.clk(clk),.rst_n(rst_n), .tc_data(tc_data), .input_data0(input_data0), .input_data1(input_data1), .input_data2(input_data2), 
	  .valid_dmac(valid_dmac), .tc_set(tc_set), .output_data(output_data), .valid_core(valid_core));

//DESIGN

always #10 clk = ~clk;

initial
begin
   valid_dmac = 0;
   tc_set = 0;
   rst_n = 0;
   clk=0;
   r=1'b0;
   #10 rst_n = 1;
   #10 tc_set = 1;
	valid_dmac=1 ;
	#20 ;
    $readmemh(FILE_t, tc);

    dest_fd = $fopen(FILE_d, "rb");
    for (t=0; t<ALL; t=t+1)
    begin
        r=$fread(read_data, dest_fd);
        if (r<0) $display("Data read error\n");
        else begin
            memory0[t] = read_data;
            memory1[t] = read_data;
            memory2[t] = read_data;
        end
    end
    $fclose(dest_fd);
    
   
    valid_dmac = 1;
    tc_set = 1;

    for(i=0;i<=8;i=i+1) 

  	  begin
		tc_data = { {3{tc[i]}} };
		#20;
  	  end

	tc_set=0;
	valid_dmac =0;
    input_data0 = 1'b0;
	input_data1 = 1'b0;
	input_data2 = 1'b0;
	# 40;
	valid_dmac=1;

    for (Row_index=0; Row_index <= ROW; Row_index = Row_index + 1)
    begin
        for (Col_index = 0; Col_index <= COL-1 ; Col_index = Col_index + 1)
        begin
	     
             input_data0[23:0] <= memory0[Row_index*ROW + Col_index];
			 input_data0[31:24] <= 0;
             input_data1[23:0] <= memory1[(Row_index+1)*ROW + Col_index];
			 input_data1[31:24] <= 0;
             input_data2[23:0] <= memory2[(Row_index+2)*ROW + Col_index];
			 input_data2[31:24] <= 0;
	     #20;
        end
    end
#10;

end

initial desto_fd = $fopen(FILE_o, "wb");

always @ (posedge clk)
begin
if ( (Row_index == 318) && (Col_index ==3))
        begin $fclose(desto_fd); $stop; end
else
begin
if ( Col_index == 5)
	for (k=0 ; k <= 317; k = k+1)
	begin
	gray = (output_data[23:16] + output_data[15:8] + output_data[7:0])/3;
	gray_data[23:16] = gray;
	gray_data[15:8] = gray;
	gray_data[7:0] = gray;
	$fwrite(desto_fd, "%c%c%c" , gray_data[23:16], gray_data[15:8], gray_data[7:0]);
	#20;
	end
end
end



endmodule