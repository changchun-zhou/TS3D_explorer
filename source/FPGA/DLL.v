//********Ver 1.2******************************
//********Author: Chen Xu**********************
//********Date: 9/21/2019**********************
//********Modified by Chen Xu at 9/22/2019*****
//********This code cannot be synthesized******


`timescale 1ns/1ps

module DLL(CLK,RST,BYPASS,S1,S0,OUTCLK, VSSA, VDDA);

input CLK,RST,BYPASS;  //ref_clk is 50MHz 
input S0,S1;         //NOTICE: S0 is in left,S1 is in right
// output LOCK;
output reg OUTCLK;
input VSSA, VDDA;
reg REFCLK;
reg CLKB;
reg CLK2X,CLK4X,CLK8X,CLK10X;
reg CLK2,CLK4,CLK8,CLK10;
wire m;

integer n;
integer seed;
/*************generate virtual multi_CLK*****************/
initial                   
	begin
		CLK2=0;
		CLK4=0;
		CLK8=0;
		CLK10=0;
	end
	
always #5    CLK2=~CLK2;    
always #2.5  CLK4=~CLK4;
always #1.25 CLK8=~CLK8;
always #1    CLK10=~CLK10;

always @ (*)
	if(n==20)              //output  multi_clk when locking
		begin
			CLK2X=CLK2;    //output 2 frequency doubling clock
			CLK4X=CLK4;    //output 4 frequency doubling clock
			CLK8X=CLK8;    //output 8 frequency doubling clock
			CLK10X=CLK10;  //output 10 frequency doubling clock
		end
	else
		begin
			CLK2X=1'b0;
			CLK4X=1'b0;
			CLK8X=1'b0; 
			CLK10X=1'b0;
		end
		

/*******************generate REFCLK****************************/
always @ (*)
	if(RST)
		REFCLK=1;
	else
		REFCLK=CLK;


		
/*************generate virtual CLKB signal*******************/  
initial seed=2;                //initial random seed
assign m=$random(seed)/40;     //generate random number

always @ (posedge CLK or posedge RST)   //adjust the CLKB delay
	if(RST)
		n=m;                    //initial CLKB delay       
	else
		if((20-n)>0)
			n=n+1;
		else
			if((20-n)<0)
				n=n-1;
			else
				n=n;


always @(*)
	CLKB<=#n REFCLK;           


/*************LOCK DETECTOR*****************************/
// assign LOCK=(n==20);

/********generate OUTCLK***************************************/		
always @ (*)
	if(BYPASS)              
		OUTCLK=CLK;
	else
		if(RST)
			OUTCLK=1'bx;
		else
				begin
					case({S1,S0})
					2'b00: OUTCLK=CLK2X;
					2'b01: OUTCLK=CLK4X;
					2'b10: OUTCLK=CLK8X;
					2'b11: OUTCLK=CLK10X;
					default: ;
					endcase
				end

			
endmodule









		
		
