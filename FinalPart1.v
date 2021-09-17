//----------------------------------------------------------------------
module Breadboard	(w,x,y,z,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9); //Module Header
input w,x,y,z;                        //Specify inputs
output r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;                        //Specify outputs
reg r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;                           //Output is a memory area.

always @ ( w,x,y,z,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9) begin      //Create a set of code that works line by line 
                                      // if the variables are used


//Hey guys add your formulas to this section

//f0= 
//r0= 

//f1= 
//r1= 

//f2= zwx + ywx + yzw +yzx                                         //Comment for the formula
r2= z & w & x | y & w & x | y & z & w | y & z & x;                 //Bitwise operation of the formula

//f3= yx + zw
r3= y & x | z & w;

//f4= 
//r4= 

//f5= 
//r5=

//f6= 
//r6= 

//f7= 
//r7= 

//f8= 
//r8= 

//f9= 
//r9= 

end                                   // Finish the Always block

endmodule                             //Module End

//----------------------------------------------------------------------

module testbench();

  //Registers act like local variables
  reg [4:0] i; //A loop control for 16 rows of a truth table.
  reg  w;//Value of 2^3
  reg  x;//Value of 2^2
  reg  y;//Value of 2^1
  reg  z;//Value of 2^0
  
  //A wire can hold the return of a function
  wire  f0,f1,f2,f3,f4,f5,f6,f7,f8,f9;
  
  //Modules can be either functions, or model chips. 
  //They are instantiated like an object of a class, 
  //with a constructor with parameters.  They are not invoked,
  //but operate like a thread.
  Breadboard zap(w,x,y,z,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9);
     
	 
  //Initial means "start," like a Main() function.
  //Begin denotes the start of a block of code.	
  initial begin
   	
  //$display acts like a classic C printf command.
  $display ("|##|W|X|Y|Z|F0|F1|F2|F3|F4|F5|F6|F7|F8|F9|");
  $display ("|==+=+=+=+=+==+==+==+==+==+==+==+==+==+==|");
  
    //A for loop, with register i being the loop control variable.
	for (i = 0; i < 16; i = i + 1) 
	begin//Open the code blook of the for loop
		w=(i/8)%2;//High bit
		x=(i/4)%2;
		y=(i/2)%2;
		z=(i/1)%2;//Low bit	
		 
		//Oh, Dr. Becker, do you remember what belongs here? 
		#60;
		 	
		$display ("|%2d|%1d|%1d|%1d|%1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d| %1d|",i,w,x,y,z,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9);
		if(i%4==3) //Every fourth row of the table, put in a marker for easier reading.
		 $display ("|--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+--|");//Only one line, does not need a code block

	end//End of the for loop code block
 
	#10; //A time dealy of 10 time units. Hashtag Delay
	$finish;//A command, not unlike System.exit(0) in Java.
  end  //End the code block of the main (initial)
  
endmodule //Close the testbench module































//Dr. Becker's cheat sheet of what is wrong in the code.
//The loop control variable can never reach 16, it is only 4 bits. Add another bit
//There needs to be a time dealy, such a #5, inside the for loop
