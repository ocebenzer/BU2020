module Main();

reg clk;

// temporary hard-code
wire[15:0] instruction_bus;
assign instruction_bus = 16'b1100001000110010; // Move Immediate, D0 50(decimal)

wire[15:0] data_bus;
wire[11:0] address_bus;

assign data_bus = 16'habcd;
assign address_bus = 12'hffe;

Memory memory(address_bus, data_bus, clk, 1'b1);
BU2020 cpu(clk, instruction_bus);

initial begin
	$dumpfile("TimingDiagram.vcd");
	$dumpvars(0, memory, clk);

	#400

	$finish;
end

always begin	
	clk = 0;
	#100;
    clk = 1;
    #100;
end

endmodule
