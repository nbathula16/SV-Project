module if_normal(input bit [31:0] I,
                 output bit [23:0]Out);
  bit sign;
  bit [7:0] exponent;
  bit [22:0] mantissa;

  typedef enum {normalized,denormalized,positive_infinity,negative_infinity,NaN} type_of_float;
  type_of_float form;

    assign sign = I[31];
    assign exponent = I[30:23];
    assign mantissa = I[22:0];
    always_comb begin
    if (exponent=='0) begin
      form = denormalized;
      Out = {1'b0,mantissa}; end
    else if (exponent == '1) begin
      if(mantissa == '0) begin
        if(sign == '0) form = positive_infinity;
        if(sign == '1) form = negative_infinity;
      end
      else form = NaN;
    end
    else  begin 
      form = normalized;
      Out = {1'b1,mantissa}; end
    end 
endmodule

module product(input bit [31:0]a,b,output bit[47:0]result);
  bit [23:0]a_new,b_new;
  bit [47:0]mul_result,temp,exp_array,result_new;
  int count1,count2,point_count,c=0,additional_exponent;
  if_normal m1(a,a_new);
  if_normal m2(b,b_new);
  binary_24bitmultiplier m3(a_new,b_new,mul_result);
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
      if (mul_result=='0) 
     additional_exponent = 0;
    else begin
      for(int l=0; l<48; l++) begin
       additional_exponent = l; 
        if(exp_array[l] == 1)break; 
         end
      end
       result_new= mul_result << additional_exponent;
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
    if(a[22:0] == '0 && b[22:0]=='0) result='0;
    else begin
    for (int k=0; k<48;k++) begin
    for(int l=0;l<24;l++) begin
      sum = sum + products [l][47-k];
    end
      result[k]=sum[0];
      sum = sum[5:1];
    end end end
endmodule
