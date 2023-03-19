package float_type;
typedef enum {normalized,denormalized,positive_infinity,negative_infinity,NaN,VALID,OVERFLOW,UNDERFLOW,ZERO} type_of_float;
endpackage

import float_type::*;

module if_normal(input bit [31:0] I,
                 output bit [23:0]Out_mantissa,
                 output bit [7:0]Out_exponent,
                 output bit Out_sign, type_of_float form);
  bit [22:0] mantissa;

    assign Out_sign = I[31];
	assign Out_exponent = I[30:23];
    assign mantissa = I[22:0];
  
    always_comb
      begin:floattype
      if (Out_exponent=='0) begin
      form = denormalized;
      Out_mantissa = {1'b0,mantissa}; end
      else if (Out_exponent == '1) begin
      if(mantissa == '0) begin
        if(Out_sign == '0) form = positive_infinity;
        if(Out_sign == '1) form = negative_infinity;
      end
      else form = NaN;
    end
    else  begin 
      form = normalized;
      Out_mantissa = {1'b1,mantissa}; end
    end :floattype
endmodule

module product(input logic [31:0]a,b,
               output bit [31:0] fp_result,
               output bit U,O,N);
  
  bit[47:0]result_mantissa,mul_result;
  bit [7:0]exponent,a_exp,b_exp;
  bit sign,additional_exponent,round_carry,a_sign,b_sign;
  bit [23:0]a_new,b_new;
  bit [22:0]mantissa;
  bit [8:0]sum_exp;
  bit [1:0]carry;
  
  type_of_float result_str, float_a, float_b; 
  if_normal m1(a,a_new,a_exp,a_sign,float_a);
  if_normal m2(b,b_new,b_exp,b_sign,float_b);
  round m3(result_mantissa, mantissa,round_carry);
  binary_24bitmultiplier m5(a_new,b_new,mul_result);
  
    always_comb 
      begin:compute_mantissa
      if (mul_result[47:46]==2'b00) begin
        result_mantissa= {mul_result[45:0],2'b00};
        additional_exponent=0; end
      if (mul_result[47:46]==2'b01) begin
        result_mantissa={mul_result[45:0],2'b00};
        additional_exponent=0; end
      if (mul_result[47:46]==2'b10) begin
       result_mantissa={mul_result[46:0],1'b0};
        additional_exponent=1; end
      if (mul_result[47:46]==2'b11) begin
       result_mantissa={mul_result[46:0],1'b0};
        additional_exponent=1; end
      end:compute_mantissa
  
  always_comb
    begin:Compute_final_result
      
      if (a=='0 || b=='0) begin //a and b inputs zero
        result_str= ZERO;  U=0;O=0; end
      
     else if ((float_a == positive_infinity) || (float_a ==negative_infinity) ||(float_a == NaN)) result_str = float_a; //Checking the float-type of input 1
   
      else if ((float_b == positive_infinity) || (float_b ==negative_infinity) ||(float_b == NaN)) result_str = float_b; //Checking the float-type of input2
      
      else begin
      
        if ((a_exp=='0) && (b_exp=='0))begin //a and b denormalized
      exponent={-126+-126+round_carry+additional_exponent+127};
      result_str = UNDERFLOW;
        U=1;O=0; end
      
        else if ((a_exp=='0) && (b_exp!=='0)) begin //a-denormalized b-normalized
    {carry,exponent}= {-126+b_exp+round_carry+additional_exponent};
      if(exponent=='1 && mantissa!='1)  begin 
       result_str=NaN; U=0;O=0;N=1; end
          else if({-126+b_exp-127+round_carry+additional_exponent+127} < 1) begin
          result_str= UNDERFLOW; U=1;O=0;end
          else if({-126+b_exp-127+round_carry+additional_exponent+126} == 0) begin
          exponent='0; U=0;O=0; end
       else if({-126+b_exp-127+round_carry+additional_exponent+127} > 254) begin
            result_str= OVERFLOW; U=0;O=1;end 
       else begin
          result_str = VALID;  
     U=0;O=0; end
      end
      
        else if ((a_exp!=='0) && (b_exp=='0)) //a-normalized b-denormalized
        begin
         {carry,exponent}= {-126+a_exp+round_carry+additional_exponent};
          if(exponent=='1 && mantissa!='1)  begin 
       result_str=NaN; U=0;O=0;N=1; end
          else if({-126+a_exp-127+round_carry+additional_exponent+127} < 1) begin
          result_str= UNDERFLOW; U=1;O=0;end
          else if({-126+a_exp-127+round_carry+additional_exponent+126} == 0) begin
          exponent='0; U=0;O=0; end
          else if({-126+a_exp-127+round_carry+additional_exponent+127}>254) begin
            result_str= OVERFLOW; U=0;O=1;end
        else begin  
          result_str = VALID;  
     U=0;O=0; end
      end 
      
    else begin //a and b normalized
    {carry,exponent}= {a_exp+b_exp+round_carry+additional_exponent-127};
      
      if(exponent=='1 && mantissa!=='1)  begin 
       result_str=NaN; U=0;O=0;N=1; end
      
      else if({b_exp+a_exp+round_carry+additional_exponent-127+127} < 128) begin
          result_str= UNDERFLOW; U=1;O=0;end
      
      else if({b_exp-127+a_exp+round_carry+additional_exponent+126} == 0)     begin
          exponent='0; U=0;O=0; end
      else if(carry==1)begin
            result_str= OVERFLOW; U=0;O=1;end
        else begin  
          result_str = VALID;  
     U=0;O=0; end
      end 
      end
      
     sum_exp= {carry,exponent};  
     sign = a_sign ^ b_sign; //sign bit
     fp_result = {sign,exponent,mantissa};  //final floating point result
    
  end:Compute_final_result
  
    always_comb
      begin: Assertions
        a_inputs:  assert(!$isunknown(b))
          else  $info("Unknown inputs");
      end: Assertions
   
endmodule
 
    

module binary_24bitmultiplier (input [23:0] a,b,
                               output bit [47:0]result);
  bit products [24][48];
  bit [5:0]sum;
  
  always_comb 
    begin:rowmultiplication
   for (int i=0; i < 24; i++) begin
    for(int j=0;j<24;j++) begin
       products[i][47-j-i] = (a[j] & b[i]);
     end
 end
  end:rowmultiplication
  always_comb 
    begin: sumofcoloumns
    for (int k=0; k<48;k++) begin
    for(int l=0;l<24;l++) begin
      sum = sum + products [l][47-k];
    end
      result[k]=sum[0];
      sum = sum[5:1];
  end
  end:sumofcoloumns
endmodule

module round(input bit [47:0]product, output bit [22:0] mantissa, output bit round_carry);
bit guard,round,sticky;
  bit [23:0] mantissa_copy;

	assign guard = product[24];
	assign round = product[23];
	assign sticky = |(product[22:0]);
	assign mantissa_copy = product[47:25];
  
    always_comb
     begin: rounding
	
    if(guard==1 && round == 1)
	  {round_carry,mantissa} = mantissa_copy+1;
    else if(guard==1 && round == 0 && sticky == 1)
	    {round_carry,mantissa} = mantissa_copy+1;
    else if(guard==1 && round == 0 && sticky == 0)
		if(mantissa_copy[0] == 1)
			{round_carry,mantissa} = mantissa_copy+1;
		else 
			{round_carry,mantissa} = mantissa_copy+1;
	else if(guard ==0)
		 {round_carry,mantissa} = mantissa_copy;
	end
endmodule
