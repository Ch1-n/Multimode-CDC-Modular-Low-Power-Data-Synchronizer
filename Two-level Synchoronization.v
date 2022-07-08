// --------------------------------------
// FileName: TwoLevelSync
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:TwoLevelSync
// Version: 1.0
// Date: 2022-5-9
// Copyright:https://github.com/Ch1-n
// --------------------------------------
module TwoLevelSync (
  input     clk_a,
  input     clk_b,
  input     rst_n_a,
  input     rst_n_b,
  input     vld_in,
  input     level_en,
  output    vld_out
);
  reg   vld_a;
  reg   vld_b;
  reg   vld_b1;
  reg   clken_a;
  reg   clken_b;
  wire  vld_out;  
  wire  gated_clka;
  wire  gated_clkb;   

// block clock gating 
always @ (clk_a or level_en)  begin
   if (!clk_a) 
      clken_a <= level_en;
end

assign gated_clka = clken_a & clk_a;

always @ (clk_b or level_en)  begin
   if (!clk_b) 
      clken_b <= level_en;
end
assign gated_clkb = clken_b & clk_b;

//SYNC
  always @(posedge gated_clka or rst_n_a) begin
    if (!rst_n_a) begin
      vld_a  <=  1'b0;        
    end else begin
      vld_a  <=  vld_in;      
    end
  end    

  always @(posedge gated_clkb or rst_n_b) begin
    if (!rst_n_b) begin
      vld_b  <=  1'b0;
      vld_b1 <=  1'b0;          
    end else begin
      vld_b  <=  vld_a;
      vld_b1 <=  vld_b;        
    end
  end

  assign  vld_out = vld_b1;

endmodule