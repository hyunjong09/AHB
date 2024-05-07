`include "ahb_macro_h.v"
module DAMC_SLAVE (
    // Inputs
    s_HCLK,
    s_HRESETn,
    s_HTRANS,
    s_HSEL,
    s_HREADY,
    s_HWRITE,
    s_HSIZE,
    s_HBURST,
    DMAC_HADDR_REG,
	DMAC_Configuration,
	DMAC_C0_SrcAddr,
	DMAC_C0_DestAddr,
	DMAC_C0_Control,
	DMAC_C0_Configuration,
	DMACINTR_pend,
	DMACINTR_mask,
   
    // Outputs
    out_HRDATA,
    out_HRESP,
    out_HREADY,

    // Outputs to register bank
    write_out_reg,
    load_ahb_addr
);

//slave input
input s_HCLK;
input s_HRESETn;
input [1:0] s_HTRANS;
input s_HSEL;
input s_HREADY;
input s_HWRITE;
input [2:0] s_HSIZE;
input [3:0] s_HBURST;
input [11:0] DMAC_HADDR_REG;

//register bank에서 out_HRDATA로 값을 넣어야 되니까 input 필요
input [31:0] DMAC_Configuration;
input [31:0] DMAC_C0_SrcAddr;
input [31:0] DMAC_C0_DestAddr;
input [31:0] DMAC_C0_Control;
input [31:0] DMAC_C0_Configuration;
input DMACINTR_pend;
input DMACINTR_mask;

//slave에서 버스로 나가는 output
output reg [31:0] out_HRDATA;
output reg [1:0] out_HRESP;
output reg out_HREADY;

//slave에서 register bank로 나가는 output
output reg write_out_reg;
output reg load_ahb_addr;

//FSM 위한 내부 register
reg [1:0] sns, sps;

//FSM 위한 parameter
parameter SDMAC_ADDR_S = 0;
parameter SDMAC_WRITE_S = 1;
parameter SDMAC_READ_S = 2;
parameter SDMAC_ERROR_S = 3;

//instance




//slave fsm
always @(posedge s_HCLK or negedge s_HRESETn)
begin
   if(!s_HRESETn) sps <= SDMAC_ADDR_S; 
   else sps <= sns;
   
end

always @(*) // state block
begin
	case(sps)
		SDMAC_ADDR_S : begin
			if(s_HREADY == 0) // ??: s_HREADY? 0?? ?? ?? ??
				sns <= SDMAC_ADDR_S;
			else if(s_HREADY == 1 && s_HSEL == 1 && s_HTRANS[1] == 1 && s_HWRITE == 0) 
				sns <= SDMAC_READ_S;
			else if(s_HREADY == 1 && s_HSEL == 1 && s_HTRANS[1] == 1 && s_HWRITE == 1) 
				sns <= SDMAC_WRITE_S;
			else 
				sns <= SDMAC_ADDR_S;
		end
		SDMAC_WRITE_S : begin
			if(s_HREADY == 0) // ??: s_HREADY? 0?? ?? ?? ??
				sns <= SDMAC_WRITE_S;
			else if(s_HSEL == 1 && s_HTRANS[1] == 1 && s_HWRITE == 1) 
				sns <= SDMAC_WRITE_S;
			else if(s_HSEL == 1 && s_HTRANS[1] == 1 && s_HWRITE == 0) begin
				sns <= SDMAC_READ_S;
			end
			else sns <= SDMAC_ADDR_S;
			if(!((DMAC_HADDR_REG == 12'h030)||
				(DMAC_HADDR_REG == 12'h100)||
				(DMAC_HADDR_REG == 12'h104)||
				(DMAC_HADDR_REG == 12'h10C)||
				(DMAC_HADDR_REG == 12'h110))) begin
					sns <= SDMAC_ERROR_S;
			end
		end
		SDMAC_READ_S : begin
			if(s_HREADY == 0) // ??: s_HREADY? 0?? ?? ?? ??
				sns <= SDMAC_READ_S;
			else if(s_HSEL == 1 && s_HTRANS[1] == 1 && s_HWRITE == 0) sns <= SDMAC_READ_S;
			else if(s_HSEL == 1 && s_HTRANS[1] == 1 && s_HWRITE == 1) sns <= SDMAC_WRITE_S;
			else sns <= SDMAC_ADDR_S;
		end
		SDMAC_ERROR_S : begin
			if(s_HREADY == 0) // ??: s_HREADY? 0?? ?? ?? ??
				sns <= SDMAC_ERROR_S;
			else
				sns <= SDMAC_ADDR_S;
		end
		default : sns <= SDMAC_ADDR_S;
	endcase
end


always @(*) //output block
begin  
	case(sps)
		SDMAC_ADDR_S : begin
			if(sns!=SDMAC_ADDR_S) begin //?? ????? READ?? WRITE ??
				out_HRESP <= `OKAY;
				out_HREADY <= 1'b1;
				out_HRDATA <= 32'b0; 
				load_ahb_addr <= 1'b1; //DMAC_HADDR_REG = HADDR[6:5]
				write_out_reg <= 1'b0;
			end
			else begin //?? ????? ADDR ??
				if(s_HREADY ==1'b1) begin
					out_HRESP <= `OKAY;
					out_HREADY <= 1'b1;
					out_HRDATA <= 32'b0; 
					load_ahb_addr <= 1'b0;
					write_out_reg <= 1'b0;
				end
				else begin
					out_HRESP <= `OKAY;
					out_HREADY <= 1'b0;
					out_HRDATA <= 32'b0; 
					load_ahb_addr <= 1'b0;
					write_out_reg <= 1'b0;
				end
			end
		end
		SDMAC_WRITE_S : begin
			if(sns==SDMAC_ADDR_S) begin
				out_HRESP <= `OKAY;
				out_HREADY <= 1'b1;
				out_HRDATA <= 32'b0; 
				load_ahb_addr <= 1'b0;   
				if((DMAC_HADDR_REG == 12'h030)||
					(DMAC_HADDR_REG == 12'h100)||
					(DMAC_HADDR_REG == 12'h104)||
					(DMAC_HADDR_REG == 12'h10C)||
					(DMAC_HADDR_REG == 12'h110)) begin
						write_out_reg<= 1'b1;
				end 
				else begin
					write_out_reg <=1'b0;
				end
			end
			else if(sns ==SDMAC_ERROR_S) begin
				out_HRESP <= `ERROR;
				out_HREADY <= 1'b0;
				out_HRDATA <= 32'b0;
				load_ahb_addr <= 1'b0;
				write_out_reg <= 1'b0;
			end
			else if(sns ==SDMAC_READ_S) begin
				out_HRESP <= `OKAY;
				out_HREADY <= 1'b1;
				out_HRDATA <= 32'b0; 
				load_ahb_addr <= 1'b1;
				if((DMAC_HADDR_REG == 12'h030)||
					(DMAC_HADDR_REG == 12'h100)||
					(DMAC_HADDR_REG == 12'h104)||
					(DMAC_HADDR_REG == 12'h10C)||
					(DMAC_HADDR_REG == 12'h110)) begin
						write_out_reg<= 1'b1;
				end 
				else begin
					write_out_reg <=1'b0;
				end
			end
			else begin
				if(s_HREADY) begin
					out_HRESP <= `OKAY;
					out_HREADY <= 1'b1;
					out_HRDATA <= 32'b0; 
					load_ahb_addr <= 1'b1;
					if((DMAC_HADDR_REG == 12'h030)||
						(DMAC_HADDR_REG == 12'h100)||
						(DMAC_HADDR_REG == 12'h104)||
						(DMAC_HADDR_REG == 12'h10C)||
						(DMAC_HADDR_REG == 12'h110)) begin
							write_out_reg<= 1'b1;
					end 
					else begin
						write_out_reg <=1'b0;
					end
				end
				else begin
					out_HRESP <= `OKAY;
					out_HREADY <= 1'b0;
					out_HRDATA <= 32'b0; 
					load_ahb_addr <= 1'b0;
					write_out_reg <=1'b0;
				end
			end
		end
		SDMAC_READ_S : begin
         if(sns == SDMAC_ADDR_S) begin //read -> addr
            out_HRESP <= `OKAY;
            out_HREADY <= 1'b1;
            load_ahb_addr <= 1'b0;
            write_out_reg <= 1'b0;
            case(DMAC_HADDR_REG)
               12'h030 : out_HRDATA <= {31'b0,DMAC_Configuration};
               12'h100 : out_HRDATA <= DMAC_C0_SrcAddr;
               12'h104 : out_HRDATA <= DMAC_C0_DestAddr;
               12'h10C : out_HRDATA <= {17'b0, DMAC_C0_Control[14:0]};
               12'h110 : out_HRDATA <= {29'b0, DMACINTR_pend, DMACINTR_mask, DMAC_C0_Configuration};
               default : out_HRDATA <= out_HRDATA;
            endcase
         end
         else if (sns == SDMAC_WRITE_S) begin //read -> write
            out_HRESP <= `OKAY;
            out_HREADY <= 1'b1;
            load_ahb_addr <= 1'b1;
            write_out_reg <= 1'b0;
            case(DMAC_HADDR_REG)
               12'h030 : out_HRDATA <= {31'b0,DMAC_Configuration};
               12'h100 : out_HRDATA <= DMAC_C0_SrcAddr;
               12'h104 : out_HRDATA <= DMAC_C0_DestAddr;
               12'h10C : out_HRDATA <= {17'b0, DMAC_C0_Control[14:0]};
               12'h110 : out_HRDATA <= {29'b0, DMACINTR_pend, DMACINTR_mask, DMAC_C0_Configuration};
               default : out_HRDATA <= out_HRDATA;
            endcase
         end
         else begin // read -> read
            if(s_HREADY) begin
            out_HRESP <= `OKAY;
            out_HREADY <= 1'b1;
            load_ahb_addr <= 1'b1;
            write_out_reg <= 1'b0;
            case(DMAC_HADDR_REG)
               12'h030 : out_HRDATA <= {31'b0,DMAC_Configuration};
               12'h100 : out_HRDATA <= DMAC_C0_SrcAddr;
               12'h104 : out_HRDATA <= DMAC_C0_DestAddr;
               12'h10C : out_HRDATA <= {17'b0, DMAC_C0_Control[14:0]};
               12'h110 : out_HRDATA <= {29'b0, DMACINTR_pend, DMACINTR_mask, DMAC_C0_Configuration};
               default : out_HRDATA <= out_HRDATA;
            endcase
            end
            else begin
               out_HRESP <= `OKAY;
               out_HREADY <= 1'b0;
               load_ahb_addr <= 1'b0;
               write_out_reg <= 1'b0;
               out_HRDATA <=out_HRDATA;
            end
          end
          
      end
      SDMAC_ERROR_S : begin
         out_HRESP <= `ERROR;
         out_HREADY <= 1'b0;
         out_HRDATA <= 32'b0;
         load_ahb_addr <= 1'b0;
         write_out_reg <= 1'b0;
      end
      default: begin
         out_HRESP <= `OKAY;
         out_HREADY <= 1'b1;
         out_HRDATA <= 32'b0;
         load_ahb_addr <= 1'b0;
         write_out_reg <= 1'b0;
      end
   endcase
end

endmodule