`timescale 1ns/1ns

module Main();

reg clk = 0;
reg[15:0] cycle = 0;

//Connection between cpu-memory
wire[11:0] address_bus, Instruction_addressbus;
wire[15:0] data_bus, Instruction_databus, incoming_data_bus;
wire write_mode, doubleRead, doubleWrite;

BU2020 cpu(clk, address_bus, data_bus, incoming_data_bus, write_mode, Instruction_addressbus, Instruction_databus, doubleRead, doubleWrite);
Memory memory(clk, address_bus, data_bus, incoming_data_bus, write_mode, Instruction_addressbus, Instruction_databus, doubleRead, doubleWrite);


initial begin
	$dumpfile("TimingDiagram.vcd");
	$dumpvars(0, cycle, memory, cpu, Instruction_addressbus, Instruction_databus, incoming_data_bus, address_bus, data_bus, write_mode);

	#4000

	$finish;
end

always begin
    #1;
	clk = 0;
	#1;
    clk = 1;
end

always begin
	cycle = cycle + 1;
	#2;
end

endmodule
