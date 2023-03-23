module product(input logic [31:0]a,b,
               output bit [31:0] fp_result,
               output bit U,O,N);
  
  bit[47:0]result_mantissa,mul_result,multiplier_result;
  bit [7:0]exponent,a_exp,b_exp;
  bit sign,additional_exponent,round_carry,a_sign,b_sign;
  bit [23:0]a_new,b_new;
  bit [22:0]mantissa;
  bit [8:0]sum_exp;
  bit [1:0]carry;
  bit [5:0]denorm_shift;
  bit [1:0]state;
  int count,i,shift;
  type_of_float result_str, float_a, float_b; 
  if_normal m1(a,a_new,a_exp,a_sign,float_a);
  if_normal m2(b,b_new,b_exp,b_sign,float_b);
  round m3(result_mantissa, mantissa,round_carry);
  binary_24bitmultiplier m5(a_new,b_new,mul_result);
  assign state= mul_result[47:46];
 
  always_comb begin//normalizing the multiplication result
    unique case(state)
      2'b00: begin 
        if(a==32'b0 || b==32'b0) begin 
          result_mantissa=48'b0; 
          additional_exponent=0;
          denorm_shift= 0; end
        else begin
        for(i=47; i>=0; i--) begin
        count = i;
        shift = 48-count;
          if(mul_result[i]==1'b1) break; 
       end
        result_mantissa={mul_result<<shift};
        denorm_shift= 47-count-1; 
        end end
      2'b01: begin
            result_mantissa={mul_result[45:0],2'b00};
        additional_exponent=0; 
      denorm_shift= 0;end
      2'b10: begin 
              result_mantissa={mul_result[46:0],1'b0};
        additional_exponent=1;
      denorm_shift= 0;
      end
      2'b11: begin
       result_mantissa={mul_result[46:0],1'b0};
        additional_exponent=1;
      denorm_shift= 0;
      end
    endcase
  end
  
  always_comb
    begin:Compute_final_result
      if (a=='0 || b=='0) begin //a and b inputs zero
        result_str= ZERO;  U=0;O=0; 
		fp_result=32'b0;
		end
      
     else if ((float_a == positive_infinity) || (float_a ==negative_infinity) ||(float_a == NaN)) result_str = float_a; //Checking the float-type of input 1
   
      else if ((float_b == positive_infinity) || (float_b ==negative_infinity) ||(float_b == NaN)) result_str = float_b; //Checking the float-type of input2
      
      else begin
      
        if ((a_exp=='0) && (b_exp=='0))begin //a and b denormalized
          exponent=(-126+-126+round_carry+additional_exponent-denorm_shift+127);
      result_str = UNDERFLOW;
        U=1;O=0; end
      
        else if ((a_exp=='0) && (b_exp!=='0)) begin //a-denormalized b-normalized
          {carry,exponent}= (-126+b_exp+round_carry+additional_exponent-denorm_shift);
      if(exponent=='1 && mantissa!='1)  begin 
       result_str=NaN; U=0;O=0;N=1; end
          else if((-126+b_exp-127+round_carry+additional_exponent-denorm_shift+127) < (1)) begin
          result_str= UNDERFLOW; U=1;O=0;end
          else if((-126+b_exp-127+round_carry+additional_exponent-denorm_shift+126) == (0)) begin
          exponent='0; U=0;O=0; end
          else if((-126+b_exp-127+round_carry+additional_exponent-denorm_shift+127) > (254)) begin
            result_str= OVERFLOW; U=0;O=1;end 
       else begin
          result_str = VALID;  
     U=0;O=0; end
      end
      
        else if ((a_exp!=='0) && (b_exp=='0)) //a-normalized b-denormalized
        begin
          {carry,exponent}= {-126+a_exp+round_carry+additional_exponent-denorm_shift};
          if(exponent=='1 && mantissa!='1)  begin 
       result_str=NaN; U=0;O=0;N=1; end
          else if((-126+a_exp-127+round_carry+additional_exponent-denorm_shift+127) < (1)) begin
          result_str= UNDERFLOW; U=1;O=0;end
          else if((-126+a_exp-127+round_carry+additional_exponent-denorm_shift+126) == (0)) begin
          exponent='0; U=0;O=0; end
          else if((-126+a_exp-127+round_carry+additional_exponent-denorm_shift+127)>(254)) begin
            result_str= OVERFLOW; U=0;O=1;end
        else begin  
          result_str = VALID;  
     U=0;O=0; end
      end 
      
    else begin //a and b normalized
    {carry,exponent}= {a_exp+b_exp+round_carry+additional_exponent-127};
      
      if(exponent=='1 && mantissa!=='1)  begin 
       result_str=NaN; U=0;O=0;N=1; end
      
      else if({b_exp+a_exp+round_carry+additional_exponent-127} < 1) begin
          result_str= UNDERFLOW; U=1;O=0;end
      
      else if({b_exp-127+a_exp+round_carry+additional_exponent+126} == 0)     begin
          exponent='0; U=0;O=0; end
      else if(carry>0)begin
            result_str= OVERFLOW; U=0;O=1;end
        else begin  
          result_str = VALID;  
     U=0;O=0; end
      end 
      end
      sum_exp= {carry,exponent};  
      sign = a_sign ^ b_sign;
      if(result_str==ZERO)  fp_result ={sign,31'b0};
      else  fp_result = {(a_sign ^ b_sign),exponent,mantissa};
    
  end:Compute_final_result
  
    always_comb
      begin
	  // a_zero: assert($countones(a)||$countones(b)==(!(result_str == ZERO)))
          // else $info("Wrong Zero,%b,%b,%b",a,b,fp_result);
        a_inputs:  assert(!$isunknown(b))
          else  $info("Unknown inputs");
        // a_overflow: assert((U||N)||(carry ~^ O))
        // else $info("Overflow Flag Error");
//         a_underflow: assert((result_str == VALID)||(U&&~O&&~N))
//           else $error("Underflow Flag Error");
        
        end
		
		
endmodule
 
