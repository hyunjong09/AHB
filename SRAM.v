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

parameter MEM_DEPTH = 32'h4096;
parameter MEM_WIDTH = 8;
 
reg [MEM_WIDTH-1:0] memory [0:MEM_DEPTH-1];
reg [MEM_WIDTH*4-1:0] read_buffer;
reg read_enable;
reg write_enable;
reg [31:0] q_HADDR;


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
    end 
	else begin
        s5_HREADY <= 1'b1; // 트랜잭션이 준비됨
        if ((HSEL) && (HTRANS[1]==1) && (HREADY)) begin
            if ((HWRITE) && ((HADDR[15:0]) < (MEM_DEPTH * 4))) begin
                write_enable <= 1'b1; // 쓰기 활성화
                // 쓰기 응답은 다음 posedge HCLK에서 처리됨
            end
			else if ((!HWRITE) && ((HADDR[15:0]) < (MEM_DEPTH * 4))) begin
				case(HSIZE)
				3'b000: begin//byte
					read_enable <=1'b1;//읽기 활성화
					read_buffer <= {24'b0 , memory[HADDR[15:0]]};
				end
				3'b001: begin//Half Word
					read_enable <=1'b1;//읽기 활성화
					read_buffer <= {16'b0, memory[HADDR[15:0]+1], memory[HADDR[15:0]]};
				end
				3'b010: begin//Word
					read_enable <= 1'b1; // 읽기 활성화
					read_buffer[7:0] <= memory[HADDR[15:0]];
					read_buffer[15:8] <= memory[HADDR[15:0]+1];
					read_buffer[23:16] <= memory[HADDR[15:0]+2];
					read_buffer[31:24] <= memory[HADDR[15:0]+3];
				end
				default: begin
					read_enable <= 1'b1; // 읽기 활성화
					read_buffer[7:0] <= memory[HADDR[15:0]];
					read_buffer[15:8] <= memory[HADDR[15:0]+1];
					read_buffer[23:16] <= memory[HADDR[15:0]+2];
					read_buffer[31:24] <= memory[HADDR[15:0]+3];
					// 읽기 데이터는 다음 posedge HCLK에서 처리됨
				end
				endcase
            end 
			else begin
                s5_HRESP <= 2'b01; // 주소가 범위 밖임
				s5_HREADY <=1'b0;
            end
        end
		else begin
            write_enable <= 1'b0; // 쓰기 비활성화
            read_enable <= 1'b0;  // 읽기 비활성화
        end
    end
end

// 쓰기 동작은 클록의 상승 에지에서 동기적으로 처리
always @(posedge HCLK) begin
    if (write_enable) begin
		case(HSIZE)
		3'b000: begin
			memory[q_HADDR[15:0]] <=HWDATA[7:0];
			s5_HRESP <= 2'b00; // OKAY
		end
		3'b001: begin
			memory[q_HADDR[15:0]] <= HWDATA[7:0];
			memory[q_HADDR[15:0]+1] <= HWDATA[15:8];
			s5_HRESP <= 2'b00; // OKAY
		end
		3'b010: begin
			memory[q_HADDR[15:0]] <= HWDATA[7:0];
			memory[q_HADDR[15:0]+1] <= HWDATA[15:8];
			memory[q_HADDR[15:0]+2] <= HWDATA[23:16];
			memory[q_HADDR[15:0]+3] <= HWDATA[31:24];
			s5_HRESP <= 2'b00; // OKAY
		end
		default: begin
			memory[q_HADDR[15:0]] <= HWDATA[7:0];
			memory[q_HADDR[15:0]+1] <= HWDATA[15:8];
			memory[q_HADDR[15:0]+2] <= HWDATA[23:16];
			memory[q_HADDR[15:0]+3] <= HWDATA[31:24];
			s5_HRESP <= 2'b00; // OKAY
			//write_enable signal이 sequencial로 나오기 때문에 address mapping을 위하여 q_HADDR필요
			//sequencial logic으로 작성 시 write > read 바로 동작 불가
			//저장되는게 실제 입력 후 1cycle 뒤임 즉, 마지막 저장 과정 중 read가 시작되면 해당 부분 접근 불가
			//어차피 같은 memory에서 W<>R 시 IDLE state가 있기에 크게 신경쓰지 않아도 될듯
		end
		endcase
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