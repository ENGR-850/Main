`timescale 1ns/1ps
`default_nettype none
`include "top_if.sv"
`include "top_test.sv"
module top_testbench;
   bit clock; 
     
  // Generate Clock signal
   initial begin
   //$dumpfile("dump.vcd");
   //$dumpvars;
   $vcdpluson;
   clock = 1'b0;
   forever #10ns clock=!clock;
   end
     // The interface
     top_if topif(clock);

     // The DUT
  top top_1(
      .BestDist(topif.BestDist),
      .motionX(topif.motionX [3:0]),
      .motionY(topif.motionY [3:0]),
      .clock(topif.clock),
      .start(topif.start),
      .AddressR(topif.AddressR),
      .AddressS1(topif.AddressS1),
      .AddressS2(topif.AddressS2),
      .R(topif.R),
      .S1(topif.S1),
      .S2(topif.S2),
      .completed(topif.completed));

     // The test
     test test(topif.top_test);   
 
   
endmodule // test