// Interface for motion estimator design
interface top_if (input bit clock);
	bit start;
	logic [7:0] BestDist;
	logic [3:0] motionX, motionY;
	logic completed;
	logic [7:0] R, S1, S2;
	logic [7:0] AddressR;
	logic [9:0] AddressS1, AddressS2;
	
	//modport top_dut(input clock,start,R,S1,S2, output BestDist,motionX,motionY,AddressR,AddressS1, AddressS2,completed);
	modport top_test(input clock,BestDist,motionX,motionY,AddressR,AddressS1,AddressS2,completed,output start,R,S1,S2);

	/*ROM_R memR_u(.clock(topif.clock), .AddressR(topif.AddressR), .R(topif.R));

	ROM_S memS_u(.clock(topif.clock), .AddressS1(topif.AddressS1), .AddressS2(topif.AddressS2), .S1(topif.S1), .S2(topif.S2));*/
endinterface : top_if