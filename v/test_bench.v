//Testfixture for Input SRAM

module test_bench;

reg clock, reset, start;
integer i, output_file;

initial
begin
	$readmemh("input_secret1.mem", bellman.input_sram.Register);	
	$readmemh("Graph_secret1.mem", bellman.graph_sram.Register);
	#0 reset = 0;
	#0 clock = 0;
	#8 reset = 1;
	#4 start = 1'b1;
	
	wait( bellman.main.control.current_state == 20 );
	#20
	$display("Execution Finish Time = %t ns\n", $time);

        output_file = $fopen("Output.dat","w");
		
	if ( bellman.main.data.outputWrite_Addr == 14'h0 )
	begin
		$fwrite(output_file,"Negative cycle exists");
	end
	
else 
begin
	for (i = 0; i < bellman.main.data.outputWrite_Addr+1; i = i + 1)
	begin
	if( bellman.output_sram.Register[i] == 16'hFFFF )
		$fwrite(output_file,"FFFF\n");
	else
		$fwrite(output_file,"%d\n", bellman.output_sram.Register[i]);
	end
end

	$fclose(output_file);

	$writememh("Out_secret1.mem", bellman.output_sram.Register);
	#10 $finish;
end	

always #5 clock = ~clock; 

top_with_mem bellman ( .clock(clock), .reset(reset), .start(start) );

endmodule
