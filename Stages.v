`timescale 1ns/1ns

module Registers (
	input clk,
	input[2:0] read1,
	input[2:0] read2,
	input[15:0] write_data,
	input[2:0] write_address,
	output[15:0] data1,
	output[15:0] data2,
	input register_write
);
	//TODO
	assign data1 = 16'h4444;
	assign data2 = 16'h2;
endmodule

module Control (
	input[3:0] opcode,
	output[8:0] control_output
	);

	reg[8:0] test;

	assign control_output[8] = 0;
	assign control_output[7:5] = (opcode < 7) ? opcode[2:0] : 3'b000; // ADD as default, 3'b111 is nto used

	assign control_output[4] = 0;
	assign control_output[3] = 0;
	assign control_output[2] = 0;

	assign control_output[1] = 0;
	assign control_output[0] = 0;

	//assign control_output = test;

	// initial begin
	// 	test <= 9'b111100011; // hex 1E3
	// 	#4;
	// 	test = 9'b000011100; // hex 01C
	// end

	//TODO
endmodule

module STAGE_IF (
	input clk,
	input[15:0] if_in,
	output[1:0][15:0] if_out,
	output[11:0] Instruction_addressbus,
	input[15:0] Instruction_databus,
	input[15:0] PC_from,
	output[15:0] PC_to,
	input PCSrc // TODO handle PCSrc for both "Simple Jump" and "BNE Jump"
	);


	assign PC_to = PCSrc ? if_in : PC_from + 2;

	assign Instruction_addressbus = PC_from;
	assign if_out[0] = PC_from;
	assign if_out[1] = Instruction_databus;
	
endmodule

module STAGE_ID (
	input clk,
	input[1:0][15:0] id_in,
	output[5:0][15:0] id_out,
	input[15:0] wb_out_data,
	input[2:0] wb_out_reg_address,
	output[8:0] control_output,
	input register_write
	);

// Pass PC
	assign id_out[0] = id_in[0];

// Connect Registers-ID
	wire[15:0] reg_data1, reg_data2;
	wire[2:0] reg_read1, reg_read2;

	//TODO slayttaki örnek 32 bit, bizim yapmamız gereken 16-bit, son bir defa doğru olduğuna kontrol et
	assign reg_read1 = id_in[1][8:6];
	assign reg_read2 = id_in[1][5:3];
	assign id_out[1] = reg_data1;
	assign id_out[2] = reg_data2;

	Registers register(clk, reg_read1, reg_read2, wb_out_data, wb_out_reg_address, reg_data1, reg_data2, register_write);

// Pass Other Instructions

	assign id_out[3] =
		(id_in[1][15:12] < 4) ? id_in[1][5:0]
		: (id_in[1][15:12] > 13) ? id_in[1][11:0]
		: id_in[1][8:0];
	assign id_out[4] =id_in[1][15:0]; //TODO Handle ALU Control Input later
	assign id_out[5] =id_in[1][11:9];

// Control Output
	// WB [1:0]
		// 1 bit RegWrite
		// 1 bit MemToReg
	// MEM [4:2]
		// 1 bit SimpleJump
		// 1 bit BNE Jump
		// 1 bit MemWrite, also works as MemRead
	// EX [8:5]
		// 3 bit ALU Op
		// 1 bit ALU Src

	Control control(id_in[1][15:12], control_output);

	
	//Dummy wire to see reg_write on GTKWave
	wire[2:0] reg_writeTo;
	assign reg_writeTo = id_in[1][11:9];
endmodule

module STAGE_EX (
	input clk,
	input[5:0][15:0] ex_in,
	output[4:0][15:0] ex_out,
	input[3:0] ex_control_input
	);
	assign ex_out[0] = ex_in[0] + ex_in[3]; //TODO IMMEDIATE???

	wire[15:0] ALU_input2 = ex_control_input[3] ? ex_in[3] : ex_in[2]; //TODO IMMEDIATE???
	wire[15:0] ALU_zero, ALU_result;

	ALU alu(ex_in[1], ALU_input2, ALU_zero, ALU_result, ex_control_input[2:0]);

	assign ex_out[1] = ALU_zero;
	assign ex_out[2] = 16'hFFFD; //ALU_result; TEMPORARY HARD CODE
	assign ex_out[3] = ex_in[2];
	assign ex_out[4] = ex_in[5];
endmodule

module STAGE_MEM (
	input clk,
	input[4:0][15:0] mem_in,
	output[2:0][15:0] mem_out,
	output[11:0] Memory_addressbus,
	inout[15:0] Memory_databus,
	output Memory_writemode,
	input[2:0] mem_control_input
	//TODO Add output PCSrc
	//TODO Add input doubleRead Control path
	);

	assign Memory_addressbus = mem_in[2];
	assign Memory_databus = mem_control_input[2] ? mem_in[2] : 'bz;

	assign mem_out[0] = Memory_databus;
	assign mem_out[1] = mem_in[2];
	assign mem_out[2] = mem_in[4];
	//TODO Memory needs 1 cycle to read, might be a problem
endmodule

module STAGE_WB (
	input clk,
	input[2:0][15:0] wb_in,
	output[15:0] wb_out_data,
	output[2:0] wb_out_reg_address,
	input[1:0] wb_control_input
	);

	assign wb_out_reg_address = wb_in[2];

	assign wb_out_data = wb_control_input[1] ? wb_in[0] : wb_in[1];
endmodule