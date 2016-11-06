/*Module FSM*/

module fsm (clock, reset, start, graphData1_Zero, iterDone, iterStop, negCycle, zeroFlag, outputWriteDone, goS8, fsm_state);

input clock;
input reset;
input start;

//From datapath
input graphData1_Zero;
input iterDone, iterStop, negCycle;
input outputWriteDone, zeroFlag;
input goS8;

output reg [4:0] fsm_state;

parameter [4:0] S0 = 5'd0,
S1 = 5'd1,
S2 = 5'd2,
S3 = 5'd3,
S4 = 5'd4,
S5 = 5'd5,
S6 = 5'd6,
S7 = 5'd7,
S8 = 5'd8,
S9 = 5'd9,
S10 = 5'd10,
S11 = 5'd11,
S12 = 5'd12,
S13 = 5'd13,
S14 = 5'd14,
S15 = 5'd15,
S16 = 5'd16,
S17 = 5'd17,
S18 = 5'd18,
S19 = 5'd19,
S20 = 5'd20;

reg [4:0] current_state, next_state;

always@(posedge clock)
begin
	if(!reset) current_state <= S0;
	else current_state <= next_state;
end

always@(*)
begin
case(current_state)

	S0: 
	begin	
	 if (start)
		next_state = S1;
	else next_state = S0;

	fsm_state = 5'd0;

	end
	
	S1:
	begin
		fsm_state = 5'd1;
		
		if (!reset) next_state = S0;
		else next_state = S2;
	end
	
	S2:
	begin
		fsm_state = 5'd2;
		
		if (!reset) next_state = S0;
		else next_state = S3;
	end
	
	S3:
	begin
		fsm_state = 5'd3;
		
		if (!reset) next_state = S0;
		else next_state = S4;		
	end
	
	S4:
	begin
		fsm_state = 5'd4;
	
		if (!reset) next_state = S0;
		else next_state = S5;
	end	
	
	S5:
	begin
		fsm_state = 5'd5;
			
		if (!reset) next_state = S0;
		else if (graphData1_Zero) 
		next_state = S6;
		else next_state = S5;
	end
	
	S6:
	begin
		fsm_state = 5'd6;
	
		if (!reset) next_state = S0;
		else next_state = S7;
	end
	
	S7:
	begin
		fsm_state = 5'd7;
	  
		if (!reset) next_state = S0;
		else next_state = S8;
	end
	
	S8:
	begin
		fsm_state = 5'd8;
	  
		if (!reset) next_state = S0;
		else next_state = S9;
	end
	
	S9:
	begin
		fsm_state = 5'd9;
	  
		if (!reset) next_state = S0;
		else next_state = S10;
	end
	
	S10:
	begin
		fsm_state = 5'd10;
		
		if (!reset) next_state = S0;	
		else if ( iterDone == 1'b1 )
		next_state = S11;
		else if ( goS8 == 1'b1 )
		next_state = S8;
		else next_state = S10;
	end
	
	S11:
	begin
		fsm_state = 5'd11;
	
		if (!reset) next_state = S0;	
		else if ( iterStop == 1'b1 )
		next_state = S12;
		else if ( negCycle == 1'b1 )
		next_state = S13;
		else next_state = S6;
	end	
	
	S12:
	begin
		fsm_state = 5'd12;
	
	if (!reset) next_state = S0;
	else next_state = S14;
		
	end
	
	S13:
	begin
		fsm_state = 5'd13;
		
	if (!reset) next_state = S0;
	else next_state = S20;
	end
	
	S14:
	begin
		fsm_state = 5'd14;
		
	if (!reset) next_state = S0;
	else next_state = S15;
	end
	
	S15:
	begin
		fsm_state = 5'd15;
		
	if (!reset) next_state = S0;
	else next_state = S16;
	end
	
	S16:
	begin
		fsm_state = 5'd16;
		
	if (!reset) next_state = S0;
	else next_state = S17;
	end
	
	S17:
	begin
		fsm_state = 5'd17;
		
	if (!reset) next_state = S0;
	else if ( outputWriteDone == 1 )
	next_state = S19;
	else next_state = S18;
	end
	
	S18:
	begin
		fsm_state = 5'd18;
		
	if (!reset) next_state = S0;
	else next_state = S17;
	end
	
	S19:
	begin
		fsm_state = 5'd19;
		
	if (!reset) next_state = S0;
	else if ( zeroFlag == 1 )
	next_state = S20;
	else next_state = S1;	
	end
	
	S20:
	begin

		fsm_state = 5'd20;
	
	if (!reset) next_state = S0;
	else next_state = S20;
	end
	
	default:
	begin

	next_state = S0;

	fsm_state = 5'd0;

	end	
endcase

end

endmodule

		
		
			

	
	
