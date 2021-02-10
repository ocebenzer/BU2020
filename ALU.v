module ALU (
	input signed [15:0] data1,
	input signed [15:0] data2,
	output[15:0] status_reg,
	output[15:0] result,
	input[2:0] ALU_control_output
);
	reg signed[15:0] outpt;
	reg[3:0] flags;

	assign result = outpt;
	assign status_reg[11:0] = 0;
	assign status_reg[15:12] = flags;
	
	wire[31:0] mul;
	assign mul = data1*data2;

	always @ * begin
		case (ALU_control_output)
			3'b000: outpt <= data1 + data2;
			3'b001: outpt <= data1 + data2; //How are we suppose to do this
			3'b010: outpt <= data1 - data2;
			3'b011: outpt <= data1 + data2;
			3'b100: outpt <= mul[15:0];
			3'b101: outpt <= data1 & data2;
			3'b110: outpt <= data1 << data2;
			3'b111: outpt <= data1;
			default: outpt <= data1 + data2;
		endcase
	// handle status register
		flags[3] <= outpt == 0;
		flags[2] <= outpt < 0;
		flags[1] <= outpt > 32767; //TODO what is the difference between carry-overflow?
		flags[0] <= outpt > 32767; // 16'hf7fff;
	end
endmodule