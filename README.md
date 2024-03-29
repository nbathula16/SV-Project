# SV-Project
Specification: 32-bit Single Precision Floating point Multiplication which takes in two 32-bit floating point numbers as inputs and generates a output if the multiplication is valid i.e, if the inputs and the product produced is in the range of 32-bit floating point numbers. The model flags Overflow , Underflow or NaN whenever the inputs trigger such conditions to occur. 
What is a floating point number?
A floating point number consists of 32-bits divided into three parts, bit 31 as sign bit representing positive float if the sign bit is 0 and negative float points when the bit is 1. The exponent bits range from [30:23]. The exponent range is biased i.e, the exponent represented is equal to the actual exponent count + 127. If the exponent field is 8'b0, the float point represented is a denormalized number which implies that 0.mantissa multiplied to the 2 power -126. The bits [22:0] represent the mantissa. 
Here are few examples:
32'b0_00001010_0000_1111_1010_1010_1111_000 = (2^-117)x 1.00001111101010101111000 Normalized
32'b0_00000000_0000_1111_1010_1010_1111_000 = (2^-126)x 0.00001111101010101111000 Denormalized 
32'b1_11111111_0000_0000_0000_0000_0000_000 = Negative Infinity
32'b0_11111111_0000_0000_0000_0000_0000_000 = Positive Infinity
32'b1_11111111_0000_0110_0000_0000_0000_000 = NaN
Multiplication:
When one of the inputs are positive infinity, negative infinity or NaN we are directly declaring them as invalid inputs. If this check passes, the inputs pass through a 24-bit multiplier module(23 mantissa bits[22:0] and the 23rd bit the MSB is 1 if the number is normalized else, zero) where the product is stored row wise shifting by 1 bit to the left in the consequent rows in a 2-D array. Later after all the bits are multiplied, the coloumns are added with a carry propagating through. 48-bit product is obtained by multiplying two 24 bit numbers.
Normalize:
The 48-bit multiplier output is now normalized based on the [47:46] bits of the product. The following are the possibilities for the most signficant 2 bits:
2'b00 - This case is obtained when two denormalized numbers are multiplied. Here we need to perform a left shift from the 45th bit till the first one is obtained, the right sided bits to the one will go to the new vector which is concatenated with zeroes in the least significant position to make it a 48-bit value. The number of shift is stored in an another variable say denormalized_shift which further is used to subtract from the sum of exponents while calculating the exponent field.
2'b01 - This indicates that the value obtained is normalized without any carry, the 48-bit normalized product would be {[45:0],2'b00}.
2'b10 and 2'b11 - This indicates that the value obtained is normalized with an additional carry 1 which is further used to calculate the exponent. So, the 48-bit output from here is, {[46:0],1'b0}.
Rounding: 
The 48-bit output is now passed through a rounding module where the 48-bit value is rounded to a 23-bit mantissa with round_carry either 0 or 1. The 22nd bit is the sticky bit, the 23rd is round bit, 24th is guard bit and the 25th is LSB. If {G,R,S}=3'b000 or 3'b001 or 3'b010 or 3'b011 the rounding action would be truncating the LSB bits. If the {G,R,S}=3'b100, round to even which means roundup when LSB=1 and truncate if LSB is 0. And for the remaining combinations of {G,R,S} round up and get the 23-bit mantissa.
Exponent filed:
The exponent filed is calculated by adding the exponent field by keeping a track on bias, subtracting the denorm-shift if applicable, adding the round_carry and additional_carry generated from the above processes. Now, if the obtained exponent is -126 then, the exponent filed would be 8'b0, if the exponent is >254 then the overflow flag would raise, if the exponent is <-126 then the underflow flag would get asserted and when the exponent is 8'b11111111 then, the result would become NaN. Note that the comparision to produce flags is done after biasing the exponent.
Sign bit: sign of input 1 xor with the input 2. All of the bits are concatenated {sign,exponent,mantissa}
Verification approach: The model has been successful when running through directed testcases. Self-checking is implemented by considering shortreal type variables and driving them with the same stimulus that is given to the inputs,multiplication is perform using * the outputs from the both multiplications are compared and checked. 
Classes are used to generate random stimulus using constrain randomization method to both the inputs. The result obtained is considered to be the coverpoint which is observed using the covergroup. Bins are created accordingly and the coverage is observed through generatinga report. 
