module BU2020(input clk, inout[15:0] instruction_bus);
//instruction_bus hard coded to "16'b1100001000110010" for now

	reg[10:0][15:0] registers;
	/*
	registers[0]: Zero Register
	registers[1-4]: D registers
	registers[5-7]: A registers
	registers[8]: SR
	registers[9]: BA
	registers[10]: PC
	*/
	
	initial begin
		// Initially all registers but BA will be 0x0000, BA will be 0x0040 since the Base Address starts from 0x0040
		registers <= 176'h000000000040000000000000000000000000000000000000;
	end

	always @(posedge clk) begin
		// TODO properly fetch data from PC address
		case (instruction_bus[15:12])
			4'b0000: ;		// Add registers, R format
			4'b0001: ;		// Add from memory, I1 format
			4'b0010: ;		// Subtract registers, R format
			4'b0011: ;		// Add Immediate, I2 format
			4'b0100: ;		// Multiply, R format
			4'b0101: ;		// AND, R format
			4'b0110: ;		// Shift Left, I2 format
			4'b0111: ;		// Load word, I2 format
			4'b1000: ;		// Load word pointer, I2 format
			4'b1001: ;		// Save word, I2 format
			4'b1010: ;		// Save word pointer, I2 format
			4'b1011: ;		// Clear register, R format
			4'b1100: begin 	// Move Immediate, I1 format
				registers[instruction_bus[11:9]] <= instruction_bus[8:0];
				// TODO Properly ADD PC+4
				registers[10] <= 16'h0004;
			end
			4'b1101: ;		// Compare registers, R format
			4'b1110: ;		// Branch not equal, J format
			4'b1111: ;		// Unconditional jump, J format
		endcase
	end


endmodule