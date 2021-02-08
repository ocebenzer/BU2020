`timescale 1ns/1ns

module Memory(
	input clk,
	input[11:0] address_bus,
	inout[15:0] data_bus,
	input write_mode,
	input[11:0] Instruction_addressbus,
	output[15:0] Instruction_databus
	);

	// 4KB Memory, 4x1KB modules, first module is instruction module, rest 3 are data modules
	reg[511:0][15:0] data_instruction = 0;
	reg[511:0][15:0] data1 = 0;
	reg[511:0][15:0] data2 = 0;
	reg[511:0][15:0] data3 = 0;
	
	initial begin
	//Instruction Initialization

		//0000 010 011 100 XXX, 04E0h Add R010 R011 R100
		data_instruction[0] = 16'h04E0;
		//0001 010 011 000110, 14C6h Add R010 R011 memory(BA+"6")
		data_instruction[1] = 16'h14C6;
		//0010 010 011 100 XXX, 24E0h Sub R010 R011 R100
		data_instruction[2] = 16'h24E0;
		//0011 010 011 000110, 34C6h Addi R010 R011  "6"
		data_instruction[3] = 16'h34C6;
		//0100 010 011 100 XXX, 44E0h Mul R010 R011 R100
		data_instruction[4] = 16'h44E0;
		//0101 010 011 100 XXX, 54E0h And R010 R011 R100
		data_instruction[5] = 16'h54E0;
		//0110 010 000001001, 6409h Sll R010 "9"
		data_instruction[6] = 16'h6409;
		//0111 010 000001001, 7409h Lw R010 "9"
		data_instruction[7] = 16'h7409;
		//1000 010 000001001, 8409h Lwi R010 "9"
		data_instruction[8] = 16'h8409;
		//1001 010 000001001, 9409h Sw R010 "9"
		data_instruction[9] = 16'h9409;
		//1010 010 000001001, A409h Swi R010 "9"
		data_instruction[10] = 16'hA409;
		//1011 010 XXXXXXXXX, B400h CLR R010
		data_instruction[11] = 16'hB400;
		//1100 010 000001001, C409h Mov R010 "9"
		data_instruction[12] = 16'hC409;
		//1101 XXX 011 100 XXX, D0E0h CMP R011 R100
		data_instruction[13] = 16'hD0E0;
		//1110 000000001100, E00Ch Bne "2x12"
		data_instruction[14] = 16'hE00C;
		//1111 000000001100, F4ECh Jmp "2x12"
		data_instruction[15] = 16'hF00C;

	// Memory Initialization

		data3[510] <= 16'habcd;
	end

	reg[15:0] data_bus_read;

	assign data_bus = write_mode ? 'bz : data_bus_read;

	// Read/Write Data
	always@(posedge clk) begin
		case (write_mode)
			1'b0: begin
				//read mode
				case(address_bus[11:10])
					2'b00: data_bus_read <= data_instruction[address_bus[9:1]];
					2'b01: data_bus_read <= data1[address_bus[9:1]];
					2'b10: data_bus_read <= data2[address_bus[9:1]];
					2'b11: data_bus_read <= data3[address_bus[9:1]];
				endcase
			end
			1'b1: begin
				//write mode
				case(address_bus[11:10])
					2'b00: data_instruction[address_bus[9:1]] <= data_bus;
					2'b01: data1[address_bus[9:1]] <= data_bus;
					2'b10: data2[address_bus[9:1]] <= data_bus;
					2'b11: data3[address_bus[9:1]] <= data_bus;
				endcase
			end
		endcase
	end

	// Read Instruction

	assign Instruction_databus =
		(Instruction_addressbus[11:10] == 2'b00) ? data_instruction[Instruction_addressbus[9:1]]
		: (Instruction_addressbus[11:10] == 2'b01) ? data1[Instruction_addressbus[9:1]]
		: (Instruction_addressbus[11:10] == 2'b10) ? data2[Instruction_addressbus[9:1]]
												: data3[Instruction_addressbus[9:1]];
endmodule