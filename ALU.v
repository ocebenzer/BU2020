module ALU (
	input[15:0] data1,
	input[15:0] data2,
	output[15:0] zero, // TODO check if this can be status register
	output[15:0] result,
	input[2:0] ALU_control_output
);
	reg[15:0] outpt;

	assign result = outpt;
	
	wire[31:0] mul;
	assign mul = data1*data2;

	always @ * begin
		case (ALU_control_output)
			3'b000: begin
				outpt <= data1 + data2;
			end
			3'b001: begin
				outpt <= data1 + data2; //How are we suppose to do this
			end
			3'b010: begin
				outpt <= data1 - data2;
			end
			3'b011: begin
				outpt <= data1 + data2;
			end
			3'b100: begin
				outpt <= mul[15:0];
			end
			3'b101: begin
				outpt <= data1 & data2;
			end
			3'b110: begin
				outpt <= data1 << data2;
			end
			3'b111: begin
				outpt <= data1;
			end
			default: begin
				outpt <= data1 + data2;
			end
		endcase
	end
endmodule