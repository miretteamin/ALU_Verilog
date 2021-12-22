// module param ();
// integer sizze ;
// endmodule
`define REALSIZE 5
//Anding 3 dataflow


module and_3 (output out, input a, input b,  input c);
    wire andout;
    and(andout, a, b);
    and(out, andout, c);
endmodule

//Oring 4 dataflow
module or_4 (output out, input a, input b,  input c, input d);
    wire orout1, orout2;
    or(orout1, a, b);
    or(orout2, c, d);
    or(out, orout1, orout2);
endmodule

//Full Adder
module full_adder(output sum, output carry, input x, input y, input cin);
    wire s1, c1, c2;
    xor(s1, x, y);
    and(c1, x, y);
    xor(sum, s1, cin);
    and(c2, s1, cin);
    or(carry, c1, c2);
endmodule

//4x1 Multiplexer
module mux4x1 (output out, input a,  input b,  input c, input d, input s1, input s0);
    wire ns0, ns1;
    not(ns0,s0);
    not(ns1,s1);

    wire o1, o2, o3, o4;
    and_3 and_30(o1, ns0, ns1, a);
    and_3 and_31(o2, s0, ns1, b);
    and_3 and_32(o3, ns0, s1, c);
    and_3 and_33(o4, s0, s1, d);

    or_4 or_40(out, o1, o2, o3, o4);
endmodule

//2x1 Multiplexer
module mux2x1 (output out, input a,  input b, input s);
    wire ns;
    not(ns,s);

    wire o1, o2;
    and(o1, ns, a);
    and(o2, s, b);

    or(out, o1, o2);
endmodule

//Arithmetic Circuit: 4 operations
module ac (output [size-1:0] out, output carry, input[size-1:0] a, input[size-1:0] b, input[1:0] sel);
    parameter size = `REALSIZE ;
    /* 
                *----Description----*
    * Adding 2 numbers: s1 = 0 , s0 = 0, cin = 0
    * Subtracting 2 numbers: s1 = 0, s0 = 1, cin = 1 
    * Adding 1 to a number: s1 = 1, s0 = 0, cin = 1
    * Subtracting 1 from a number: s1 = 1, s0 = 1, cin = 0

    * So, cin is XOR of s0 and s1  then cin will be 1 in case of adding 1 to number and subtraction 2 numbers
    */

    wire nb[size-1:0],o[size-1:0],c[size:0];
    wire cin;
    xor(cin, sel[0], sel[1]);
    buf (c[0],cin);
    generate
    genvar i;

    // for (i=0; i<size-1; i=i+1)
    // begin
    // end 
    
    

    for (i=0; i<size; i=i+1)
    begin
        not (nb[i],b[i]);
        mux4x1 mu0(o[i], b[i], nb[i], 1'b0, 1'b1, sel[1], sel[0]);
        full_adder full_adder0(out[i], c[i+1], a[i], o[i], c[i]);
            
        // if (!(i + 1 < size - 1)) 
        // begin
        //     end
    end
    buf(carry,c[size]);
    endgenerate
    

   

endmodule

//Logic Circuit 
module lc (output [size-1:0] out, input[size-1:0] a, input[size-1:0] b, input[1:0] sel);

    /* 
                *----Description----*
    * ANDING 2 numbers: s1 = 0, s0 = 0 or s1 = 0, s0 = 1 
    * ORING 2 numbers: s1 = 1, s0 = 0 
    * XORING 2 numbers: s1 = 1, s0 = 1 

    */
    parameter size = `REALSIZE ;

    wire orr[size-1:0];
    wire xorr[size-1:0];
    wire andd[size-1:0];


    generate
    genvar  i;
    for (i=0; i<size; i=i+1)
    begin
        and(andd[i], a[i], b[i]);
        or(orr[i], a[i], b[i]);
        xor(xorr[i], a[i], b[i]);
    mux4x1 mu0(out[i], andd[i], andd[i], orr[i], xorr[i], sel[1], sel[0]);
    end

    // for (i=0; i<size-1; i=i+1)
    //     begin
    //     end

    // for (i=0; i<size-1; i=i+1)
    //     begin
    //     end


    
    // for (i=0; i<size-1; i=i+1)
    // begin
    // end
    endgenerate


    
   

endmodule
////////////////////////////////////////


module ars (output [size-1:0]out, input[size-1:0]in);
    parameter size = `REALSIZE ;
generate
    genvar i;
    for (i=0; i<size-1; i=i+1)
    begin
        buf(out[i],in[i+1]);
        // if (!(i + 1 < size - 1))
        // begin
            
        // end
    end
endgenerate
buf(out[size-1],in[size-1]);
    
endmodule


//arithmetic logic unit
module alu (output [size:0] out , input [size-1:0] a , input [size-1:0] b , input [3:0]sel);
    // wire o0,o1,o2,o3 //ac output
    parameter size = `REALSIZE ;

    wire [size-1:0]acout;
    // wire l0,l1,l2,l3 // lc output
    wire [size-1:0]lcout;
    // wire c1 , c2 , c3 , c4
    wire outcarry;
    // wire cin 
    wire [size-1:0]shiftrig;
    wire [size-1:0]arsout;
    // wire f0,f1,f2,f3
    
    
    
    /* 
    * Logic Circuit output s3=0 / s2 =0       
    *Arithmetic Circuit    s3 =0 /  s2=  1 
    *shift right            s3 = 1 / s2 =  0 Or s3 = 1/  s2 =  1 

    */
    
    lc lc1(lcout,a,b,{sel[1],sel[0]});
    ars ars1(arsout,a);
    ac ac1(acout,outcarry,a,b,{sel[1],sel[0]});
    buf(out[size],outcarry);

    generate
    genvar i;

    for (i=0; i<size; i=i+1)
    begin
        mux4x1 mu0(out[i],lcout[i],acout[i],arsout[i],arsout[i],sel[3],sel[2]);
    end
    endgenerate
    


    
endmodule

module Test_ALU();
// Genvar i
    parameter size = `REALSIZE ;
    reg [size-1:0] A;
    reg [size-1:0] B;
    reg [3  :0] s;

    wire [size:0] out;

    alu alu(out, A, B, s);

    initial 
    begin
        // $monitor($time, " carry=%b,    out = %b%b%b%b     ,    s = %b%b%b%b , a=%b%b%b%b,  b=%b%b%b%b", out[4],out[3], out[2], out[1], out[0], s[3],s[2],s[1],s[0],A[3], A[2], A[1], A[0], B[3], B[2], B[1], B[0]);
        $monitor($time, " carry=%b,    out = %b%b%b%b%b     ,    s = %b%b%b%b , a=%b%b%b%b%b,  b=%b%b%b%b%b",out[5], out[4],out[3], out[2], out[1], out[0], s[3],s[2],s[1],s[0],A[4],A[3], A[2], A[1], A[0],B[4], B[3], B[2], B[1], B[0]);

    //    A[4] <= 0; A[3] <= 0; A[2] <=1 ; A[1] <= 0; A[0] <= 0;
       A[4] <= 0; A[3] <= 1; A[2] <=1 ; A[1] <= 0; A[0] <= 0; // 12 -  6 = 6
    //    B[4] <= 1;B[3] <= 0; B[2] <= 1; B[1] <= 1; B[0] <= 0;
       B[4] <= 0;B[3] <= 0; B[2] <= 1; B[1] <= 1; B[0] <= 0;

        #10 s[3] <= 0; s[2] <= 0; s[1] <= 0; s[0] <= 0;
        #10 s[3] <= 0; s[2] <= 0; s[1] <= 0; s[0] <= 1;
        #10 s[3] <= 0; s[2] <= 0; s[1] <= 1; s[0] <= 0;
        #10 s[3] <= 0; s[2] <= 0; s[1] <= 1; s[0] <= 1;
        #10 s[3] <= 0; s[2] <= 1; s[1] <= 0; s[0] <= 0;
        #10 s[3] <= 0; s[2] <= 1; s[1] <= 0; s[0] <= 1;
        #10 s[3] <= 0; s[2] <= 1; s[1] <= 1; s[0] <= 0;
        #10 s[3] <= 0; s[2] <= 1; s[1] <= 1; s[0] <= 1;
        #10 s[3] <= 1; s[2] <= 0; s[1] <= 0; s[0] <= 0;
        #10 s[3] <= 1; s[2] <= 0; s[1] <= 0; s[0] <= 1;
        #10 s[3] <= 1; s[2] <= 0; s[1] <= 1; s[0] <= 0;
        #10 s[3] <= 1; s[2] <= 0; s[1] <= 1; s[0] <= 1;
        #10 s[3] <= 1; s[2] <= 1; s[1] <= 0; s[0] <= 0;
        #10 s[3] <= 1; s[2] <= 1; s[1] <= 0; s[0] <= 1;
        #10 s[3] <= 1; s[2] <= 1; s[1] <= 1; s[0] <= 0;
        #10 s[3] <= 1; s[2] <= 1; s[1] <= 1; s[0] <= 1;

        $finish;
    end
endmodule
////////////////////
