/*
Evan Nibbe
Oct 9, 2021
This file was derived from https://iverilog.fandom.com/wiki/Using_VPI
i.e. the manual on how to use the Verilog Programming Interface in C with iverilog
*/
#include <vpi_user.h>
static int hello_compiletf(char *user_data) {
	return 0;
}

//we can get an input of a byte from the following code and give an output of a byte back to the verilog system
//we will use this as a means of gradually outputting where different pieces are on the board to an array in verilog, where verilog will be used to check 
//whether someone has won, and if so to tell the player
//This is the function that provides the functionality of C
char board[2*6]; //each even byte starting at index 0 will represent what the row starting from the top looks like in whether the yellow piece is in that spot
	//each odd byte starting at index 1 will represent what row starting from the top the red piece is in
void getPlayer(int player);
static int hello_calltf(char *user_data) {
	int input=tf_getp(1);
	if (input<2*6) {
		tf_putp(0, board[input]); 
	} else {
		//if even, then it is yellow's turn, odd is red's turn, if equal to 30, then yellow wins, if equal to 31, then red wins
		if (input<30 && input%2==0) { //yellow turn
			getPlayer(0);
		} else if (input<30) { //red turn
			getPlayer(1);
		} else if (input==30) {
			vpi_printf("Yellow has won!");
		} else if (input==31) {
			vpi_printf("Red has won!");
		}

	}
	//vpi_printf("Hello, world!\tinput: %d\toutput: %d\n", input, input+1);
	return 0;
}
void hello_register() {
	s_vpi_systf_data tf_data;
	tf_data.type=vpiSysFunc;
	tf_data.tfname="$hello";
	tf_data.calltf=hello_calltf;
	tf_data.compiletf=hello_compiletf;
	tf_data.sizetf=0;
	tf_data.user_data=0;
	vpi_register_systf(&tf_data);
	//vpi_printf("Number is %d.\nReturn %d\n", arg, arg+1);
	//return arg+1;
}

//required to be void return and void input
void (*vlog_startup_routines[])() = 
{
	hello_register,
	0
};

//The following will be more traditional C code for getting player inputs and stating what the board looks like
void getPlayer(int player) {
	if (player==0) { //yellow
		
	} else { //red
		
	}
}
