// --------------------------------------
// FileName: fifo_a
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:异步fifo
// Version: 1.0
// Date: 2022年5月9日21:45:37
// Copyright:https://github.com/Ch1-n
// --------------------------------------
 module fifo_async 
 #(  parameter DEPTH = 8,
     parameter WIDTH = 8
 )(  input   wr_en,
     input   rd_en,
     input   [WIDTH-1:0] wr_data,
     output  reg [WIDTH-1:0] rd_data,
     input   wr_clk,
     input   rd_clk,
     output  reg full,
     output  reg empty,
     input   wrst_n,
     input   rrst_n
 );
   reg [$clog2(DEPTH):0]   wr_addr, rd_addr;//read&write address
   reg [WIDTH-1:0] fifo_a [DEPTH-1:0];//fifo_async

  //write
  always @(posedge wr_clk or negedge wrst_n ) begin
    if(!wrst_n) begin
      wr_addr <= 0;
    end else if (wr_en && !full) begin
      fifo_a[wr_addr] <=  wr_data;
      wr_addr <= wr_addr + 1;
    end else  wr_addr <=  wr_addr;
  end


  //read
  always @(posedge rd_clk or negedge rrst_n) begin
    if(!rrst_n) begin
      rd_addr <= 0;
      rd_data <= 0;
    end else if (rd_en && !empty) begin
      rd_data   <=    fifo_a[rd_addr];
      rd_addr   <=    rd_addr + 1;
    end else rd_addr  <=  rd_addr;
  end

  // bin to Gray
  wire [$clog2(DEPTH):0] wr_addr_g;
  wire [$clog2(DEPTH):0] rd_addr_g;
  assign wr_addr_g  =  wr_addr ^ (wr_addr >> 1);
  assign rd_addr_g  =  rd_addr ^ (rd_addr >> 1);


  //Define Tap Delay Gray Code
  reg [$clog2(DEPTH):0] wr_addr_gr,wr_addr_grr; 
  reg [$clog2(DEPTH):0] rd_addr_gr,rd_addr_grr;

  //wr_clk sync to rd_clk
  always @(posedge rd_clk or negedge rrst_n) begin
    if(!rrst_n) begin
      wr_addr_gr  <= 0;
      wr_addr_grr <= 0;
    end else begin
      wr_addr_gr   <=  wr_addr_g;
      wr_addr_grr  <=  wr_addr_gr;
    end
  end

  //rd_clk sync to wr_clk
  always @(posedge wr_clk or negedge wrst_n) begin
    if(!wrst_n) begin
      rd_addr_gr  <= 0;
      rd_addr_grr <= 0;
    end else begin
      rd_addr_gr   <=  wr_addr_g;
      rd_addr_grr  <=  wr_addr_gr;
    end
  end  

  //assign empty = (wr_addr_grr[$clog2(DEPTH):0] == rd_addr_grr[$clog2(DEPTH):0])?1:0;
  //assign full  = ({~wr_addr_grr[$clog2(DEPTH):$clog2(DEPTH)-1],wr_addr_grr[$clog2(DEPTH)-2:0]} == rd_addr_grr[$clog2(DEPTH):0])?1:0;
 
  //判断空
   always @(posedge rd_clk or negedge rrst_n ) begin
    if(!rrst_n) begin
      empty <= 0;
    end else if (wr_addr_grr == rd_addr_g) begin
      empty <= 1;
    end else empty  <=  0;
  end

  //判断满
  always @(posedge wr_clk or negedge wrst_n ) begin
    if(!wrst_n) begin
      full <= 0;
    end else if ({~wr_addr_g[$clog2(DEPTH):$clog2(DEPTH)-1],wr_addr_g[$clog2(DEPTH)-2:0]} == rd_addr_grr[$clog2(DEPTH):0]) begin
      full <= 1;
    end else full  <=  0;
  end


 
 endmodule