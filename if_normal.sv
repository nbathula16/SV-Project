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
