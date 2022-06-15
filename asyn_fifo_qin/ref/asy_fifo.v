
module asy_fifo#(
    parameter   WIDTH = 8,
    parameter   DEPTH = 8
)(
    input   [WIDTH - 1 : 0] wr_data,
    input                   wr_clk,
    input                   wr_rstn,
    input                   wr_en,
    input                   rd_clk,
    input                   rd_rstn,
    input                   rd_en,
    output    reg              fifo_full,
    output    reg             fifo_empty,
    output  reg [WIDTH - 1 : 0] rd_data
);
    //定义读写指针
    reg [$clog2(DEPTH) : 0]  wr_ptr, rd_ptr;

    //定义一个宽度为WIDTH，深度为DEPTH的fifo
    reg [WIDTH - 1 : 0] fifo    [DEPTH - 1 : 0];



    //写操作
    always @ (posedge wr_clk or negedge wr_rstn) begin
        if(!wr_rstn)
            wr_ptr <= 0;
        else if(wr_en && !fifo_full) begin
            fifo[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
        else
            wr_ptr <= wr_ptr;
    end

    //读操作
    always @ (posedge rd_clk or negedge rd_rstn) begin
        if(!rd_rstn) begin
            rd_ptr <= 0;
            rd_data <= 0;
        end
        else if(rd_en && !fifo_empty) begin
            rd_data <= fifo[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
        else
            rd_ptr <= rd_ptr;
    end

    //定义读写指针格雷码
    wire [$clog2(DEPTH) : 0] wr_ptr_g;
    wire [$clog2(DEPTH) : 0] rd_ptr_g;

    //读写指针转换成格雷码
    assign wr_ptr_g = wr_ptr ^ (wr_ptr >>> 1);
    assign rd_ptr_g = rd_ptr ^ (rd_ptr >>> 1);


    //定义打拍延迟格雷码
    reg [$clog2(DEPTH) : 0] wr_ptr_gr, wr_ptr_grr;
    reg [$clog2(DEPTH) : 0] rd_ptr_gr, rd_ptr_grr;

    //写指针同步到读时钟域
    always @ (posedge rd_clk or negedge rd_rstn) begin
        if(!rd_rstn) begin
            wr_ptr_gr <= 0;
            wr_ptr_grr <= 0;
        end
        else begin
            wr_ptr_gr <= wr_ptr_g;
            wr_ptr_grr <= wr_ptr_gr;
        end
    end

    //读指针同步到写时钟域
    always @ (posedge wr_clk or negedge wr_rstn) begin
        if(!wr_rstn) begin
            rd_ptr_gr <= 0;
            rd_ptr_grr <= 0;
        end
        else begin
            rd_ptr_gr <= rd_ptr_g;
            rd_ptr_grr <= rd_ptr_gr;
        end
    end



    //写满判断
    always @ (posedge wr_clk or negedge wr_rstn) begin
        if(!wr_rstn)
            fifo_full <= 0;
        else if((wr_ptr_g[$clog2(DEPTH)] != rd_ptr_grr[$clog2(DEPTH)]) && (wr_ptr_g[$clog2(DEPTH) - 1] != rd_ptr_grr[$clog2(DEPTH) - 1]) && (wr_ptr_g[$clog2(DEPTH) - 2 : 0] == rd_ptr_grr[$clog2(DEPTH) - 2 : 0]))
            fifo_full <= 1;
        else
            fifo_full <= 0;
    end

    //读空判断
    always @ (posedge rd_clk or negedge rd_rstn) begin
        if(!rd_rstn)
            fifo_empty <= 0;
        else if(wr_ptr_grr[$clog2(DEPTH) : 0] == rd_ptr_g[$clog2(DEPTH) : 0])
            fifo_empty <= 1;
        else
            fifo_empty <= 0;
    end
endmodule