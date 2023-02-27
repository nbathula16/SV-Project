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
    for (int k=0; k<48;k++) begin
    for(int l=0;l<24;l++) begin
      sum= sum+ products [l][47-k];
    end
      result[k]=sum[0];
      sum= sum[5:1];
  end end
endmodule
