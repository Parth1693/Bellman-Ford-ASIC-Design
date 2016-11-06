/*Main module.
Build datapath*/

module datapath(clock ,reset, inputSRAM_Data, graphRead1_DataInput, graphRead2_DataInput, workRead1_DataInput, workRead2_DataInput, inputSRAM_Addr,  
graphRead1_Addr, graphRead2_Addr, workWrite_Dist, workWrite_Pred, workRead1_Addr, workRead2_Addr, workWrite_Addr, work_WE, outputWrite_Data, outputWrite_Addr, output_WE,
state, graphData1_Zero_reg, iterDone, iterStop, negCycle, zeroFlag, outputWriteDone, goS8);

/*** INPUTS ***/
input clock;
input reset;

//Inputs from FSM
input [4:0] state;

//Data from Graph SRAM.  
input [127:0] graphRead1_DataInput;
input [127:0] graphRead2_DataInput;

//Data from Input SRAM
input [7:0] inputSRAM_Data;

//Data from Work SRAM
input [127:0] workRead1_DataInput;
input [127:0] workRead2_DataInput;

/*** OUTPUTS ***/

//Outputs to FSM
output reg iterDone, negCycle;
output reg zeroFlag;
output outputWriteDone;
output reg iterStop;
output reg goS8;

//Address for graph SRAM
output reg [12:0] graphRead1_Addr;
output [12:0] graphRead2_Addr;

//Read addresses for Work SRAM
output reg [12:0] workRead1_Addr;
output reg [12:0] workRead2_Addr;

//Write address and data for Work SRAM
output reg [12:0] workWrite_Addr;
//output reg [127:0] workWrite_Data;
output reg [16:0] workWrite_Dist; 
output reg [7:0] workWrite_Pred;

output reg [9:0] inputSRAM_Addr;
output reg work_WE;
output graphData1_Zero_reg;

output reg [15:0] outputWrite_Data;
output reg [13:0] outputWrite_Addr;
output reg output_WE;

/*** Local variables ***/

//reg [127:0] graphRead1_Data;
reg [12:0] vertexAddress;
reg [7:0] vertexNumber;

reg [127:0] graphRead2_Data;

reg [7:0] sourceReg;
reg [7:0] destReg;

reg [16:0] workRead1_Dist; 
reg [7:0] workRead1_Pred;

reg [16:0] workRead2_Dist;
reg [7:0] workRead2_Pred;

reg [7:0] vertex;

//Counters
reg [7:0] daughterCount;		//Daughters of current vertex
reg [12:0] totalVertex;			//Total vertices - kept fixed once loaded.
reg [12:0] iterationCount;		//Iteration number
reg [7:0] vertexCount;			//Vertex count in current iteration.

//Zero Graph data signal.
wire graphData1_Zero_wire;
wire sourceFound;

reg [2:0] offsetMux_Sel1;
reg [2:0] offsetMux_Sel2;
reg [15:0] offsetMuxOut1;
reg [15:0] offsetMuxOut2;

reg [17:0] compareOut_Dist; 
reg [7:0] compareOut_Pred;
reg signed [63:0] addition;

reg iterStop_wire;

/*Compare portion 
d(u) + w < d(v)
Get d(u), d(v) from Work SRAM
Get w from graphRead2_Data.
d(u) is workRead1_Data [15:0]
d(v) is workRead2_Data [15:0]
w is Offset Mux output. (weight)
*/

always@(*)
begin
	
	if ( workRead1_Dist == 17'h0_FFFF )		//d(u) is infinity, don't update
	begin	
		compareOut_Dist <= workRead2_Dist;
		compareOut_Pred <= workRead2_Pred;
		iterStop_wire = 1;
	end
	
	else
	begin	
     addition = $signed (workRead1_Dist) + $signed (offsetMuxOut2[7:0]) ;
	 
	if ( $signed (addition) < $signed (workRead2_Dist) )
	begin
		compareOut_Dist <= addition [16:0];
		compareOut_Pred <= vertex;
		iterStop_wire = 0;
	end
		
	else
	begin
		compareOut_Dist <= workRead2_Dist;
		compareOut_Pred <= workRead2_Pred;
		iterStop_wire = 1;
	end
	end
	
end

//Logic to be implemented in each state
always@(posedge clock)

begin

//Reset State	
if (!reset) 
	begin 
	 sourceReg <= 8'b0;
	 destReg <= 8'b0;
	 zeroFlag <= 0;
	 graphRead1_Addr <= 0;
	 
	 inputSRAM_Addr <= 0;
	 work_WE <= 0;
	 vertexAddress <= 0;
	 vertexNumber <= 0;
	 graphRead2_Data <= 0;
	 
	 workRead1_Addr <= 0;
	 workRead2_Addr <= 0;
	 workWrite_Dist <= 0;
	 workWrite_Pred <= 0;
	 
	outputWrite_Addr <= 0;
	outputWrite_Data <= 0;
	output_WE <= 0;
		
	 daughterCount <= 0;
	 totalVertex <= 0;
	 iterationCount <= 0;
	 vertexCount <= 0;
	 	 
	end

/************************************* Input Phase ****************************************/

else
begin

//Load sourceReg with source number from input SRAM.
casex(state)
		
5'd1:				//State S1
begin
	sourceReg <= inputSRAM_Data;
	inputSRAM_Addr <= inputSRAM_Addr + 1; 
	
	//Bring machine to initial state.	
	iterStop <= 1'b1;
	
	 work_WE <= 0;
	 vertexAddress <= 0;
	 vertexNumber <= 0;
	 
	 graphRead2_Data <= 0;
	 graphRead1_Addr <= 0;
	 
	 workRead1_Addr <= 0;
	 workRead2_Addr <= 0;
	 workWrite_Dist <= 0;
	 workWrite_Pred <= 0;
	 
	outputWrite_Data <= 0;
	output_WE <= 0;
	
	 daughterCount <= 0;
	 totalVertex <= 0;
	 iterationCount <= 0;
	 vertexCount <= 0;
	
	if ( outputWrite_Addr == 14'b0 )
		outputWrite_Addr <= 14'b0;
	else outputWrite_Addr <= outputWrite_Addr + 1;
	
end

//Load destReg with destination number from input SRAM
5'd2:			//State S2
begin
	destReg <= inputSRAM_Data;
	inputSRAM_Addr <= inputSRAM_Addr + 1; 
end

//FF or 00 is encountered in input SRAM. If 00 is read, zeroFlag is set to denote end of source-destination pairs.
5'd3:			//State S3
begin
	inputSRAM_Addr <= inputSRAM_Addr + 1; 
	if( inputSRAM_Data == 8'b0 )
		zeroFlag <= 1'b1;
end	

/************************************* Initialization Phase ****************************************/

//Begin initialization phase.
//Semd address to Grpah SRAM to read first line.
5'd4:	  			 //State 4
begin
	work_WE <= 1'b0;
	graphRead1_Addr <= graphRead1_Addr + 1;
	vertexAddress <= graphRead1_DataInput[12:0];
	vertexNumber <= graphRead1_DataInput[71:64];
end

//Main init step. Write INF or 0 in Work SRAM depending on whether the vertex is source or not.
5'd5:	 		 //State 5
begin
	work_WE <= 1'b1;
	graphRead1_Addr <= graphRead1_Addr + 1;
	vertexAddress <= graphRead1_DataInput[12:0];
	vertexNumber <= graphRead1_DataInput[71:64];
	
	if (vertexNumber == 0)
	begin
		work_WE <= 1'b0;
		graphRead1_Addr <= 13'b0;
	end
	
	//Load counters with total number of vertices in the graph, when we reach 32'h0 line in Graph SRAM.
	if (graphData1_Zero_wire == 1)
	begin
		iterationCount <= graphRead1_Addr;
		vertexCount <= graphRead1_Addr;
		totalVertex <= graphRead1_Addr;		//fixed.
	end
	
	//If current vertex is source, write dist=0;
	if( sourceFound )
	begin
	//Write {0, UND}
	workWrite_Dist <= 17'b0;
	workWrite_Pred <= 8'b0;
	workWrite_Addr <= {5'b0, vertexNumber [7:0]};
	end	

	//If vertex is not source, write INF.
	else if ( !sourceFound )
	begin
	//Write {INF, UND}
	workWrite_Dist <= 17'h0FFFF;
	workWrite_Pred <= 8'b0;
	workWrite_Addr <= {5'b0, vertexNumber [7:0]};
	end
		
end		
		
/****************************************** Iteration Phase ***********************************************/

//Processing daughter nodes of a particular vertex.
//Start reading from Graph SRAM line-by-line.
5'd6:				//State S6
begin
	vertexAddress <= graphRead1_DataInput[12:0];
	vertexNumber <= graphRead1_DataInput[71:64];
end

//Load daughterCount for current vertex. Also, make both offsets = 1.	
5'd7:				//State S7
begin
	offsetMux_Sel1 <= 1'b1;
	offsetMux_Sel2 <= 1'b1;
	daughterCount <= graphRead2_DataInput [119:112];
	work_WE <= 1'b0;
	graphRead2_Data <= graphRead2_DataInput;
	vertex <= vertexNumber;
end	

//Send address to Work SRAM to read dist(u) and dist(v).
5'd8:				//State S8
begin
	
	work_WE <= 1'b0; 
	//Read d(u)
	workRead1_Addr <= {5'b0, vertexNumber [7:0]};
	//Read d(v)
	workRead2_Addr <= {5'b0, offsetMuxOut1[15:8]};
	offsetMux_Sel1 <= offsetMux_Sel1 + 1;
	
	if ( daughterCount == 1'b1 )
		graphRead1_Addr <= graphRead1_Addr + 1;
end		

//Send address to Work SRAM for reading if 
5'd9: 			//State S9
begin
	work_WE <= 1'b0;
	workRead1_Pred <= workRead1_DataInput[7:0];
	workRead1_Dist <= workRead1_DataInput[80:64];
	
	workRead2_Pred <= workRead2_DataInput[7:0];
	workRead2_Dist <= workRead2_DataInput[80:64];
	
	if ( daughterCount == 1'b1 )
	begin
		vertexAddress <= graphRead1_DataInput[12:0];
		vertexNumber <= graphRead1_DataInput[71:64];
	end	
	
	//Pipeline
	if ( daughterCount > 1 )
	begin
		workRead1_Addr <= {5'b0, vertexNumber [7:0]};
		workRead2_Addr <= {5'b0, offsetMuxOut1[15:8]};
		offsetMux_Sel1 <= offsetMux_Sel1 + 1;
	end
	
	if ( daughterCount == 2 )
	begin
		graphRead1_Addr <= graphRead1_Addr + 1;
	end
	
end

//Main FSM state to process the data for each daughter node.
//Stay in S10 till all daughters on a paricular line in Graph SRAM are processed.
//Go to S8 to start processing another line. 
5'd10:				//State 10
begin
	
	if ( iterStop_wire == 0 )
	iterStop <= 0;				//Check if there is any update.
	else if ( iterStop_wire == 1 )
	iterStop <= iterStop;
	
	if ( daughterCount > 1 )
	begin
		daughterCount <= daughterCount - 1;
		
		workRead1_Pred <= workRead1_DataInput[7:0];
		workRead1_Dist <= workRead1_DataInput[80:64];
		
		workRead2_Pred <= workRead2_DataInput[7:0];
		workRead2_Dist <= workRead2_DataInput[80:64];
	end
		
	work_WE <= 1'b1;
	
	workWrite_Dist <= compareOut_Dist;
	workWrite_Pred <= compareOut_Pred;
	workWrite_Addr <= {5'b0, offsetMuxOut2[15:8]};
	
	offsetMux_Sel2 <= offsetMux_Sel2 + 1;
		
	if ( daughterCount == 1'b1 )
	begin
		vertex <= vertexNumber;
		graphRead2_Data <= graphRead2_DataInput;
		daughterCount <= graphRead2_DataInput[119:112];
		offsetMux_Sel1 <= 1'b1;
		offsetMux_Sel2 <= 1'b1;
		vertexCount <= vertexCount - 1'b1;
	end
	
	
	//Pipeline
	if ( ( daughterCount > 2 ) && (offsetMux_Sel1 != 0) )
	begin
		workRead1_Addr <= {5'b0, vertexNumber [7:0]};
		workRead2_Addr <= {5'b0, offsetMuxOut1[15:8]};
		offsetMux_Sel1 <= offsetMux_Sel1 + 1;
	end
	
	if ( ( daughterCount == 3 ) && (offsetMux_Sel1 != 0) )
	begin
		graphRead1_Addr <= graphRead1_Addr + 1;
	end
	
	if ( daughterCount == 2 )
	begin
		vertexAddress <= graphRead1_DataInput[12:0];
		vertexNumber <= graphRead1_DataInput[71:64];
	end
	
	//Pipeline multiple lines
	
	if ( (offsetMux_Sel2 == 6 ) && ( daughterCount > 2) )
	begin
		vertexAddress <= vertexAddress + 1;
	end
	
	if ( (offsetMux_Sel2 == 7 ) && ( daughterCount > 1) )
	begin
		graphRead2_Data <= graphRead2_DataInput;
	end
		
end

//End of one iteration state. Setup regs for another iteration. Jump to output phase if iterations are over
//or if there is no updation in the cuurent iteration from last iteration.	
5'd11:				//State 11
begin
	iterationCount <= iterationCount - 1;
	graphRead1_Addr <= 1'b0;
	work_WE <= 1'b0;
	daughterCount <= 1'b0;
	vertexCount <= totalVertex;
	
	if (!iterStop)
		iterStop <= 1'b1;		
end		
		
/****************************************** Output Write Phase ***********************************************/	

//Start output SRAM writing. Send destReg address to Work SRAM.
5'd12:			//State 12
begin
	workRead1_Addr <= {5'b0, destReg};
end

//Load data from Work SRAM into read data registers.
5'd14:			//State 14
begin
	
	workRead1_Pred <= workRead1_DataInput[7:0];
	workRead1_Dist <= workRead1_DataInput[80:64];
end

//Write destination distance into Output SRAM.
5'd15:			//State 15
begin
	output_WE <= 1;
	
	outputWrite_Data <= workRead1_Dist[15:0];
end

//Write destination vertex number into Output SRAM.
5'd16:			//State 16
begin
	outputWrite_Addr <= outputWrite_Addr + 1;
	outputWrite_Data <= {8'b0, destReg};
	output_WE <= 1;
end

//Read predeccessor vertex number from work SRAM data and send it to Work SRAM for reading previous vertex data.
//Send data, address and write enable to output enable to output SRAM to write.
5'd17:				//State 17
begin
	outputWrite_Addr <= outputWrite_Addr + 1;
	
	outputWrite_Data <= {8'b0, workRead1_Pred};
	
	workRead1_Addr <= {5'b0, workRead1_Pred};
	output_WE <= 1;
end

//Load data from work SRAM into read registers.
//Move back to S17 to write in to output SRAM.
5'd18:				//State 18
begin
	output_WE <= 0;
	
	workRead1_Pred <= workRead1_DataInput[7:0];
	workRead1_Dist <= workRead1_DataInput[80:64];
end

//Finish writing into output SRAM. Move back to S1 if there is a source-destination pair yet to be processed, otherwise move to 
//S20 to finish program execution.
5'd19:				//State 19
begin
	outputWrite_Addr <= outputWrite_Addr + 1;
	output_WE <= 1;
	
	workRead1_Pred <= workRead1_DataInput[7:0];
	workRead1_Dist <= workRead1_DataInput[80:64];

	if ( zeroFlag == 1'b1 )
	outputWrite_Data <= 16'b0;
	else outputWrite_Data <= 16'hFFFF;	
end

//Negative cycle exists stage.
//Write FFFF in Outpur SRAM and exit.
5'd13:				//State 13
begin
	output_WE <= 1;
	outputWrite_Addr <= 14'b0;
	outputWrite_Data <= 16'hFFFF;
end

//END state. Finish program execution.
5'd20:				//State END. (20)
begin
	output_WE <= 0;
end

endcase

end 	//else ends..
		// Phases end..
end

//iterDone : Normal iteration over, go to S11.
//In S11, we decide whether we want to go to S6, S12 or S13.

assign outputWriteDone = ( workRead1_Pred == sourceReg );

always@(*)
begin
	if ( ( daughterCount == 1 ) | ( (offsetMux_Sel2 == 7) && (daughterCount > 1) ) )
		goS8 = 1;
	else goS8 = 0;
end

always@(*)
begin	
	if ( (daughterCount == 1'b1) & (vertexCount == 1'b1) )
		iterDone = 1'b1;			//Go to State 11 transition logic.
	else
		iterDone = 1'b0;		
end

always@(*)
begin
		if ( ( iterationCount == 1'b1 ) & ( iterStop == 1'b0) )
			negCycle = 1'b1;		//Go to State 13.
		else
			negCycle = 1'b0;
end


//Check for zero data from graph SRAM.
assign graphData1_Zero_wire = (graphRead1_DataInput == 128'b0);
assign graphData1_Zero_reg = (vertexNumber == 0);

//Assign graphRead2 address from graphRead1 data port.
assign graphRead2_Addr = vertexAddress [12:0];

//Compare current vertex with source vertex.
assign sourceFound = (vertexNumber [7:0] == sourceReg);

//Mux1 to select a daughter:weight pair from graphData2
always@(*)
begin
	casex(offsetMux_Sel1)
		3'b000: offsetMuxOut1 = graphRead2_Data[127:112];
		3'b001: offsetMuxOut1 = graphRead2_Data[111:96];
		3'b010: offsetMuxOut1 = graphRead2_Data[95:80];
		3'b011: offsetMuxOut1 = graphRead2_Data[79:64];
		3'b100: offsetMuxOut1 = graphRead2_Data[63:48];
		3'b101: offsetMuxOut1 = graphRead2_Data[47:32];
		3'b110: offsetMuxOut1 = graphRead2_Data[31:16];
		3'b111: offsetMuxOut1 = graphRead2_Data[15:0];
	//	default:  offsetMuxOut1 = 16'bx;
	endcase
	
end

//Mux2 to select a daughter:weight pair from graphData2
always@(*)
begin
	casex(offsetMux_Sel2)
		3'b000: offsetMuxOut2 = graphRead2_Data[127:112];
		3'b001: offsetMuxOut2 = graphRead2_Data[111:96];
		3'b010: offsetMuxOut2 = graphRead2_Data[95:80];
		3'b011: offsetMuxOut2 = graphRead2_Data[79:64];
		3'b100: offsetMuxOut2 = graphRead2_Data[63:48];
		3'b101: offsetMuxOut2 = graphRead2_Data[47:32];
		3'b110: offsetMuxOut2 = graphRead2_Data[31:16];
		3'b111: offsetMuxOut2 = graphRead2_Data[15:0];
	//	default:  offsetMuxOut2 = 16'bx;
	endcase
	
end

endmodule
  
