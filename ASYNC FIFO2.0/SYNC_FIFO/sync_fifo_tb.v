`timescale 10ns/1ns
module testfifo;
reg rst, clk, rd_en, wr_en;
reg [7:0] data_in;
wire [7:0]  data_out;
wire full, empty, halffull;

sync_fifo faa1(clk, rst, wr_en, rd_en, data_in, data_out, empty, full);

initial begin
  rst=1;
  clk=0;
  #1 rst = 0;
  #5 rst = 1;
end

always #20 clk = ~clk;

initial begin
  wr_en = 0;
  #1 wr_en = 1;
end

initial begin 
  rd_en = 0;
  #650 rd_en = 1;
       wr_en = 0;
end

initial begin
  data_in = 8'h0;
  #40 data_in = 8'h1;
  #40 data_in = 8'h2;
  #40 data_in = 8'h3;
  #40 data_in = 8'h4;
  #40 data_in = 8'h5;
  #40 data_in = 8'h6;
  #40 data_in = 8'h7;
  #40 data_in = 8'h8;
  #40 data_in = 8'h9;
  #40 data_in = 8'ha;
  #40 data_in = 8'hb;
  #40 data_in = 8'hc;
  #40 data_in = 8'hd;
  #40 data_in = 8'he;
  #40 data_in = 8'hf;
  #650 $finish;
end


endmodule
