# SV-Project
32-bit Single Precision Floating point Multiplication which takes in two 32-bit floating point numbers as inputs and generates a output if the multiplication is valid i.e, if the inputs and the product produced is in the range of 32-bit floating point numbers. The model flags Overflow , Underflow or NaN whenever the inputs trigger such conditions to occur. 
A floating point number consists of 32-bits divided into three parts, bit 31 as sign bit representing positive float if the sign bit is 0 and negative float points when the bit is 1. The exponent bits range from [30:23]. The exponent range is biased i.e, the exponent represented is equal to the actual exponent count + 127. If the exponent field is 8'b0, the float point represented is a denormalized number which implies that 0.mantissa multiplied to the 2 power -126. The bits [22:0] represent the mantissa. 
Here are few examples:
32'b0_00001010_0000_1111_1010_1010_1111_000 = (2^-117)x 1.00001111101010101111000 Normalized
32'b0_00000000_0000_1111_1010_1010_1111_000 = (2^-126)x 0.00001111101010101111000 Denormalized 
32'b1_11111111_0000_0000_0000_0000_0000_000 = Negative Infinity
32'b0_11111111_0000_0000_0000_0000_0000_000 = Positive Infinity
32'b1_11111111_0000_0110_0000_0000_0000_000 = NaN
When one of the inputs are positive infinity, negative infinity or NaN we are directly declaring them as invalid inputs. If this check passes, the inputs pass through a 24-bit multiplier module(23 mantissa bits[22:0] and the 23rd bit the MSB is 1 if the number is normalized else, zero) where the product is stored row wise shifting by 1 bit to the left in the consequent rows in a 2-D array. Later after all the bits are multiplied, the coloumns are added with a carry propagating through. 48-bit product is obtained by multiplying two 24 bit numbers.
