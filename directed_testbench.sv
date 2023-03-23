import float_type::*;
module tb;
  bit [31:0] I;
  bit [23:0]Out_mantissa;
  bit [31:0]a,b;
  bit [47:0]result_new;
  bit [7:0] Out_exponent,exponent;
  bit sign,Out_sign;
  type_of_float result_str;
   type_of_float form;
  if_normal n(I,Out_mantissa,Out_exponent,Out_sign,form);
  product p(a,b,result_new,exponent,sign,result_str);
   task display();
     if(result_str != VALID) begin
       if((result_str == positive_infinity)|| (result_str==negative_infinity)||(result_str==NaN))begin
         $display("One of the input is %s", result_str); end
       
       if ((result_str==OVERFLOW)||(result_str==UNDERFLOW)) $display(" Float Multiplication: %s", result_str); end
       else
    $display("m1=%b m2=%b mul_result=%b result_new=%b c=%0d %0d %b exp_array=%b additional_exponent=%0d result=%b exponent=%b sign=%b sum_exp=%b float_t1=%s",p.a_new,p.b_new,p.mul_result,result_new,p.c,p.point_count,p.temp, p.exp_array,p.additional_exponent,p.result,exponent,sign,p.sum_exp,p.float_t1.name);
    endtask
  initial begin
    a = 32'b1_01111101_00110011001100110011010; 
    b = 32'b0_10000111_11110100010000000000000;#10;
    display();
    
    a = 32'b1_01111101_00000000000000000000000; 
    b = 32'b0_10000111_00000000000000000000000;#10;
      display();
    
    a = 32'b1_01111101_11111111111111111111111; 
    b = 32'b0_10000111_11111111111111111111111;#10;
     display();
    
    a = 32'b1_01111101_11111111111111111111111; 
    b = 32'b0_10000111_00000000000000000000000;#10;
     display();
    
    a = 32'b1_11111110_11111111111111111111111; 
    b = 32'b0_11111111_00000000000000000000000;#10;
     display();
    
    a = 32'b1_00000001_11111111111111111111111; 
    b = 32'b0_00000001_00000000000000000000000;#10;
      display();
    
    a = 32'b1_11111111_11111111111111111111111; 
    b = 32'b0_00000001_00000000000000000000000;#10;
      display();
    
     a = 32'b1_00000000_11111111111111111111111; 
    b = 32'b0_00000001_00000000000000000000000;#10;
      display();
    
    a = 32'b1_00000000_00110011001100110011010; 
    b = 32'b0_01111111_11110100010000000000000;#10;
    display();
    
    a = 32'b1_11111110_00110011001100110011010; 
    b = 32'b0_11111110_11110100010000000000000;#10;
    display();
    
  end
endmodule
