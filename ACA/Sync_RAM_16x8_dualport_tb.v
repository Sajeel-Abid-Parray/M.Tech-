/*#############################################################################################
Author Name    : Sajeel Abid Parray
Enrollment No  : 2026MECEME012
Specialization : Microelectronics (ME)
Semester       : 1st
Subject        : Advanced Computer Architecture (ACA)
Filename       : Sync_RAM_16x8_dualport_tb.v
Description    : Testbench for 16x8 Synchronous Dual Port RAM 
Language       : Verilog HDL
Project        : 16x8 Synchronous Dual port RAM
Date           : 30-October-2026
###############################################################################################*/
`timescale 1ns/ 1ps                    // defining time unit and time precision 

module Sync_RAM_16x8_dualport_tb ();

reg Clk, Rst, read, write;           // Making Inputs as reg type to drive the signals in the testbench...
reg [7:0] Din;                       // ... and outputs as wire type to monitor the signals in the testbench
wire [7:0] data_out;
reg [3:0] rd_addr, wr_addr;
integer i;                           // declaring integer variable for loop iteration

Sync_RAM_16x8_dualport DUT (.Clk(Clk), .Rst(Rst), .read(read), .write(write), .Din(Din),  // Module instantiation and mapping the signals in the...   
                            .data_out(data_out), .rd_addr(rd_addr), .wr_addr(wr_addr));   //...testbench to the module ports

always               // Always block to generate clock signal with a period of 10ns
  begin
    Clk = 0; #5; 
    Clk = 1; #5;
  end

task reset();        // Task to perform reset operation on the RAM and at the same time initialization of the input signals.
begin
  @(negedge Clk)
  Rst= 1;
	Din =0;
	write =0;
	read=0;
	wr_addr =0;
  rd_addr =0;
  @(posedge Clk)
  Rst=0;
end
endtask

task write_t (input [3:0] w_addr, input [7:0] data);        // Task to write data into the RAM
begin
  @(negedge Clk)
  write = 1;
  read = 0;
  wr_addr = w_addr;
  Din = data;
end
endtask

task read_t (input [3:0] r_addr);         // Task to read data from the RAM
@(negedge Clk)
begin
  write = 0;
  read = 1;
  rd_addr = r_addr;
end
endtask

initial 
begin
  reset;
  
  // Basic write and read
  write_t (4'd3, 8'd20);          // Write 20 to address 3(0011)
  read_t  (4'd3);                 // Read from address 3(0011)

  // Overwrite same address
  write_t (4'd3, 8'd15);         // Write 15 to address 3(0011)

  // Write to another address
  write_t (4'd7, 8'd8);          // Write 8 to address 7(0111)

  // read & write on same address 
  @(negedge Clk);
  write   = 1;
  read    = 1;
  wr_addr = 4'd7;
  rd_addr = 4'd7;
  Din     = 8'd24;

  // Full address sweep
  for (i = 0; i < 16; i = i + 1)         
  begin
    write_t (i, {$random % 256});         // Loop to write random data to all addresses and then read from them
    read_t  (i);
  end
  
  //read and write on different addresses at the same time (dual-port behavior)
  @(negedge Clk);                             
  write   = 1;
  read    = 1;
  wr_addr = 4'd2;
  rd_addr = 4'd9;
  Din     = 8'd55;
  @(negedge Clk);      // read from address 9(1001) )
  write   = 0;
  read    = 1;
  rd_addr = 4'd2; 

  #100;            
  $finish;           // Finish the simulation after 100ns
end

// Monitor block to display the values of the signals at each time step
initial $monitor ("Time= %0t, Clk= %b, Rst= %b, write= %b, read= %b, Din= %0d, wr_addr= %0d, rd_addr= %0d, data_out= %0d", 
                    $time, Clk, Rst, write, read, Din, wr_addr, rd_addr, data_out);

endmodule

