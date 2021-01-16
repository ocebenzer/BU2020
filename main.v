module Main();

reg clk;

// temporary hard-code
wire[15:0] instruction_bus;
assign instruction_bus = 16'b1100001000110010; // Move Immediate, D0 50(decimal)

reg[15:0] data_bus_reg;
reg[11:0] address_bus_reg;
reg write_mode_reg;

wire[15:0]data_bus;
wire[11:0] address_bus;
wire write_mode;

always @(posedge clk) begin
	data_bus_reg <= data_bus;
	address_bus_reg <= address_bus;
end

assign data_bus = write_mode ? data_bus_reg : 'bz;
assign address_bus = address_bus_reg;
assign write_mode = write_mode_reg;


Memory memory(address_bus, data_bus, clk, write_mode);
BU2020 cpu(clk, instruction_bus);

initial begin
	$dumpfile("TimingDiagram.vcd");
	$dumpvars(0, memory, data_bus, address_bus, data_bus_reg, address_bus_reg, clk);

 	write_mode_reg <= 1'b1;

	data_bus_reg <= 16'haaaa;
	address_bus_reg <= 12'hffe;
	#4
	data_bus_reg <= 16'hbbbb;
	address_bus_reg <= 12'hffc;
	#4
	data_bus_reg <= 16'hcccc;
	address_bus_reg <= 12'hffa;
	#4
	data_bus_reg <= 16'hdddd;
	address_bus_reg <= 12'hff8;
	#8
	
 	write_mode_reg <= 1'b0;
	address_bus_reg <= 12'hffc;

	#20

	$finish;
end

always begin	
	clk = 0;
	#1;
    clk = 1;
    #1;
end

endmodule
