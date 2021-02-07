`timescale 1ns/1ns

module BU2020 (
	input clk,
	output[11:0] Memory_addressbus,
	inout[15:0] Memory_databus,
	output Memory_writemode,
	output[11:0] Instruction_addressbus,
	input[15:0] Instruction_databus
	);


	// Additional registers @ref Stages.v - Registers
		reg[15:0] PC = 16'h0000;
		// Wires: "From PC" and "To PC"
		wire[15:0] pc_from, pc_to;

		assign pc_from = PC;

		always @(posedge clk) begin
			PC <= pc_to;
		end

	// Registers between stages

		reg[1:0][15:0] IF_ID;
		// If_ID[0] -> PC
		// IF_ID[1] -> Instruction

		reg[3:0][15:0] ID_EX;
		// ID_EX[0] -> PC
		// ID_EX[1] -> Register1
		// ID_EX[2] -> Register2
		// ID_EX[3] -> Immideate Value

		reg[3:0][15:0] EX_MEM;
		// EX_MEM[0] -> PC(Updated)
		// EX_MEM[1] -> Zero
		// EX_MEM[2] -> ALU Result
		// EX_MEM[3] -> Data2

		reg[1:0][15:0] MEM_WB;
		// MEM_WB[0] -> Memory Output
		// MEM_WB[0] -> ALU Output

		wire[15:0] if_in, wb_out;
		wire[1:0][15:0] if_out, id_in, mem_out, wb_in;
		wire[3:0][15:0] id_out, ex_in, ex_out, mem_in;

	// Register Stages
		STAGE_IF	_IF(clk, if_in, if_out, Instruction_addressbus, Instruction_databus, pc_from, pc_to);
		STAGE_ID	_ID(clk, id_in, id_out, wb_out);
		STAGE_EX	_EX(clk, ex_in, ex_out);
		STAGE_MEM	_MEM(clk, mem_in, mem_out, Memory_addressbus, Memory_databus, Memory_writemode);
		STAGE_WB	_WB(clk, wb_in, wb_out);

	// Connect Stages

		assign if_in = EX_MEM[0];
		assign id_in = IF_ID;
		assign ex_in = ID_EX;
		assign mem_in = EX_MEM;
		assign wb_in = MEM_WB;

		always @(posedge clk) begin
			IF_ID <= if_out;
			ID_EX <= id_out;
			EX_MEM <= ex_out;
			MEM_WB <= mem_out;
		end

	// Connect Memory-MEM
		//TODO

endmodule
