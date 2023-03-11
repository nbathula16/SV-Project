module round(input logic [47:0]product, output logic [22:0] mantissa);
logic guard,round,sticky;
logic [22:0] mantissa_copy;

	assign guard = product[23];
	assign round = product[24];
	assign sticky = |(product[22:0]);
	assign mantissa_copy = product[47:25];
  
    always_comb
    begin
	if(guard == 0)
	mantissa = mantissa_copy;
	else if (guard ==1 && round == 0 && sticky == 0)
		begin
			if(mantissa_copy[0] == 1)
			mantissa = mantissa_copy+1;
		else 
			mantissa = mantissa_copy;
		end
	else if (guard ==1 && (round|sticky) == 1)
		mantissa = mantissa_copy;
    end
	
endmodule
