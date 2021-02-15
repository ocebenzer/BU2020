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
//Registers
	// registers[0] -> BA
	// registers[3:1] -> Address Registers
	// registers[7:4] -> Data Registers
	reg[7:0][15:0] registers = 0;

	// Handle register read
	assign data1 = registers[read1];
	assign data2 = registers[read2];

	// Handle register write
	always @(posedge clk) begin
		case (register_write)
			1'b1: registers[write_address] <= write_data;
		endcase
	end

	// Initial register values
	initial begin
		registers[0] <= 16'h0400; // BA starts from 0x0400
		registers[1] <= 16'h4444;
		registers[2] <= 16'h4443;
		registers[3] <= 16'h4000;
		registers[4] <= 16'h0000;
		registers[5] <= 16'h0000;
		registers[6] <= 16'hFFFD;
		registers[7] <= 16'h0000;
	end
endmodule

module Control (
	input[3:0] opcode,
	output[9:0] control_output
	);

// Control Output Guide
	// EX output[9:5]
		// [4:3] -> 1 bit ALU Src
		// [2:0] -> 3 bit ALU Op
	// MEM output[4:2]
		// [2] -> 1 bit MemWrite, also works as MemRead
		// [1] -> 1 bit BNE Jump
		// [0] -> 1 bit Simple Jump
	// WB output[1:0]
		// [1] -> 1 bit MemToReg
		// [0] -> 1 bit RegWrite


	assign control_output[9:8] =
		(opcode == 3 || opcode == 6 || opcode == 12) ? 2'b01 :
		(opcode > 6 && opcode < 11) ? 2'b10 : 
		(opcode == 11) ? 2'b11 : 2'b00;
	assign control_output[7:5] = (opcode < 7) ? opcode[2:0] :
									(opcode == 11 || opcode == 12) ? 3'b111 :
									(opcode == 13)	? 3'b010 : 3'b000;

	assign control_output[4] = (opcode >= 9 && opcode <= 10);
	assign control_output[3] = (opcode == 4'he);
	assign control_output[2] = (opcode == 4'hf);

	assign control_output[1] = (opcode >= 7 && opcode <= 10);
	assign control_output[0] = (opcode >= 0 && opcode <= 8) || (opcode == 11 || opcode == 12);
endmodule

module STAGE_IF (
	input clk,
	input[15:0] if_in,
	output[1:0][15:0] if_out,
	output[11:0] Instruction_addressbus,
	input[15:0] Instruction_databus,
	input[15:0] PC_from,
	output[15:0] PC_to,
	input PCSrc
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
	output[9:0] control_output,
	input register_write
	);

// Pass PC
	assign id_out[0] = (id_in[1][15:12] == 4'hf) ? 0 : id_in[0]; // if simple jump, we send 0 as the next PC

// Connect Registers-ID
	wire[15:0] reg_data1, reg_data2;
	wire[2:0] reg_read1, reg_read2;

	//TODO slayttaki örnek 32 bit, bizim yapmamız gereken 16-bit, son bir defa doğru olduğuna kontrol et
	assign reg_read1 = (id_in[1][15:12] == 4'h6) ? (id_in[1][11:9]):
						(id_in[1][15:12] > 4'h6 &&  id_in[1][15:12] < 4'hB) ? 0 /*BA Register*/ : (id_in[1][8:6]);
	assign reg_read2 = id_in[1][5:3];
	assign id_out[1] = reg_data1;
	assign id_out[2] = reg_data2;

	Registers register(clk, reg_read1, reg_read2, wb_out_data, wb_out_reg_address, reg_data1, reg_data2, register_write);

// Pass Other Instructions

	assign id_out[3] =
		(id_in[1][15:12] < 4) ? id_in[1][5:0]
		: (id_in[1][15:12] > 13) ? id_in[1][11:0]
		: id_in[1][8:0];
	assign id_out[4] =id_in[1][15:0]; //This is not used
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
	input[4:0] ex_control_input
	);

	wire signed [15:0] addition = ex_in[3];

	assign ex_out[0] = ex_in[0] + 2*addition;

	wire[15:0] ALU_input2 =
	(ex_control_input[4:3] == 2'b00) ? ex_in[2] :
	(ex_control_input[4:3] == 2'b10) ? ex_in[3] * 2 :
	(ex_control_input[4:3] == 2'b01) ? ex_in[3] : 0;
	wire[15:0] ALU_status, ALU_result;

	ALU alu(ex_in[1], ALU_input2, ALU_status, ALU_result, ex_control_input[2:0]);

	assign ex_out[1] = ALU_status;
	assign ex_out[2] = ALU_result;
	assign ex_out[3] = ex_in[2];
	assign ex_out[4] = ex_in[5];
endmodule

module STAGE_MEM (
	input clk,
	input[4:0][15:0] mem_in,
	output[2:0][15:0] mem_out,
	output[11:0] Memory_addressbus,
	input[15:0] Memory_databus,
	output[15:0] Memory_incoming_data_bus,
	output Memory_writemode,
	input[2:0] mem_control_input,
	input z_flag,
	output PCSrc
	//TODO Add input doubleRead Control path
	);

	assign PCSrc = (mem_control_input[0] == 1) ? 1
					: (mem_control_input[1] == 1) ? !z_flag : 0;

	assign Memory_addressbus = mem_in[2];
	assign Memory_incoming_data_bus = mem_in[2];

	assign Memory_writemode = mem_control_input[2];

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