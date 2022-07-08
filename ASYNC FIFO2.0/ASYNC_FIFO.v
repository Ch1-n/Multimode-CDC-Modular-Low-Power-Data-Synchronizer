// --------------------------------------
// FileName: fifo_a
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:async_fifo
// Version: 1.0
// Date: 2022-5-9
// Copyright:https://github.com/Ch1-n
// --------------------------------------

 module fifo_async 
 #(  parameter DEPTH = 8,
     parameter WIDTH = 32
 )(  input   wr_en,
     input   rd_en,
     input   [WIDTH-1:0] wr_data,
     output  reg [WIDTH-1:0] rd_data,
     input   wr_clk,
     input   rd_clk,
     input   asyncfifo_en,
     output  reg full,
     output  reg empty,
     input   wrst_n,
     input   rrst_n
 );
   reg [$clog2(DEPTH):0]   wr_addr, rd_addr;//read&write address
   reg [WIDTH-1:0] fifo_a [DEPTH-1:0];//fifo_async
   reg             clken_a;
   reg             clken_b;
   wire            vld_out;  
   wire            gated_clka;
   wire            gated_clkb;   

// block clock gating 
always @ (wr_clk or asyncfifo_en)  begin
   if (!wr_clk) 
      clken_wr <= asyncfifo_en;
end

assign wr_clk_en = clken_wr & wr_clk;

always @ (rd_clk or asyncfifo_en)  begin
   if (!rd_clk) 
      clken_rd <= asyncfifo_en;
end
assign rd_clk_en = clken_rd & rd_clk;

  //write
  always @(posedge wr_clk_en or negedge wrst_n ) begin
    if(!wrst_n) begin
      wr_addr <= 0;
    end else if (wr_en && !full) begin
      fifo_a[wr_addr] <=  wr_data;
      wr_addr <= wr_addr + 1;
   // end else  wr_addr <=  wr_addr;// clock-gating
  end
  end

  //read
  always @(posedge rd_clk_en or negedge rrst_n) begin
    if(!rrst_n) begin
      rd_addr <= 0;
      rd_data <= 0;
    end else if (rd_en && !empty) begin
      rd_data   <=    fifo_a[rd_addr];
      rd_addr   <=    rd_addr + 1;
    end // else rd_addr  <=  rd_addr; // clock-gating
  end

  // bin to Gray
  wire [$clog2(DEPTH):0] wr_addr_g;
  wire [$clog2(DEPTH):0] rd_addr_g;
  assign wr_addr_g  =  wr_addr ^ (wr_addr >> 1);
  assign rd_addr_g  =  rd_addr ^ (rd_addr >> 1);


  //Define Tap Delay Gray Code
  reg [$clog2(DEPTH):0] wr_addr_gr,wr_addr_grr; 
  reg [$clog2(DEPTH):0] rd_addr_gr,rd_addr_grr;


  //Select level synchronization, pulse synchronization or edge synchronization according to the actual situation
  
  //Two-level level synchronization

  //wr_clk sync to rd_clk  T
  always @(posedge rd_clk_en or negedge rrst_n) begin
    if(!rrst_n) begin
      wr_addr_gr  <= 0;
      wr_addr_grr <= 0;
    end else begin
      wr_addr_gr   <=  wr_addr_g;
      wr_addr_grr  <=  wr_addr_gr;
    end
  end

  //rd_clk sync to wr_clk  two-stage synchronizer
  always @(posedge wr_clk_en or negedge wrst_n) begin
    if(!wrst_n) begin
      rd_addr_gr  <= 0;
      rd_addr_grr <= 0;
    end else begin
      rd_addr_gr   <=  wr_addr_g;
      rd_addr_grr  <=  wr_addr_gr;
    end
  end  

/*
        Edge Synchronization

  always @(posedge clk_b or posedge rst_n_b) begin
    if(rst_n_b) begin
      vld_b1 <=  1'b0;
      vld_b2 <=  1'b0;     
      vld_b3 <=  1'b0;
    end else begin
      vld_b1 <=  vld_a;
      vld_b2 <=  vld_b1;       
      vld_b3 <=  vld_b2;
    end
  end
  assign vld_e = vld_b2 && (!vld_b3);


*/

/*

      Pulse Synchronization

  always @(posedge clk_a or rst_n_a) begin
    if (!rst_n_a) begin
      vld_a   <= 1'b0;
      vld_a1  <= 1'b0;
    end else begin
      if (en) begin
        vld_a1 <= vld_a;
      end else begin
        vld_a <= ~vld_a1;
      end
    end
  end

  always @(posedge clk_b or rst_n_b) begin
    if(!rst_n_b) begin
      vld_b_r   <=  1'b0;
      vld_b     <=  1'b0;
      vld_b1    <=  1'b0;
    end else  begin
      vld_b_r   <=  vld_a1;
      vld_b     <=  vld_b_r;
      vld_b1    <=  vld_b;      
    end
  end

  always @(posedge clk_b or rst_n_b) begin
    if(!rst_n_b) begin
      vld_b2    <=  1'b0;
    end else  begin
      vld_pls    <=  vld_b2;      
    end
  end

  always @(posedge clk_a or rst_n_a) begin
    if(!rst_n_b) begin
      vld_b1_r  <=  1'b0;
      vld_b1_rr <=  1'b0;
    end else  begin
      vld_b1_r   <=  vld_b1;
      vld_b1_rr  <=  vld_b1_r;
    end
  end  
  assign vld_b2 = vld_b ^ vld_b1;
  assign rdy = ~(vld_a ^ vld_b1_rr);
  assign en  = vid_in && rdy; 
*/

  //assign empty = (wr_addr_grr[$clog2(DEPTH):0] == rd_addr_grr[$clog2(DEPTH):0])?1:0;
  //assign full  = ({~wr_addr_grr[$clog2(DEPTH):$clog2(DEPTH)-1],wr_addr_grr[$clog2(DEPTH)-2:0]} == rd_addr_grr[$clog2(DEPTH):0])?1:0;
 
  //判断空
   always @(posedge rd_clk_en or negedge rrst_n ) begin
    if(!rrst_n) begin
      empty <= 0;
    end else if (wr_addr_grr == rd_addr_g) begin
      empty <= 1;
    end // else empty  <=  0;// clock-gating
  end

  //判断满
  always @(posedge wr_clk_en or negedge wrst_n ) begin
    if(!wrst_n) begin
      full <= 0;
    end else if ({~wr_addr_g[$clog2(DEPTH):$clog2(DEPTH)-1],wr_addr_g[$clog2(DEPTH)-2:0]} == rd_addr_grr[$clog2(DEPTH):0]) begin
      full <= 1;
    end // else full  <=  0;// clock-gating
  end


 
 endmodule