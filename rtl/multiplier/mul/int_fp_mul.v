module int_fp_mul (mode,a,b,c,error);

    input mode;
    input [15:0] a,b;
    output [15:0] c;
    output error;

    wire [15:0] c_tmp;
    wire c_sign,a_zero,b_zero;
    wire [4:0] sum_exponent, biased_sum_exponent;
    wire [15:0] multiplier_input1,multiplier_input2;

    wire [31:0] multiplier_output;
    wire [14:0] normalized_out;
    wire [21:0] mantissa_prod;
    wire c1,c2;
    assign overflow = c1;
    assign underflow = (sum_exponent[4] == 1'b0) ? 1'b1 : 1'b0;

    assign a_zero = ~(|a);
    assign b_zero = ~(|b);
    assign c_sign = a[15] ^ b[15];
    assign multiplier_input1 = mode ? {5'b0,1'b1,a[9:0]} : ((a[7]==1'b0) ? {9'b0,a[6:0]} : {9'b0,~a[6:0]+1'b1});
    assign multiplier_input2 = mode ? {5'b0,1'b1,b[9:0]} : ((b[7]==1'b0) ? {9'b0,b[6:0]} : {9'b0,~b[6:0]+1'b1});
    assign mantissa_prod = multiplier_output[21:0];
    assign c_tmp = mode ? ((a_zero | b_zero) ? 16'b0 : {c_sign,normalized_out}) : ((a[7]^b[7] == 1'b0) ? multiplier_output[15:0] : {1'b1,~multiplier_output[14:0]+1'b1});
    // error handle
    assign c = (error) ? (underflow ? {c_sign,15'b0} : {c_sign,15'b1}) : c_tmp;
    assign error = overflow | underflow; 
    mul16x16 u1(multiplier_input1,multiplier_input2,multiplier_output);
    
    cla_nbit #(.n(5)) u2(a[14:10],b[14:10],1'b0,sum_exponent,c1); // add exponent
    cla_nbit #(.n(5)) u3(sum_exponent, 5'b10001,1'b0,biased_sum_exponent,c2); // minus bias
    mul_normalizer u4(biased_sum_exponent,mantissa_prod,normalized_out);

endmodule
