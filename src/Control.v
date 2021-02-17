`timescale 1ns/1ns

module Control (
	input[3:0] opcode,
	output[11:0] control_output
	);

// Control Output Guide
	// EX output[11:7]
		// [4:3] -> 1 bit ALU Src
		// [2:0] -> 3 bit ALU Op
	// MEM output[6:2]
		// [4] -> doubleRead
		// [3] -> doubleWrite
		// [2] -> 1 bit MemWrite, also works as MemRead
		// [1] -> 1 bit BNE Jump
		// [0] -> 1 bit Simple Jump
	// WB output[1:0]
		// [1] -> 1 bit MemToReg
		// [0] -> 1 bit RegWrite


	assign control_output[11:10] =
		(opcode == 3 || opcode == 6 || opcode == 12) ? 2'b01 :
		(opcode > 6 && opcode < 11) ? 2'b10 : 
		(opcode == 11) ? 2'b11 : 2'b00;
	assign control_output[9:7] = (opcode < 7) ? opcode[2:0] :
									(opcode == 11 || opcode == 12) ? 3'b111 :
									(opcode == 13)	? 3'b010 : 3'b000;

	assign control_output[6] = opcode == 4'h8;
	assign control_output[5] = opcode == 4'hA;
	assign control_output[4] = (opcode >= 9 && opcode <= 10);
	assign control_output[3] = (opcode == 4'he);
	assign control_output[2] = (opcode == 4'hf);

	assign control_output[1] = (opcode >= 7 && opcode <= 10);
	assign control_output[0] = (opcode >= 0 && opcode <= 8) || (opcode == 11 || opcode == 12);
endmodule