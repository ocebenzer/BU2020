`timescale 1ns / 1ns

module SimpleAdder(input x1, x2, output out, carry);
	xor(out, x1, x2);
	and(carry, x1, x2);
endmodule


module CarryLookaheadAdder(input[3:0] x1, x2,
							input old_carry, 
							output[3:0] out, 
							output flag);

	// Level 1
	wire[3:0] outs, carrys;

	SimpleAdder add0(x1[0], x2[0], outs[0], carrys[0]);
	SimpleAdder add1(x1[1], x2[1], outs[1], carrys[1]);
	SimpleAdder add2(x1[2], x2[2], outs[2], carrys[2]);
	SimpleAdder add3(x1[3], x2[3], outs[3], carrys[3]);
	
	// Level 2
	wire[0:0] group0;
	wire[1:0] group1;
	wire[2:0] group2;
	wire[3:0] group3;

	and(group0[0], old_carry, outs[0]);
	
	and(group1[0], old_carry, outs[0], outs[1]);
	and(group1[1], carrys[0], outs[1]);
	
	and(group2[0], old_carry, outs[0], outs[1], outs[2]);
	and(group2[1], carrys[0], outs[1], outs[2]);
	and(group2[2], carrys[1], outs[2]);
	
	and(group3[0], old_carry, outs[0], outs[1], outs[2], outs[3]);
	and(group3[1], carrys[0], outs[1], outs[2], outs[3]);
	and(group3[2], carrys[1], outs[2], outs[3]);
	and(group3[3], carrys[2], outs[3]);

	// Level 3
	wire[2:0] c;

	or(c[0], group0[0], carrys[0]);
	or(c[1], group1[0], group1[1], carrys[1]);
	or(c[2], group2[0], group2[1], group2[2], carrys[2]);
	or(flag, group3[0], group3[1], group3[2], group3[3], carrys[3]);

	// Level 4
	xor(out[0], old_carry, outs[0]);
	xor(out[1], c[0], outs[1]);
	xor(out[2], c[1], outs[2]);
	xor(out[3], c[2], outs[3]);

endmodule

module ByteWiseAdder(input[7:0] x1, x2,
						input old_carry,
						output[7:0] out,
						output flag);

	wire tmp_carry;
	CarryLookaheadAdder least_sig_adder(x1[3:0], x2[3:0], old_carry, out[3:0], tmp_carry);
	CarryLookaheadAdder	most_sig_adder(x1[7:4], x2[7:4], tmp_carry, out[7:4], flag);
endmodule

module WordWiseAdder(input[15:0] x1, x2,
						input old_carry,
						output[15:0] out,
						output flag);

	wire tmp_carry;
	ByteWiseAdder least_sig_adder(x1[7:0], x2[7:0], old_carry, out[7:0], tmp_carry);
	ByteWiseAdder	most_sig_adder(x1[15:8], x2[15:8], tmp_carry, out[15:8], flag);

endmodule