// --------------------------------------
// FileName: EdgeSync
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:EdgeSync
// Version: 1.0
// Date: 2022-5-9
// Copyright:https://github.com/Ch1-n
// --------------------------------------
module EdgeSync (
  input     clk_a,
  input     clk_b,
  input     rst_n_a,
  input     rst_n_b,
  input     vld_in,

  output    vld_out
);
  reg   vld_a;
  reg   vld_b;
  reg   vld_b1;
  reg   vld_b2;  
  wire  vld_out;

  always @(posedge clk_a or rst_n_a) begin
    if (!rst_n_a) begin
      vld_a  <=  1'b0;        
    end else begin
      vld_a  <=  vld_in;      
    end
  end    

  always @(posedge clk_b or rst_n_b) begin
    if (!rst_n_b) begin
      vld_b  <=  1'b0;
      vld_b1 <=  1'b0;  
      vld_b2 <=  1'b0;          
    end else begin
      vld_b  <=  vld_a;
      vld_b1 <=  vld_b;   
      vld_b2 <=  vld_b1;             
    end
  end

  assign  vld_out = vld_b1 && (!vld_b2);

endmodule