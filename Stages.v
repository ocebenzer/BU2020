`timescale 1ns/1ns

module Registers (
	input clk,
	input[4:0] read1,
	input[4:0] read2,
	input[4:0] write1,
	input[15:0] write_data,
	output[15:0] data1,
	output[15:0] data2
);
	//TODO
endmodule

module STAGE_IF (input clk, input[15:0] if_in, output[1:0][15:0] if_out);
	
endmodule

module STAGE_ID (input clk, input[1:0][15:0] id_in, output[3:0][15:0] id_out, input[15:0] wb_out);

	wire[15:0] reg_writedata, reg_data1, reg_data2;
	wire[4:0] reg_read1, reg_read2, reg_write1;

// Connect Registers-ID
	//TODO slayttaki örnek 32 bit, bizim yapmamız gereken 16-bit
	assign reg_read1 = id_in[1][5:3];
	assign reg_read2 = id_in[1][8:6];
	assign reg_write1 = id_in[1][11:9];
	assign reg_writedata = wb_out;

	Registers register(clk, reg_read1, reg_read2, reg_write1, reg_writedata, reg_data1, reg_data2);
endmodule

module STAGE_EX (input clk, input[3:0][15:0] ex_in, output[3:0][15:0] ex_out);
	
endmodule

module STAGE_MEM (input clk, input[3:0][15:0] mem_in, output[1:0][15:0] mem_out);
	
endmodule

module STAGE_WB (input clk, input[1:0][15:0] wb_in, output[15:0] wb_out);
	
endmodule