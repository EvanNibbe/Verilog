//Evan Nibbe, Srivatsan Srirangam, Eddie C.
//Nov 18, 2021
//Part3_add_register.v
//This code is derived from the code given by Dr. Eric Becker
//
//=============================================
// Half Adder
//=============================================
module HalfAdder(A,B,carry,sum);
	input A;
	input B;
	output carry;
	output sum;
	reg carry;
	reg sum;
//---------------------------------------------	
	always @(*) 
	  begin
	    sum= A ^ B;
	    carry= A & B;
	  end
//---------------------------------------------
endmodule



//=============================================
// Full Adder
//=============================================
module FullAdder(A,B,C,carry,sum);
	input A;
	input B;
	input C;
	output carry;
	output sum;
	reg carry;
	reg sum;
//---------------------------------------------	
	wire c0;
	wire s0;
	wire c1;
	wire s1;
//---------------------------------------------
//	HalfAdder ha1(A ,B,c0,s0);
//	HalfAdder ha2(s0,C,c1,s1);
//---------------------------------------------
	always @(*) 
	  begin
	    sum=s1;//
		sum= A^B^C;
	    carry=c1|c0;//
		carry= ((A^B)&C)|(A&B);  
	  end
//---------------------------------------------
	
endmodule

module AddSub(inputA,inputB,mode,sum,carry,overflow);
	function [1:0] full_adder(input a, b, c);
		begin
			full_adder[0]= (a^b)^c; //| 
			full_adder[1]=(((a & b) | (b & c) | (a & c)));
		end
	endfunction
    input [15:0] inputA;
	input [15:0] inputB;
    input mode;
    output [31:0] sum;
	output carry;
    output overflow;
	reg c0,c1,c2,c3,c4; //Carry Interfaces
	reg [1:0]car; //for using a 2 bit result function
	reg [15:0] count;
	reg [31:0] result;
always @(*) begin
	result=0;
	//#6
	for (count=0; count<16; count=count+1) begin
		c4=c1;
		if (count==0) begin
			car=full_adder(inputA[count], inputB[count]^mode, mode);
			c1=car[1];
			result[count]=car[0];
		end else begin
			car=full_adder(inputA[count], inputB[count]^mode, c4);
			c1=car[1];
			result[count]=car[0];
			
		end
	end
	//$display("Add line 91, A: %d, B: %d, sum %d", inputA, inputB, result);
	//now just replicate the bit at index 15 to cover all the rest of the bits of output
 end //end of always block
	assign sum=result;
	assign carry=c4;
	assign overflow=c4^c3;
endmodule

module multiply(inputA, inputB, res);
	input [15:0]inputA;
	input [15:0]inputB;
	output [31:0]res;
	
	reg [31:0]partial;
	reg [31:0]count;
	reg [15:0]count2;
	reg [31:0]count3;
	reg [31:0]mult;
	reg [31:0]addition;
	reg [1:0]car;
	function automatic [1:0] full_adder(input a, input b, input c);
		begin
			full_adder[0]= (a^b)^c; //| 
			full_adder[1]=(((a & b) | (b & c) | (a & c)));
		end
	endfunction
	//the following will need to be bitshifted left by i after it is calculated
	function automatic [31:0] partial_sum(input [15:0]a, input [15:0]i, input [15:0]b); 
		begin
			for(count=0; count<32; count=count+1) begin
				if (count<i) begin
					partial_sum[count]=0;
				end else if (count<i+16) begin
					partial_sum[count]=a[i] && b[count-i]; //thus multiplying one bit of a by each bit of b
				end else begin
					partial_sum[count]=a[15] ^ b[15]; //two positive numbers make a positive, two negative numbers a positive, one pos one neg makes neg
				end
			end
		end
	endfunction
	always @(*) begin
			mult=0;
			for (count2=0; count2<16; count2=count2+1) begin
				//mult=addition(mult, partial_sum(a, count2, b)); 
				partial=partial_sum(inputA, count2, inputB);
				car=0;
				for (count3=0; count3<32; count3=count3+1) begin
					car=full_adder(car[1], mult[count3], partial[count3]);
					//#6;
					addition[count3]=car[0];
				end
				//#6;
				mult=addition;
			end
		//$display("mult line 145, A: %d, B: %d, sum %d", inputA, inputB, mult);
	end //end always block
	assign res=mult;
endmodule

module divide(inputA, inputB, resDiv, divZero);
	input [15:0] inputA;
	input [15:0]inputB;
	output [31:0]resDiv;
	output divZero;
	reg [31:0] res;
	reg dZ;
	always @(*) begin
		if (inputB==0) begin
			dZ=1;
			res=-1;
		end else begin
			res=inputA/inputB;
			dZ=0;
		end
		//$display("div line 165, A: %d, B: %d, sum %d", inputA, inputB, res);
	end
	assign divZero=dZ;
	assign resDiv=res;
endmodule

module modulo(inputA, inputB, resMod, divZero);
	input [15:0] inputA;
	input [15:0] inputB;
	output [31:0] resMod;
	output divZero;
	reg [31:0] res;
	reg dZ;
	always @(*) begin
		if (inputB==0) begin
			 dZ=1;
			res=-1;
		end else begin
			res=inputA%inputB;
			dZ=0;
		end
		//$display("mod line 186, A: %d, B: %d, sum %d", inputA, inputB, res);
	end
	assign divZero=dZ;
	assign resMod=res;
endmodule



module Dec4x16(binary,onehot);
	input [31:0] binary;
	output [31:0]onehot;
	
	assign onehot[ 0]=~binary[3]&~binary[2]&~binary[1]&~binary[0];
	assign onehot[ 1]=~binary[3]&~binary[2]&~binary[1]& binary[0];
	assign onehot[ 2]=~binary[3]&~binary[2]& binary[1]&~binary[0];
	assign onehot[ 3]=~binary[3]&~binary[2]& binary[1]& binary[0];
	assign onehot[ 4]=~binary[3]& binary[2]&~binary[1]&~binary[0];
	assign onehot[ 5]=~binary[3]& binary[2]&~binary[1]& binary[0];
	assign onehot[ 6]=~binary[3]& binary[2]& binary[1]&~binary[0];
	assign onehot[ 7]=~binary[3]& binary[2]& binary[1]& binary[0];
	assign onehot[ 8]= binary[3]&~binary[2]&~binary[1]&~binary[0];
	assign onehot[ 9]= binary[3]&~binary[2]&~binary[1]& binary[0];
	assign onehot[10]= binary[3]&~binary[2]& binary[1]&~binary[0];
	assign onehot[11]= binary[3]&~binary[2]& binary[1]& binary[0];
	assign onehot[12]= binary[3]& binary[2]&~binary[1]&~binary[0];
	assign onehot[13]= binary[3]& binary[2]&~binary[1]& binary[0];
	assign onehot[14]= binary[3]& binary[2]& binary[1]&~binary[0];
	assign onehot[15]= binary[3]& binary[2]& binary[1]& binary[0];
	
endmodule

 
//MUX Multiplexer 16 by 4
module Mux16x4a(channels,select,b);
input [15:0][31:0]channels;
input       [3:0] select;
output      [31:0] b;
wire  [15:0][31:0] channels;
reg         [31:0] b;

always @(*)
begin
 b=channels[select]; //This is disgusting....
end

endmodule
 

module Mux16x4b(channels, select, b);
input [15:0][31:0] channels;
input      [31:0] select;
output      [31:0] b;
//wire  [15:0][31:0] channels;
//wire        [31:0] b;


	assign b = ({32{select[15]}} & channels[15]) | 
               ({32{select[14]}} & channels[14]) |
			   ({32{select[13]}} & channels[13]) |
			   ({32{select[12]}} & channels[12]) |
			   ({32{select[11]}} & channels[11]) |
			   ({32{select[10]}} & channels[10]) |
			   ({32{select[ 9]}} & channels[ 9]) |
			   ({32{select[ 8]}} & channels[ 8]) |
			   ({32{select[ 7]}} & channels[ 7]) |
			   ({32{select[ 6]}} & channels[ 6]) |
			   ({32{select[ 5]}} & channels[ 5]) |
			   ({32{select[ 4]}} & channels[ 4]) |
			   ({32{select[ 3]}} & channels[ 3]) |
			   ({32{select[ 2]}} & channels[ 2]) | 
               ({32{select[ 1]}} & channels[ 1]) |
               ({32{select[ 0]}} & channels[ 0]) ;

endmodule

module Logic(inputA, inputB, op_code, resLog);
input [15:0]inputA;
input [15:0]inputB;
input [3:0]op_code;
output [31:0]resLog;
wire [15:0]inputA;
wire [15:0]inputB;
wire [3:0]op_code;
wire [31:0]resLog;
reg [15:0]res;

always @(*) begin
	if (op_code==5) begin //AND
		res=inputA & inputB;
	end else if (op_code==6) begin //OR
		res=inputA | inputB;
	end else if (op_code==7) begin //NAND
		res=~(inputA & inputB);
	end else if (op_code==9) begin //NOR
		res=~(inputA | inputB);
	end else if (op_code==10) begin //XOR
		res=inputA ^ inputB;
	end else if (op_code==11) begin //XNOR
		res=(inputA & inputB) | ~(inputA | inputB); //is true when both are false or when both are true 
	end else begin //NOT (would be on 12, or on any other call.)
		res=~inputA;
	end


end //end always

assign resLog=res;

endmodule


//=============================================
// DFF
//=============================================
module DFF(clk,in,out);
 parameter n=32;//width
 input clk;
//  initial 
//  	forever begin
//     		#26 
//		clk = ~clk;
//  	end

 input [n-1:0] in;
 output [n-1:0] out;
 reg [n-1:0] out;
	//output [3:0]op_code;
	//reg [3:0]op_code;
	//reg [n-1:0]maintain;
	always @(posedge clk) begin
		#3;
		out<=in;
		//setting op_code to NO-OP after changes results in unresolved wires, so I will just have to change the clock in order to make sure everything runs properly
		//op_code<=4'b1101; //set to No-op in order to avoid repeat changes.
		//out=maintain;
		//$display("DFF run, input %d or %b", in, in);
	end //end always
 //assign out = maintain;
endmodule

module BreadBoard(inputA,inputB,op_code,R,error,register);
input [31:0] register;
//reg [31:0] register; 
input [15:0]inputA;
input [15:0]inputB;
input [3:0] op_code;
output [31:0]R;
output error;
wire [15:0]inputA;
wire [15:0]inputB;
wire [3:0] op_code;
reg [31:0]R;
reg error;
reg [6:0] display;


//Local Variables
//Full Adder
reg mode;
wire [31:0] sum;
wire [31:0] resMod;
wire [31:0] resDiv;
wire [31:0] resLog; //AND, OR, NAND, NOR, XOR, XNOR, NOT
wire divZero;
wire divZero2; //a dummy variable since only one of these two needs to discover that inputB is 0
wire [31:0] res; //multiplication
wire carry;
wire overflow;

//Multiplexer
wire [15:0][31:0] channels ;
wire [31:0] onehotMux;
wire [31:0] b;

//Seven Segment Display
wire [31:0] D;
wire [31:0] replace_op_code; //need 32 bits to maintain consistency with other changes
assign replace_op_code=op_code;
 

Dec4x16 DecBeta(b,D);
Dec4x16 DecAlpha(replace_op_code,onehotMux);
AddSub nept(inputA,inputB,mode,sum,carry,overflow);
multiply Mult3(inputA, inputB, res);
divide div3(inputA, inputB, resDiv, divZero);
modulo mod3(inputA, inputB, resMod, divZero2);
Logic log(inputA, inputB, op_code, resLog);
//Mux16x4a uran(channels,op_code,b);
Mux16x4b satu(channels,onehotMux,b);



assign channels[ 0]=sum;//Addition
assign channels[ 1]=resMod;//Modulo
assign channels[ 2]=resDiv;//Divide
assign channels[ 3]=32'b000000000000000000000000000000;//GROUND=0 //reset 0
assign channels[ 4]=res;//Multiplication
assign channels[ 5]=resLog;//AND
assign channels[ 6]=resLog;//OR
assign channels[ 7]=resLog;//NAND
assign channels[ 8]=sum;//Subtraction
assign channels[ 9]=resLog;//NOR
assign channels[10]=resLog;//XOR
assign channels[11]=resLog;//XNOR
assign channels[12]=resLog;//NOT
assign channels[13]=register;//GROUND=0 //will eventually be the No-op command once the register is used
assign channels[14]=0;//GROUND=0
assign channels[15]=32'b11111111111111111111111111111111; //preset 111111111111111111111111111111

always @(*)  
begin
//-------------------------------------------------------------
 mode=op_code[3];
//$display("line 334 sum: %b, b: %b", sum, b);
	R=b;
 error=overflow;
//------------------------------------------------------------- 
//-------------------------------------------------------------	   
end

endmodule



module TestBench();
  reg clk=0;
  reg [15:0] inputA;
  wire [15:0] inputB;
  reg [3:0] op_code;
  wire [31:0] result;
	wire [31:0]result2;
	wire [31:0]result3;
	wire [31:0]result4;
	wire [31:0]R;
  wire error;
	wire [1:0] E; //the output error
	wire divZero;

	//-----------------------------------------
	//registers
	reg [15:0] tempresult1;
	reg [15:0] tempresult2;
	reg [15:0] pi = 31416; //constant (we have to divide by 10,000), then modulo to get the 
	reg [15:0] circum; //circumference
	reg [15:0] height;
	reg [15:0] slope; //result of pythagoran theorem
	reg [15:0] geoa; //a^2
	reg [15:0] geob; //b^2
	reg [15:0] up_sl; //slope/10000
	reg [15:0] dn_sl; //slope%10000


	//outputs/result
	//wire [31:0] SA; //surface area
	//wire [31:0] Vol; //volume
	//---------------------------------------------
  
  wire [31:0] register;
	assign inputB=register[15:0];
	//alias inputB={{register[15], register[14], register[13], register[12], register[11], register[10], register[9], register[8], register[7], register[6], register[5], register[4], register[3], register[2], register[1], register[0]};
	DFF DFF1(clk,R,register);
  BreadBoard BB8(inputA,inputB,op_code,R,error,register);
	multiply Mult2(inputA, inputB, result2);
	divide Div2(inputA, inputB, result3, divZero);
	modulo Mod2(inputA, inputB, result4, divZero);
  reg k1,k2,k3,k4,k5;
  reg [10:0]segA;
  reg [7:0] charA;
  reg [6*8-1:0] operation;
  //CLOCK Thread
  initial
	begin
		clk=0;
		//R=0;
		#1;
		clk=1;
		#1;
		clk=0;
		charA=0;
			forever
				begin
					#20;
					clk=1;
					#30;
					clk=0;
					//if (charA<120 && charA%7==3) begin
					//	
					//	$display("clock run %d times", charA);
					//end
					//charA=charA+1;
					
				end
	end
	assign E[1]=((!(inputB || inputB)) && (op_code==1 || op_code==2))		; //divideZero

	assign E[0]= (op_code==0 || op_code==8); //determine whether addoverflow could occur.
  initial begin
    assign inputA  = 4'b0110;
	//assign inputB  = 4'b1001;
	
	//(!(op_code || op_code) || op_code[3]) && error; //addOverflow
	
	$display("inputA\tinputA (bin)\t\tinputB\tinputB (bin)\t\tOperation\top_code\t\tOutput\tOutput (bin)\t\t\t\tError");

	//Each line of the table is done by replicating the effect of this, though this will be edited to use the feedback from the clock on each operation to
	//the register in a feedback loop
	assign op_code = 4'b0011;
	operation="RESET ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1101;
	operation="NO-OP ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0000;
	operation="ADD   ";
	while (clk==0) begin
		#3;
	end
	
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1000;
	operation="SUB   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0100;
	operation="MUL   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0010;
	operation="DIV   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0001;
	operation="MOD   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0101;
	operation="AND   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0110;
	operation="OR    ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1100;
	operation="NOT   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1010;
	operation="XOR   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1011;
	operation="XNOR  ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0111;
	operation="NAND  ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1001;
	operation="NOR   ";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b1111;
	operation="PRESET";
	while (clk==0) begin
		#3;
	end

	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));
	while (clk==1) begin
		#3;
	end

	//SECOND EQUATION APPLICATION IMPLEMENTATION
	//--------------------------------------------------------------------------------------------------------//
	
	

	//Pythagorean theorem
	//a^2 + b^2 = c^2
	//h^2 + r^2 = slope^

	$display("---------------------Geometric Equations---------------------");

	$display("Surface Area\t\t\t\tVolume");

	//Surface Area
	//Surface Area of cone: SA=πrs+πr^2

	//πr^2 (this part of the equation)
	assign op_code = 4'b0011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 4'b0110; //radius = 6

	assign op_code = 4'b0000; //add (add 0+ 6) = 6

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register);

	assign inputA = 4'b0110; //radius = 6

	assign op_code = 4'b0100; //multiply (multiply 6 * 6) = 36

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register);

	assign inputA = pi;

	assign op_code = 4'b0100; //multiply (36 * pi) = some number lol

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register);

	assign tempresult1 = inputA; // at this point we have πr^2
	assign inputA = 0;

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register); //0

	//a^2+b^2 = sqrt(slope)

	//part a^2
	assign op_code = 4'b0011; //reset


	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 4'b0100; //height = 4
	assign op_code = 4'b0000; //add (add 0+ 4) = 4
	
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register); //4

	assign inputA = 4'b0100; //height = 4
	
	assign op_code = 4'b0100; //multiply (4 * 4) = 16

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register);//16

	geoa <= register; //slower assign statement

	//part b^2
	assign inputA = 0;
	assign op_code = 4'b0011;//reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 4'b0110; //radius = 6

	assign op_code = 4'b0000; //add ( 0 + 6) = 6

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign op_code = 4'b0100; //multiply ( 6 * 6) = 36

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register); //36

	assign inputA = geoa;
	assign op_code = 4'b0000; //add (add 36 + 16)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register); //52

	slope <= register; //at this point we have a^2 + b^2

	//divide slope
	assign inputA = 0;
	assign op_code = 4'b0011;//reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10000;

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = slope;

	assign op_code = 4'b0010;

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	up_sl <= register;

	assign op_code 4'b0011; //reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 10000;

	assign op_code = 4'b0000; //add (0+10000);

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = slope;

	assign op_code = 4'b0001; //mod (slope%10000)

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	dn_sl <= register;

	//πrs (this part of the equation)
	assign op_code = 4'b0011;//reset

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	assign inputA = 4'b0110; //radius = 6

	assign op_code = 4'b0000; //add (add 0+ 6) = 6

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register); //6

	assign inputA = pi;

	assign op_code = 4'b0100; //multiply (6 * pi) = some number lol

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register); //188496

	//need to add the pythagorean theorem

	//slope = $sqrt(slope); //$sqrt(result of a^2 + b^2)






	
	assign inputA = 7; //assign inputA = slope;




	assign op_code = 4'b0100; //multiply (6 * pi * slope) = some number lol

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register);

	//now we put both parts together
	assign inputA = tempresult1;
	assign op_code = 4'b0000; // add ((6 * pi * slope) + (pi * r * r))

	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end

	$display("%d",register);

	//Volume
	//Volume of cone: v=1/3 (πr^2h)

	$display("Cone : %d.%d",inputA, pi);
	$display("Cone : %d.%d",inputA/10000, inputA%10000);

	//Surface Area
	//Surface Area of Sphere: 4πr^2

	//Volume
	//Volume of Sphere: v=4/3 (πr^3)

	$display("Sphere: %d \t%b %d \t%b", );

	//Surface Area
	//Surface Area of Cylinder: 2πr^2 + 2πrh

	//Volume
	//Volume of Cylinder: πr^2h

	$display("Cylinder: %d \t%b %d \t%b", );


	//--------------------------------------------------------------------------------------------------------//


	//$display("op_code set %d times, clock run %d times", segA, charA);


//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Now we are going to do a simple math operation, then a medium difficulty problem, then a hard difficulty problem
	assign op_code = 4'b0011; //reset
	while (clk==0) begin
		#3;
	end

	while (clk==1) begin
		#3;
	end
	//value of inputB is now 0
	//To do the Fibonnaci series, I will need an extra register, C, and inputB and C will be swapping with each other to recieve the next value.
	//this means that 

	#60; 

	$finish;
  end  
 

 
endmodule
