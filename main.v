module Main();

reg clk;

// temporary hard-codeasd
wire[15:0] instruction_bus;
assign instruction_bus = 16'b1100001000110010; // Move Immediate, D0 50(decimal)

BU2020 cpu(clk, instruction_bus);

initial begin
	$dumpfile("TimingDiagram.vcd");
	$dumpvars(0, cpu, clk);

	#200

	$finish;
end

always begin	
	clk = 0;
	#100;
    clk = 1;
    #100;
end

endmodule
