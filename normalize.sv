package float_type;
typedef enum {normalized,denormalized,positive_infinity,negative_infinity,NaN,VALID,OVERFLOW,UNDERFLOW} type_of_float;
endpackage

import float_type::*;

module if_normal(input bit [31:0] I,
                 output bit [23:0]Out_mantissa,output bit [7:0]Out_exponent,output bit Out_sign, type_of_float form);
  bit [22:0] mantissa;

    assign Out_sign = I[31];
  assign Out_exponent = I[30:23];
    assign mantissa = I[22:0];
    always_comb begin
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
    end 
endmodule

module product(input bit [31:0]a,b,output bit[47:0]result_new,output bit [7:0]exponent,output bit sign,type_of_float result_str);
  bit [23:0]a_new,b_new,tempx;
  bit [7:0] a_exp,b_exp;
  bit [8:0]sum_exp;
  bit a_sign,b_sign,sign1;
  bit [47:0]mul_result,temp,exp_array,result;
  int count1,count2,point_count,c=0,additional_exponent;
  bit carry=0;
    type_of_float float_t1, float_t2,float_t;
  if_normal m1(a,a_new,a_exp,a_sign,float_t1);
  if_normal m2(b,b_new,b_exp,b_sign,float_t2);
 // if_normal m3(result_new[31:0],tempx,exponent,sign1,float_t);
  binary_24bitmultiplier m4(a_new,b_new,mul_result);
  task point(input bit [22:0]I,output int count);
    begin

      for(int i=0; i<22; i++) begin
        count = i;
        if(I[i]==1) break; 
      end
 
    end
  endtask
    always_comb begin
      point(a_new[22:0],count1);
      point(b_new[22:0],count2);
      point_count = 46 - (count1 + count2);
      
      for(int l=0; l<48; l++) begin
       c = l; 
        if(mul_result[l] == 1)break; 
         end
     
       temp = mul_result >> c;
      result = temp << (48-point_count);
      exp_array = temp >> point_count;
      if (mul_result=='0 || exp_array=='0) 
     additional_exponent = 0;
    else begin
      for(int l=47; l>=0; l--) begin
       additional_exponent = l; 
        if(exp_array[l] == 1)break; 
         end
      end
       result_new= mul_result << additional_exponent;
      end
  always_comb begin
    {carry,exponent}= {a_exp+b_exp+additional_exponent-127};
    sum_exp= {carry,exponent};
    
    if ((float_t1 == positive_infinity) || (float_t1 ==negative_infinity) ||(float_t1 == NaN)) result_str = float_t1;
   
    else if ((float_t2 == positive_infinity) || (float_t2 ==negative_infinity) ||(float_t2 == NaN)) result_str = float_t2;
    
    else if (a_exp+b_exp+additional_exponent < 127)
      result_str=UNDERFLOW;
     else if (carry==1)
      result_str=OVERFLOW;
    else result_str=VALID;
    sign = a_sign ^ b_sign;
  end  
endmodule
  
    

module binary_24bitmultiplier (a,b,result);
  input  [23:0] a;
  input [23:0] b;
  output bit [47:0] result;
  bit products [24][48];
  bit [5:0]sum;
  int l;
  always_comb begin
   for (int i=0; i < 24; i++) begin
    for(int j=0;j<24;j++) begin
       products[i][47-j-i] = (a[j] & b[i]);
     end
 end
  end 
  always_comb begin
    if(a[22:0] == '0 || b[22:0]=='0) result='0;
    else begin
    for (int k=0; k<48;k++) begin
    for(int l=0;l<24;l++) begin
      sum = sum + products [l][47-k];
    end
      result[k]=sum[0];
      sum = sum[5:1];
    end end end
endmodule
