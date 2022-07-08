// --------------------------------------
// FileName: PulseSync
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:PulseSync
// Version: 1.0
// Date: 2022-5-9
// Copyright:https://github.com/Ch1-n
// --------------------------------------
module PulseSync (
  input     clk_a,
  input     clk_b,
  input     rst_n_a,
  input     rst_n_b,
  input     vld_in,
  input     pulse_en,
  output    vld_out
);

  reg vld_a;  //data of D port
  reg vld_a1; //data of Q port
  reg vld_b;  //a1 signal in the B clock domain
  reg vld_b1; //b signal after 2 dff
  reg vld_b1_r;//b signal after 1 dff
  reg vld_b1_ar;//b1 signal after 1 dff in the A clock 
  reg vld_b1_arr;//b signal after 2 dff in the A clock domain

  wire en;
  wire rdy;
  wire vld_b2;
  reg   clken_a;
  reg   clken_b;
  wire  vld_out;  
  wire  gated_clka;
  wire  gated_clkb;   

// block clock gating 
always @ (clk_a or pulse_en)  begin
   if (!clk_a) 
      clken_a <= pulse_en;
end

assign gated_clka = clken_a & clk_a;

always @ (gated_clkb or pulse_en)  begin
   if (!clk_b) 
      clken_b <= pulse_en;
end
assign gated_clkb = clken_b & clk_b;

//SYNC
  always @(posedge gated_clka or rst_n_a) begin
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

  always @(posedge gated_clkb or rst_n_b) begin
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

  assign vld_b2 = vld_b ^ vld_b1;

  always @(posedge gated_clkb or rst_n_b) begin
    if(!rst_n_b) begin
      vld_b2    <=  1'b0;
    end else  begin
      vld_pls    <=  vld_b2;      
    end
  end

  always @(posedge gated_clka or rst_n_a) begin
    if(!rst_n_b) begin
      vld_b1_ar  <=  1'b0;
      vld_b1_arr <=  1'b0;
    end else  begin
      vld_b1_ar   <=  vld_b1;
      vld_b1_arr  <=  vld_b1_ar;
    end
  end  
  assign rdy = ~(vld_a1 ^ vld_b1_ar);
  assign en  = vid_in && rdy;

endmodule