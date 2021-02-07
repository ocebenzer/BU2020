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
		data_instruction[15:0] = 256'h0000111122223333444455556666777788889999aaaabbbbccccddddeeeeffff;
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