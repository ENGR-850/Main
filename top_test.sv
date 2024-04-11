// Here is the testbench proper:
program automatic test(top_if topif);

    // Test bench gets wires for all device under test (DUT) outputs:

   reg [7:0]     Rmem[0:255]; 
   reg [7:0]     Smem[0:1023];
   //reg [3:0] Expected_motionX, Expected_motionY;
   integer Expected_motionX, Expected_motionY;
   integer       i;
   integer       j;
   integer signed x, y;
   
   // Referesen and search memories

   ROM_R memR_u(.clock(topif.clock), .AddressR(topif.AddressR), .R(topif.R));
   ROM_S memS_u(.clock(topif.clock), .AddressS1(topif.AddressS1), .AddressS2(topif.AddressS2), .S1(topif.S1), .S2(topif.S2));
   
   initial
   begin
      // First setup up to monitor all inputs and outputs
      $monitor ("time=%5d ns, clock =%b, start =%b, BestDist =%b, motionX =%d, motionY =%d, count =%d", $time, topif.clock, topif.start , topif.BestDist[7:0], topif.motionX[3:0], topif.motionY[3:0], topif.ctl_u.count[12:0]);

      // Randomize Smem
      foreach (Smem[i]) begin
          Smem[i] = $urandom_range(0,255);
      end

      // Randomize expected motionX and motionY
      Expected_motionX = $urandom_range(0,15)-8;    
      Expected_motionY = $urandom_range(0,15)-8;

      // Extract Rmem from Smem for Expected_motionX and Expected_motionY
      foreach (Rmem[i]) begin
          Rmem[i] = Smem[32*8+8+(((i/16)+Expected_motionY)*32)+((i%16)+Expected_motionX)];
      end

      // Initialize memories
      foreach (memR_u.Rmem[i]) begin
          memR_u.Rmem[i]= Rmem[i];
      end
      foreach (memS_u.Smem[i]) begin
          memS_u.Smem[i]= Smem[i];
      end

      // First initialize all registers
      topif.clock = 1'b0;
      topif.start = 1'b0;

      // Start signal
      @(posedge topif.clock); #10;
      topif.start = 1'b1;

      // Loop to monitor newBest signal
      for (i = 0; i < 4112; i = i + 1) begin
          if (topif.comp_u.newBest == 1'b1) begin
              $display("New Result Coming!");
              // Exit the loop if newBest is detected
              break;
          end
          @(posedge topif.clock); #10;
      end

      topif.start = 1'b0;

      @(posedge topif.clock); #10;

      if (topif.motionX >= 8)
          x = topif.motionX - 16;
      else
          x = topif.motionX;

      if (topif.motionY >= 8)
          y = topif.motionY - 16;
      else
          y = topif.motionY;

      // Print memory content
      $display("Reference Memory content:");
      foreach (Rmem[i]) begin
          if(i%16 == 0) $display("  ");
          $write("%h  ",Rmem[i]);
          if(i == 255) $display("  ");
      }

      $display("Search Memory content:");
      foreach (Smem[i]) begin
          if(i%32 == 0) $display("  ");
          $write("%h  ",Smem[i]);
          if(i == 1023) $display("  ");
      }

      // Print test results
      if (topif.BestDist == 8'b11111111)
          $display("Reference Memory Not Found in the Search Window!");
      else
          begin
              if (topif.BestDist == 8'b00000000)
                  $display("Perfect Match Foudn for Reference Memory in the Search Window : BestDist = %d, motionX  = %d , motionY =  %d Expected motionX  = %d , Expected motionY =  %d ", topif.BestDist, x , y, Expected_motionX, Expected_motionY);
              else
                  $display("Non-perfect Match Found the Reference Memory in the Search Window : BestDist = %d, motionX  = %d , motionY =  %d Expected motionX  = %d , Expected motionY =  %d ", topif.BestDist, x, y, Expected_motionX, Expected_motionY);
          end

      if (x == Expected_motionX && y == Expected_motionY) begin
          $display("DUT motion outputs Do match expected motions: DUT motionX = %d DUT motionY = %d Expected_motionX = %d Expected_motionY = %d",x, y, Expected_motionX, Expected_motionY);
      end
      else begin
          $display("DUT motion outputs DO NOT match expected motions: DUT motionX = %d DUT motionY = %d Expected_motionX = %d Expected_motionY = %d",x, y, Expected_motionX, Expected_motionY);
      end

      $display("All tests completed\n\n");

      $finish;
   end

   // This is to create a dump file for offline viewing.
   /*initial
     begin
        $dumpfile ("top.dump");
        $dumpvars (0, top_testbench);
     end */

endprogram // top_testbench
