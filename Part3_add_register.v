//Evan Nibbe, Srivatsan Srirangam, Eddie C.
//October 10, 2021
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
//     		#13 
//		clk = ~clk;
//  	end

 input [n-1:0] in;
 output [n-1:0] out;
 //reg [n-1:0] out;
	reg [n-1:0]maintain;
	always @(posedge clk) begin
		maintain=in;
		$display("DFF run, input %d or %b", in, in);
	end //end always
 assign out = maintain;
endmodule

module BreadBoard(inputA,inputB,op_code,R,error,display,register);
input [31:0] register;
//reg [31:0] register; 
input [15:0]inputA;
input [15:0]inputB;
input [3:0] op_code;
output [31:0]R;
output error;
output [6:0] display;
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
assign channels[15]=32'b111111111111111111111111111111; //preset 111111111111111111111111111111

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
	reg [31:0]R;
  wire error;
	reg [1:0] E; //the output error
	wire divZero;
  wire [6:0] display;
  
  wire [31:0] register;
	assign inputB=register[15:0];
	//alias inputB={{register[15], register[14], register[13], register[12], register[11], register[10], register[9], register[8], register[7], register[6], register[5], register[4], register[3], register[2], register[1], register[0]};
	DFF DFF1(clk,R,register);
  BreadBoard BB8(inputA,inputB,op_code,result,error,display,register);
	multiply Mult2(inputA, inputB, result2);
	divide Div2(inputA, inputB, result3, divZero);
	modulo Mod2(inputA, inputB, result4, divZero);
  reg k1,k2,k3,k4,k5;
  reg segA,segB,segC,segD,segE,segF,segG;
  reg [7:0] charA;
  reg [6*8-1:0] operation;
  //CLOCK Thread
  initial
	begin
		clk=0;
		//R=0;
		#3;
		clk=1;
		#3;
		clk=0;
			forever
				begin
					#6;
					clk=~clk;
					//if (charA<5) begin
					//	#2;
					//	$display("inputB is: %d or %b, clock run %d times", inputB, inputB, charA);
					//	charA=charA+1;
					//end
					
				end
	end
  initial begin
    assign inputA  = 4'b0110;
	//assign inputB  = 4'b1001;
	R=0;
	E=((!(inputB || inputB)) && (op_code==1 || op_code==2))<<1 |  (op_code==0 || op_code==8); //divideZero
	//(!(op_code || op_code) || op_code[3]) && error; //addOverflow
	
	$display("inputA\tinputA (bin)\t\tinputB\tinputB (bin)\t\tOperation\top_code\t\tOutput\tOutput (bin)\t\t\t\tError");

	//Each line of the table is done by replicating the effect of this, though this will be edited to use the feedback from the clock on each operation to
	//the register in a feedback loop
	assign op_code = 4'b0011;
	operation="RESET ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1101;
	operation="NO-OP ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0000;
	operation="ADD   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1000;
	operation="SUB   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0100;
	operation="MUL   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0010;
	operation="DIV   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0001;
	operation="MOD   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0101;
	operation="AND   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0110;
	operation="OR    ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1100;
	operation="NOT   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1010;
	operation="XOR   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1011;
	operation="XNOR  ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b0111;
	operation="NAND  ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1001;
	operation="NOR   ";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	assign op_code = 4'b1111;
	operation="PRESET";
	#13;
	$display("%d \t%b \t%d \t%b \t%s \t\t%b\t%d \t%b \t%b", inputA, inputA, inputB, inputB, operation, op_code, R, R, E & ~(!error));

	#13;
	$display("inputA { %2d:%b }, inputB { %2d:%b }, op_code:%b,%b,E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
	#13;
	//multiply Mult2(inputA, inputB, result2);
	$display("A * B = %b", result2);
	$display("A / B = %b, divZero: %b", result3, divZero);
	$display("A mod B = %b, divZero: %b", result4, divZero);
	$display();
	
 
  
   	assign op_code=4'b0100;
	#13;
		
	

	$display("%2d:%b,%2d:%b, op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

   	assign op_code=4'b1000;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   	assign op_code=4'b0000;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

	//AND
   	assign op_code=4'b0101;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   	
	//OR
	assign op_code=4'b0110;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//NAND
	assign op_code=4'b0111;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//NOR
	assign op_code=4'b1001;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//XOR
	assign op_code=4'b1010;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//XNOR
	assign op_code=4'b1011;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

	//NOT
	assign op_code=4'b1100;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
	#13;
	assign inputA=15'b101101110100111;
	//assign inputB=15'b110110011001110;
	#13;
	$display("inputA: %d, inputB: %d, op_code: %d, R: %d, E: %b", inputA, inputB, op_code, R, E & ~(!error));

	#13;
	$display("inputA { %2d:%b }, inputB { %2d:%b }, op_code:%b,%b,E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
	#13;
	//multiply Mult2(inputA, inputB, result2);
	$display("A * B = %b", result2);
	$display("A / B = %b, divZero: %b", result3, divZero);
	$display("A mod B = %b, divZero: %b", result4, divZero);
	$display();
	
 
  
   	assign op_code=4'b0100;
	#13;
		
	

	$display("%2d:%b,%2d:%b, op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

   	assign op_code=4'b1000;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   	assign op_code=4'b0000;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

	//AND
   	assign op_code=4'b0101;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   	
	//OR
	assign op_code=4'b0110;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//NAND
	assign op_code=4'b0111;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//NOR
	assign op_code=4'b1001;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//XOR
	assign op_code=4'b1010;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));
   
	//XNOR
	assign op_code=4'b1011;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

	//NOT
	assign op_code=4'b1100;
	#13;
		
	

	$display("%2d:%b,%2d:%b,op_code:%b, R: %b, E:%b",inputA,inputA,inputB,inputB,op_code,result, E & ~(!error));

	
	#60; 
	$finish;
  end  
 

 
endmodule
