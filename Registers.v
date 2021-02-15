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