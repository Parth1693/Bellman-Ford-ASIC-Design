/*top with mem*/

module top_with_mem (clock, reset, start);

input clock;
input reset;
input start;

wire [9:0] inputSRAM_Addr;
wire [7:0] inputSRAM_Data;
wire [12:0] graphRead1_Addr, graphRead2_Addr, workRead1_Addr, workRead2_Addr, workWrite_Addr;
wire [127:0] graphRead1_DataInput, graphRead2_DataInput, workRead1_DataInput, workRead2_DataInput;
wire work_WE, output_WE;
wire [15:0] outputWrite_Data, ReadBus;
wire [13:0] outputWrite_Addr, ReadAddress;
wire [16:0] workWrite_Dist;
wire [7:0] workWrite_Pred;


SRAM_1R input_sram (.ReadAddress(inputSRAM_Addr), .ReadBus(inputSRAM_Data));

SRAM_2R graph_sram (.ReadAddress1(graphRead1_Addr), .ReadAddress2(graphRead2_Addr), .ReadBus1(graphRead1_DataInput), .ReadBus2(graphRead2_DataInput) );

SRAM_2R1W work_sram (.clock(clock), .WE(work_WE), .WriteAddress(workWrite_Addr), .ReadAddress1(workRead1_Addr), .ReadAddress2(workRead2_Addr), 
.WriteBus({{47'b0,workWrite_Dist}, {56'b0, workWrite_Pred}}), .ReadBus1(workRead1_DataInput), .ReadBus2(workRead2_DataInput));

SRAM_1R1W output_sram (.clock(clock), .WE(output_WE), .WriteAddress(outputWrite_Addr), .ReadAddress(ReadAddress), .WriteBus(outputWrite_Data), .ReadBus(ReadBus) );

top_without_mem main (.clock(clock), .reset(reset), .start(start), .inputSRAM_Data(inputSRAM_Data), .graphRead1_DataInput(graphRead1_DataInput), .graphRead2_DataInput(graphRead2_DataInput),
.workRead1_DataInput(workRead1_DataInput), .workRead2_DataInput(workRead2_DataInput), .inputSRAM_Addr(inputSRAM_Addr),  
.graphRead1_Addr(graphRead1_Addr), .graphRead2_Addr(graphRead2_Addr), .workWrite_Dist(workWrite_Dist), .workWrite_Pred(workWrite_Pred), .workRead1_Addr(workRead1_Addr), 
.workRead2_Addr(workRead2_Addr), .workWrite_Addr(workWrite_Addr), .work_WE(work_WE), .outputWrite_Data(outputWrite_Data), .outputWrite_Addr(outputWrite_Addr), .output_WE(output_WE));

endmodule
