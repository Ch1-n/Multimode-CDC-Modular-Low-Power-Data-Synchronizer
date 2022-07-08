// --------------------------------------
// FileName: DMUX
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:DMUX
// Version: 1.0
// Date: 2022.6.7
// Copyright:https://github.com/Ch1-n
// --------------------------------------

module DMUX
#(  parameter WIDTH = 32
 )(
    input clk_a,
    input clk_b,
    input vld_in,
    input rst_n_a,
    input rst_n_b,
    input dmux_en,
    input [WIDTH-1:0] data_in,

    output             vld_out,
    output [WIDTH-1:0] data_out
);
    reg             vld_b1;
    reg             vld_b2;
    reg             vld_b3;

    reg             vld_a;
    wire            vld_e;
    reg [WIDTH-1:0] data_a;
    reg             clken_a;
    reg             clken_b;
    wire            vld_out;  
    wire            gated_clka;
    wire            gated_clkb;   

// block clock gating 
always @ (clk_a or dmux_en)  begin
   if (!clk_a) 
      clken_a <= dmux_en;
end

assign gated_clka = clken_a & clk_a;

always @ (clk_b or dmux_en)  begin
   if (!clk_b) 
      clken_b <= dmux_en;
end
assign gated_clkb = clken_b & clk_b;

  //Source Clock Domain Registered Data
  always @(posedge gated_clka or rst_n_a) begin
    if(!rst_n_a) begin
      vld_a <=  1'b0;
    end else begin vld_a  <=  vld_in;
    end
  end

  always @(posedge gated_clka or rst_n_a) begin
    if(!rst_n_a) begin
      data_a <=  32'b0;
    end else begin  data_a  <=  data_in;
  end
  end

  //Select level synchronization, pulse synchronization or edge synchronization according to the actual situation
  
  //Two-level level synchronization
  always @(posedge gated_clkb or rst_n_b) begin
    if(!rst_n_b) begin
      vld_b1 <=  1'b0;
      vld_b2 <=  1'b0;     
    end else begin        
      vld_b1 <=  vld_a;
      vld_b2 <=  vld_b1; 
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



  //Edge detection synchronization
  always @(posedge gated_clkb or posedge rst_n_b) begin
    if(!rst_n_b) begin
      vld_b3 <= 1'b0;
    end else begin
      vld_b3<= vld_b2;
    end
  end

  assign vld_e = vld_b2 && (!vld_b3);

  //Data out
  always @(posedge gated_clkb or rst_n_b) begin
    if(!rst_n_b) begin
      data_out  <= 32'b0;
    end else begin
      data_out  <= data_a;
    end
  end
  //control signal output
    always @(posedge gated_clkb or rst_n_b) begin
    if(!rst_n_b) begin
      vld_out  <= 1'b0;
    end else begin
      vld_out  <= vld_e;
    end
  end
endmodule