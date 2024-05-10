`include "ahb_macro_h.v"
module SRAM(
            HCLK, HRESETn,
            //Inputs of AHB Slave Interface
            HSEL, HADDR, HWRITE, HTRANS, HSIZE, HBURST, HWDATA, HREADY,
            //outputs of AHB Slave Interface
            s5_HREADY, s5_HRESP, s5_HRDATA
            );

input wire HCLK;
input wire HRESETn;
input wire HSEL;
input wire HREADY;
input wire [31:0] HADDR;
input wire [2:0] HSIZE;
input wire [1:0] HTRANS;
input wire HWRITE;
input wire [2:0] HBURST;
input wire [31:0] HWDATA;

output reg [31:0] s5_HRDATA;
output reg s5_HREADY;
output reg [1:0] s5_HRESP;

parameter MEM_DEPTH = 32'h3000;
parameter MEM_WIDTH = 32;
 
reg [MEM_WIDTH-1:0] memory [0:MEM_DEPTH-1];
reg [MEM_WIDTH-1:0] read_buffer;
reg read_enable;
reg write_enable;
reg [31:0] q_HADDR;


//ADDR flip-flop
always @(posedge HCLK or negedge HRESETn) begin
	if(!HRESETn) begin
		q_HADDR <=0;
	end
	else begin
		q_HADDR <= HADDR;
	end
end

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        // 리셋 로직
        s5_HREADY <= 1'b1;
        s5_HRESP <= 2'b00; // OKAY
        read_enable <= 1'b0;
        write_enable <= 1'b0;
    end else begin
        s5_HREADY <= 1'b1; // 트랜잭션이 준비됨
        if ((HSEL) && (HTRANS[1]==1) && (HREADY)) begin
            if ((HWRITE) && ((HADDR[15:0]) < (MEM_DEPTH * 4))) begin
                write_enable <= 1'b1; // 쓰기 활성화
                // 쓰기 응답은 다음 posedge HCLK에서 처리됨
            end else if ((!HWRITE) && ((HADDR[15:0]) < (MEM_DEPTH * 4))) begin
                read_enable <= 1'b1; // 읽기 활성화
				read_buffer <= memory[HADDR[15:0]];
                // 읽기 데이터는 다음 posedge HCLK에서 처리됨
            end else begin
                s5_HRESP <= 2'b01; // 주소가 범위 밖임
				s5_HREADY <=1'b0;
            end
        end else begin
            write_enable <= 1'b0; // 쓰기 비활성화
            read_enable <= 1'b0;  // 읽기 비활성화
        end
    end
end

// 쓰기 동작은 클록의 상승 에지에서 동기적으로 처리
always @(*) begin
    if (write_enable) begin
        memory[q_HADDR[15:0]] <= HWDATA;
        s5_HRESP <= 2'b00; // OKAY
    end
	else begin
		s5_HRDATA <=s5_HRDATA;
		s5_HREADY <=s5_HREADY;
		s5_HRESP <=s5_HRESP;
	end
end

// 읽기 동작 지연 구현
always @(*) begin
    if (read_enable) begin
        s5_HRDATA <= read_buffer;
        s5_HRESP <= 2'b00; // OKAY
    end
	else begin
		s5_HRDATA <=s5_HRDATA;
		s5_HREADY <=s5_HREADY;
		s5_HRESP <=s5_HRESP;
	end
end

endmodule