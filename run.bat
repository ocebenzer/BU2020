copy TimingDiagram.vcd TimingDiagram.vcd.old
copy output.vvp output.vvp.old
del TimingDiagram.vcd
del output.vvp

iverilog -o output.vvp main.v BU2020.v Memory.v
vvp output.vvp

if exist TimingDiagram.vcd (
	gtkwave TimingDiagram.vcd
)