// --------------------------------------
// FileName: MultimodeCDCModularLowPowerDataSynchronizer
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:Top
// Version: 1.0
// Date: 2022-5-9
// Copyright:https://github.com/Ch1-n
// --------------------------------------
module MCMLPDS  #(  
     parameter WIDTH = 32
 )(
  input   clk_a,//transmit clock domain
  input   clk_b,//receive clock domain
  input   vld_in,//control signal
  input   [WIDTH-1:0] mdata_in,//multibits data
  input   sdata_in,//single bit data
  input   rst_n_a,
  input   rst_n_b,
  input   en,
  output  vld_out,
  output  sdata_out,
  output  [WIDTH-1:0] mdata_out
);

  reg     [1:0] a;
  reg     [1:0] b;  
  reg     clken_a;
  reg     clken_b;  
  reg     flag_a;
  reg     flag_b;
  reg     flag_equal;
  wire    en;
  wire    gated_clka;
  wire    gated_clkb;

// clock frequency comparison module 
  
// block clock gating 
always @ (clk_a or en)  begin

   if (!clk_a) 

      clken_a <= en;

end

assign gated_clka = clken_a & clk_a;

always @ (clk_b or en)  begin

   if (!clk_b) 

      clken_b <= en;

end

assign gated_clkb = clken_b & clk_b;


//Compare Two Clock Frequency Relationships
  always @(posedge gated_clka or rst_n_a) begin
   if (!rst_n_a && clk_en) begin
     a  <=  2'b00;
   end else if (rst_n_a && clk_en) begin 
     a <= a + 1; // clock gating
  end
  end
 
  always @(posedge gated_clkb or rst_n_b) begin
   if (!rst_n_b && clk_en ) begin
     a  <=  2'b00;
   end else if (rst_n_b && clk_en) begin 
     b <= b + 1;// clock gating
  end
  end

  always @(*) begin
    if ((!(a&&b == 1))&&(a > b)) begin
      flag_a = 1;
    end else if ((!(a&&b == 1))&&(a == b)) begin
      flag_eqal = 1;
    end else if ((!(a&&b == 1))&&(a < b)) begin flag_b = 1;
    end // clock gating
  end

//After completing the comparison, close the clock frequency comparison module 

    assign clk_en = (flag_a || flag_b || flag_eqal)? 0 : 1 ;
 
//mode select
  always @(flag_a, flag_b, flag_equal) begin
    if (({flag_a, flag_b, flag_equal} == 3'b100) && (sdata_in != 0) && (mdata_in == 0)&& (vld_in == 0)) begin //fast to slow single bit data    
      // PulseSync enable
      pulse_en = 1'b1;

    end else if (({flag_a, flag_b, flag_equal} == 3'b100) && (sdata_in == 0) && (mdata_in != 0)&& (vld_in == 0)) begin
      //fast to slow multibit data
      //AsyncFIFO enable
      asyncfifo_en = 1'b1;
    end  else if (({flag_a, flag_b, flag_equal} == 3'b100) && (sdata_in == 0) && (mdata_in != 0)&& (vld_in != 0)) begin
    
  //fast to slow multibit data and single bit contral signal
    //DMUX enaable
          dmux_en = 1'b1;
  end else if (({flag_a, flag_b, flag_equal} == 3'b010)&& (sdata_in != 0) && (mdata_in == 0)&& (vld_in == 0))begin
    //slow to fast begin single bit data  
    level_en = 1'b1;// TwoLevel enable 
    //pulse_en = 1'b1 ; edge_en = 1'b1;
  end else if (({flag_a, flag_b, flag_equal} == 3'b010)&& (sdata_in == 0) && (mdata_in != 0)&& (vld_in == 0))begin //slow to fast multibit data
            //AsyncFIFO enable
      asyncfifo_en = 1'b1;
  end else if (({flag_a, flag_b, flag_equal} == 3'b010)&& (sdata_in == 0) && (mdata_in != 0)&& (vld_in != 0))begin //slow to fast multibit data and single bit contral signal
      //DMUX enaable
      dmux_en = 1'b1;
  end //clock gating
  end



  TwoLevelSync TwoLevelSync(.level_en(en), .clk_a(clk_a), clk_b(clk_b), .rst_n_a(rst_n_a), .rst_n_b(rst_n_b), .vld_in(vld_in), .vld_out(vld_out));
 
  PulseSync PulseSync(.pulse_en(en), .clk_a(clk_a), clk_b(clk_b), .rst_n_a(rst_n_a), .rst_n_b(rst_n_b), .vld_in(vld_in), .vld_out(vld_out));

  EdgeSync  EdgeSync(.edge_en(en), .clk_a(clk_a), clk_b(clk_b), .rst_n_a(rst_n_a), .rst_n_b(rst_n_b), .vld_in(vld_in), .vld_out(vld_out));

  DMUX  DMUX(.dmux_en(en), .clk_a(clk_a), clk_b(clk_b), .rst_n_a(rst_n_a), .rst_n_b(rst_n_b), .vld_in(vld_in), .vld_out(vld_out), .data_in(mdata_in), .data_out(mdata_out));

  fifo_async  ASYN_FIFO(.asyncfifo_en(en), .wr_clk(clk_a), .rd_clk(clk_b), ..wrst_n(rst_n_a), .rrst_n(rst_n_b), .wr_data(mdata_in), .rd_data(mdata_out), .wr_en(vld_in));

endmodule