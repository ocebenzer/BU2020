module Memory(input[11:0] address_bus, inout[15:0] databus, input wire clk, write_mode);

	// 4KB Memory, 4x1KB modules, first module is instruction module, rest 3 are data modules
	reg[2047:0][15:0] data = 0;
	wire module_no = address_bus[11:10];
	wire relative_address_low = address_bus[9:0];
	wire relative_address_high = address_bus[9:0] + 1;

	//data[[module_no][relative_address+1]:[module_no][relative_address]] gives us the 16 bit we address

	always@(posedge clk) begin
		case (write_mode)
			1'b0: begin
				//read mode
				//databus <= data[[address_bus[11:10]][address_bus[9:0]+1]:[address_bus[11:10]][address_bus[9:0]]];
				end
			1'b1: begin
				//write mode
				data[address_bus[11:1]] <= databus;
				end
		endcase
	end
endmodule