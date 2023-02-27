module tb;
  logic [23:0] a,b;
  bit [47:0] result;
  binary_24bitmultiplier m1(a,b,result);
  initial begin
    a=24'b111111111111111111111111;
    b=24'b111111111111111111111111;  #1;
   for (int i = 0; i < 24; i++) begin
     $display("%p result=%b",m1.products[i],result);  
  end
end
endmodule
