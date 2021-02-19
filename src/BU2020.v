`timescale 1ns/1ns

module BU2020 (
	input clk,
	output[11:0] Memory_addressbus,
	input[15:0] Memory_databus,
	output[15:0] Memory_incoming_data_bus,
	output Memory_writemode,
	output[11:0] Instruction_addressbus,
	input[15:0] Instruction_databus,
	output doubleRead,
	output doubleWrite
	);


	// Additional registers @ref Registers.v
		reg[15:0] PC = 16'h0000;
		// Wires: "From PC" and "To PC"
		wire[15:0] pc_from, pc_to;
		assign pc_from = PC;

		//Status register
		reg[15:0] SR;
		wire[3:0] _SR = SR[15:12];
		// Wires: "From SR" and "To SR"
		wire[15:0] sr_from, sr_to;
		assign sr_from = SR;
		assign sr_to = EX_MEM[1];

		always @(posedge clk) begin
			PC <= pc_to;
			SR <= sr_to;
		end

	// Registers between stages
		reg[1:0][15:0] IF_ID = 32'hD0000000;
		// If_ID[0] -> PC
		// IF_ID[1] -> Instruction

		reg[5:0][15:0] ID_EX;
		// ID_EX[0] -> PC
		// ID_EX[1] -> Register1
		// ID_EX[2] -> Register2
		// ID_EX[3] -> Immideate Value
		// ID_Ex[4] -> ALU Control Input
		// Id_EX[5] -> Target Register Address

		reg[4:0][15:0] EX_MEM;
		// EX_MEM[0] -> PC(Updated)
		// EX_MEM[1] -> Zero
		// EX_MEM[2] -> ALU Result
		// EX_MEM[3] -> Data2
		// EX_MEM[4] -> Target Register Address

		reg[2:0][15:0] MEM_WB;
		// MEM_WB[0] -> Memory Output
		// MEM_WB[1] -> ALU Output
		// MEM_WB[2] -> Target Register Address

		wire[15:0] if_in, wb_out_data;
		wire[2:0] wb_out_reg_address;
		wire[1:0][15:0] if_out, id_in;
		wire[2:0][15:0] wb_in, mem_out;
		wire[4:0][15:0] ex_out, mem_in;
		wire[5:0][15:0] id_out, ex_in;

	// Control Unit Stages
	// WB
		// [0] -> 1 bit RegWrite
		// [1] -> 1 bit MemToReg
	// MEM
		// [0] -> 1 bit Simple Jump
		// [1] -> 1 bit BNE Jump
		// [2] -> 1 bit MemWrite, also works as MemRead
		// [3] -> doubleWrite
		// [4] -> doubleRead
	// EX
		// [2:0] -> 3 bit ALU Op
		// [4:3] -> 1 bit ALU Src

		reg[1:0] ID_EX__WB = 0;
		reg[4:0] ID_EX__MEM = 0;
		reg[4:0] ID_EX__EX = 0;

		reg[1:0] EX_MEM__WB = 0;
		reg[4:0] EX_MEM__MEM = 0;

		reg[1:0] MEM_WB__WB = 0;

		wire[11:0] id_control_output;
		wire[4:0] ex_control_input;
		wire[4:0] mem_control_input;
		wire[1:0] wb_control_input;

		assign ex_control_input = ID_EX__EX;
		assign mem_control_input = EX_MEM__MEM;
		assign wb_control_input = MEM_WB__WB;

		wire pc_src;

	// Stages
		STAGE_IF	_IF(clk, if_in, if_out, Instruction_addressbus, Instruction_databus, pc_from, pc_to, pc_src);
		STAGE_ID	_ID(clk, id_in, id_out, wb_out_data, wb_out_reg_address, id_control_output, wb_control_input[0]);
		STAGE_EX	_EX(clk, ex_in, ex_out, ex_control_input);
		STAGE_MEM	_MEM(clk, mem_in, mem_out, Memory_addressbus, Memory_databus, Memory_incoming_data_bus, Memory_writemode, mem_control_input, _SR[3], pc_src, doubleRead, doubleWrite);
		STAGE_WB	_WB(clk, wb_in, wb_out_data, wb_out_reg_address, wb_control_input);

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

	// Connect Control Stages
		always @(posedge clk) begin
			MEM_WB__WB <= EX_MEM__WB;

			EX_MEM__WB <= ID_EX__WB;
			EX_MEM__MEM <= ID_EX__MEM;

			ID_EX__WB = id_control_output[1:0];
			ID_EX__MEM = id_control_output[6:2];
			ID_EX__EX = id_control_output[11:7];
		end
endmodule
