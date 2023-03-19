class transactiona;
  rand bit[31:0] m;
  constraint numa {m inside {[32'b0_00000101_0000_0000_0000_0000_0000_000:32'b0_01100101_1111_1111_1111_1111_1111_111]};}
endclass
class transactionb;
  rand bit[31:0] n;
  constraint numb {n inside {[32'b0_00110001_0000_0000_0000_0000_0000_000:32'b0_01001101_1111_1111_1111_1111_1111_111]};}
endclass

import float_type::*;
module top;
  bit [31:0]a,b;
  bit [31:0] fp_result,rp;
  bit U,O,N,U_test,O_test;
  shortreal r_a,r_b,r_product;
//  real r_product_real;
  
  type_of_float result_str;

  transactiona tra;
  transactionb trb;

  // Instantiate the product module and connect its inputs and outputs to the
  // corresponding variables in the top-level module.
  product p(.a(a), .b(b), .fp_result(fp_result), .U(U), .O(O),.N(N));

  initial begin 
    repeat(1000) begin
      // Randomize the transactions and assign the randomized values to a and b.
      tra = new;
      trb = new;
      void'(tra.randomize());
      void'(trb.randomize());
      a = tra.m;
      b = trb.n;
      #10;
      r_a = $bitstoshortreal(a);
      r_b = $bitstoshortreal(b);
      r_product = r_a * r_b;
      rp=$shortrealtobits(r_product);
      if(!(rp==(fp_result) || (U==1) || (N==1)))
           //|| (rp==(fp_result)+1'b1) || (rp==(fp_result)-1'b1)|| (U==1))) 
           begin
        $display("@%t a=%b b=%b fp_result=%b O=%b U=%b",$time, a, b, fp_result,O,U);
        $display("@%t a=%g b=%g fp_result=%b r_product=%g",$time, r_a, r_b, rp,r_product);
        $display("-----------------------------------"); end
      else $display("-------Passed!----------"); 
    end
  end
endmodule
