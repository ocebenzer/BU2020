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

module STAGE_IF (
	input clk,
	input[15:0] if_in,
	output[1:0][15:0] if_out,
	output[11:0] Instruction_addressbus,
	input[15:0] Instruction_databus,
	input[15:0] PC_from,
	output[15:0] PC_to
	);

	reg tmp = 0;//TODO MUX

	assign PC_to = tmp ? if_in : PC_from + 2;

	assign Instruction_addressbus = PC_from;
	assign if_out[0] = PC_from;
	assign if_out[1] = Instruction_databus;
	
endmodule

module STAGE_ID (input clk, input[1:0][15:0] id_in, output[3:0][15:0] id_out, input[15:0] wb_out);

// Pass PC
	assign id_out[0] = id_in[0];

// Connect Registers-ID
	wire[15:0] reg_writedata, reg_data1, reg_data2;
	wire[4:0] reg_read1, reg_read2, reg_write1;

	//TODO slayttaki örnek 32 bit, bizim yapmamız gereken 16-bit, son bir defa doğru olduğuna kontrol et
	assign reg_read1 = id_in[1][5:3];
	assign reg_read2 = id_in[1][8:6];
	assign reg_write1 = id_in[1][11:9];
	assign id_out[1] = reg_data1;
	assign id_out[2] = reg_data2;
	assign id_out[3] = 0;//TODO Immediate_Generator
	assign reg_writedata = wb_out;

	Registers register(clk, reg_read1, reg_read2, reg_write1, reg_writedata, reg_data1, reg_data2);
endmodule

module STAGE_EX (input clk, input[3:0][15:0] ex_in, output[3:0][15:0] ex_out);
	assign ex_out[0] = ex_in[0] + ex_in[3]; //TODO IMMEDIATE???

	wire tmp = 0;//TODO MUX

	wire[15:0] ALU_input2 = tmp ? ex_in[3] : ex_in[2]; //TODO IMMEDIATE???
	wire[15:0] ALU_zero, ALU_result;

	ALU alu(ex_in[1], ALU_input2, ALU_zero, ALU_result);

	assign ex_out[1] = ALU_zero;
	assign ex_out[2] = 16'hFFFD;//ALU_result; TEMPORARY HARD CODE
	assign ex_out[3] = ex_in[2];
endmodule

module STAGE_MEM (
	input clk,
	input[3:0][15:0] mem_in,
	output[1:0][15:0] mem_out,
	output[11:0] Memory_addressbus,
	inout[15:0] Memory_databus,
	output Memory_writemode
	);
	
	assign Memory_writemode = 0;//TODO Controller

	assign Memory_addressbus = mem_in[2];
	assign Memory_databus = Memory_writemode ? mem_in[2] : 'bz;


	assign mem_out[0] = Memory_databus;
	assign mem_out[1] = mem_in[2];
endmodule

module STAGE_WB (input clk, input[1:0][15:0] wb_in, output[15:0] wb_out);
	wire tmp = 0;//TODO MUX

	assign wb_out = tmp ? wb_in[0] : wb_in[1];
endmodule