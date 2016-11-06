/* Top module 
This module will be synthesized.
Instantiate all modules except memories */

module top_without_mem(clock, reset, start, inputSRAM_Data, graphRead1_DataInput, graphRead2_DataInput, workRead1_DataInput, workRead2_DataInput, inputSRAM_Addr,  
graphRead1_Addr, graphRead2_Addr, workWrite_Dist, workWrite_Pred, workRead1_Addr, workRead2_Addr, workWrite_Addr, work_WE, outputWrite_Data, outputWrite_Addr, output_WE);

input reset;
input clock;
input start;
input [7:0] inputSRAM_Data;
input [127:0] graphRead1_DataInput, graphRead2_DataInput, workRead1_DataInput, workRead2_DataInput;

output [16:0] workWrite_Dist;
output [7:0] workWrite_Pred;
output [9:0] inputSRAM_Addr;  
output [12:0] graphRead1_Addr, graphRead2_Addr, workRead1_Addr, workRead2_Addr, workWrite_Addr;
output work_WE, output_WE;
output [15:0]  outputWrite_Data;
output [13:0] outputWrite_Addr;

wire graphData1_Zero_reg, iterDone, iterStop, negCycle, zeroFlag, outputWriteDone, goS8;
wire [4:0] state;

datapath data ( .clock(clock), .reset(reset), .inputSRAM_Data(inputSRAM_Data), .graphRead1_DataInput(graphRead1_DataInput), .graphRead2_DataInput(graphRead2_DataInput), 
.workRead1_DataInput(workRead1_DataInput), .workRead2_DataInput(workRead2_DataInput), .inputSRAM_Addr(inputSRAM_Addr),  
.graphRead1_Addr(graphRead1_Addr), .graphRead2_Addr(graphRead2_Addr), .workWrite_Dist(workWrite_Dist), .workWrite_Pred(workWrite_Pred), .workRead1_Addr(workRead1_Addr), .workRead2_Addr(workRead2_Addr), 
.workWrite_Addr(workWrite_Addr), .work_WE(work_WE), .outputWrite_Data(outputWrite_Data), .outputWrite_Addr(outputWrite_Addr), .output_WE(output_WE),
.state(state),.graphData1_Zero_reg(graphData1_Zero_reg),  .iterDone(iterDone), .iterStop(iterStop), .negCycle(negCycle), .zeroFlag(zeroFlag), .outputWriteDone(outputWriteDone), .goS8(goS8) );

fsm control ( .clock(clock), .reset(reset), .start(start), .graphData1_Zero(graphData1_Zero_reg), .iterDone(iterDone), .iterStop(iterStop), .negCycle(negCycle), 
.zeroFlag(zeroFlag), .outputWriteDone(outputWriteDone), .goS8(goS8), .fsm_state(state));

endmodule
