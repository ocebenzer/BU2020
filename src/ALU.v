module ALU (
	input signed [15:0] data1,
	input signed [15:0] data2,
	output[15:0] status_reg,
	output[15:0] result,
	input[2:0] ALU_control_input
);
	reg signed[15:0] outpt;
	reg[3:0] flags;

	assign result = outpt;
	assign status_reg[11:0] = 0;
	assign status_reg[15:12] = flags;
	

	// mul and sli need to be calculated outside
	wire[31:0] mul, sll;
	assign mul = data1*data2;
	assign sll = data1 << data2[3:0];

	always @ * begin
		case (ALU_control_input)
			3'b000: begin
				outpt <= data1 + data2;
			// handle status register for addition
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				// overflow happens if adding them pass the integer limit
				flags[1] <= (data1+data2 > 32767 || data1+data2 < -32768);
				flags[0] <= flags[1]; // what is the difference between carry-overflow?
			end

			3'b001: begin
				outpt <= data1 + data2; //TODO Find if we can do this, for now its "Add r1 r2 r3"
			// handle status register for addition
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				// overflow happens if adding them pass the integer limit
				flags[1] <= (data1+data2 > 32767 || data1+data2 < -32768);
				flags[0] <= flags[1]; // what is the difference between carry-overflow?
			end

			3'b010: begin
				outpt <= data1 - data2;
			// handle status register for subtraction
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				// overflow happens if subtracting them pass the integer limit
				flags[1] <= (data1-data2 > 32767 || data1-data2 < -32768);
				flags[0] <= flags[1]; // what is the difference between carry-overflow?
			end

			3'b011: begin
				outpt <= data1 + data2;
			// handle status register for addition
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				// overflow happens if adding them pass the integer limit
				flags[1] <= (data1+data2 > 32767 || data1+data2 < -32768);
				flags[0] <= flags[1]; // what is the difference between carry-overflow?
			end

			3'b100: begin
				outpt[15] <= mul[31];
				outpt[14:0] <= mul[14:0];
			// handle status register for multiplication
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				flags[1] <= (mul > 32767 || mul < -32768);
				// we take LSB of the multiplication, then what will be the Carry Flag??
				// Is it MSB > 0??
				flags[0] <= mul[30:16] > 0;
			end

			3'b101: begin
				outpt <= data1 & data2;
			// handle status register
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				flags[1] <= 0;
				flags[0] <= 0;
			end

			3'b110: begin
				outpt <= sll;
			// handle status register for shift left carry
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				// overflow happens if any bit goes pass the 16-bit-limit for data1
				flags[1] <= (data1 != 0) && ((data2 > 15) || sll[31:16] > 0);
				flags[0] <= flags[1];
			end

			3'b111: begin
				outpt <= data2;
			// handle status register
				flags[3] <= outpt == 0;
				flags[2] <= outpt < 0;
				flags[1] <= 0;
				flags[0] <= 0;
			end
		endcase
	end
endmodule