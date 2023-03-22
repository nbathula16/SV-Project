class transactiona;
  rand bit[31:0] m;
  constraint denorm_and_norm{m[30:23] inside {[8'b00000000:8'b11111110]};}
  constraint infinity{m[30:23]!='1 && m[22:0]!='0; }
  constraint NAN{m[30:23]!='1;}
endclass

class transactionb;
  rand bit[31:0] n;
  constraint denorm{n[30:23]!='0;}
  constraint infinity{n[30:23]!='1 && n[22:0]!='0; }
  constraint NAN{n[30:23]!='1;}
endclass

class coverage_module;
  bit [31:0]a;
 // bit [31:0]b;
  covergroup a_type;
    coverpoint a {
      bins denorm={32'b?_0000_0000_????_????_????_????_????_???};
      bins norm={[32'b?_0000_0001_????_????_????_????_????_???:32'b?_1111_1110_????_????_????_????_????_???]};
      bins zero={32'b0};
    }
  endgroup
  function new();
    a_type=new;
  endfunction
endclass     

import float_type::*;

module top;
  bit [31:0]a,b;
  bit [31:0] fp_result,rp;
  bit U,O,N,U_test,O_test;
  shortreal r_a,r_b,r_product;
  int failed;
  bit[47:0]result;
//  real r_product_real;
  
  type_of_float result_str;

  transactiona tra;
  transactionb trb;
  coverage_module cg;

  product p(.a(a), .b(b), .fp_result(fp_result), .U(U), .O(O),.N(N));
  binary_24bitmultiplier mul(.a(p.a_new),.b(p.b_new),.result(result));

  initial begin 
    repeat(100) begin
      tra = new();
      trb = new();
      cg = new();
      while(cg.a_type.get_coverage() < 100) begin
        assert(tra.randomize());
        assert(trb.randomize());
        cg.a_type.sample();
        a = tra.m;
        b = trb.n;
        #10;
        r_a = $bitstoshortreal(a);
        r_b = $bitstoshortreal(b);
        r_product = r_a * r_b;
        rp=$shortrealtobits(r_product);
        if (!(rp==(fp_result) || (U==1) || (N==1) || (O==1))) begin
          $display("@%t a=%b b=%b fp_result=%b O=%b U=%b rcary=%b addexp=%b carry=%b result_mantissa=%b result=%b a_new=%b b_new=%b mul_result=%b multiplier_result=%b count=%0d",$time, a, b, fp_result,O,U,p.round_carry,p.additional_exponent,p.carry,p.result_mantissa,result,p.a_new,p.b_new,p.mul_result,p.multiplier_result,p.count);
          $display("@%t a=%g b=%g fp_result=%b r_product=%g",$time, r_a, r_b, rp,r_product);
          $display("-----------------------------------"); 
          failed=failed+1;
        end
      end
    end
    $display("Coverage now at 100");
    if (failed==0) begin
      $display("-------Passed!----------"); 
    end end
endmodule
