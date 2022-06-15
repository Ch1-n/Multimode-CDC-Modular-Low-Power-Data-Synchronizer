// --------------------------------------
// FileName: fifo_async_tb
// Auther: Ch'in
// Email: kvinkin@qq.com
// Function:
// Version: 1.0
// Date: 2022年5月9日21:45:37
// Copyright:https://github.com/Ch1-n
// --------------------------------------
module asy_myfifo_tb;
    parameter   WIDTH = 8;
    parameter   DEPTH = 8;

    reg wr_clk, wr_en, wrst_n;
    reg rd_clk, rd_en, rrst_n;

    reg [WIDTH - 1 : 0] wr_data;

    wire full, empty;

    wire [WIDTH - 1 : 0] rd_data;

    //实例化
        fifo_async fifo_async (
            .wr_clk(wr_clk),
            .rd_clk(rd_clk),
            .wrst_n(wrst_n),
            .rrst_n(rrst_n),
            .wr_en(wr_en),
            .rd_en(rd_en),
            .wr_data(wr_data),
            .rd_data(rd_data),
            .empty(empty),
            .full(full)
        );


    //时钟
    initial begin
        rd_clk = 0;
        forever #25 rd_clk = ~rd_clk;
    end

    initial begin
        wr_clk = 0;
        forever #30 wr_clk = ~wr_clk;
    end

    //波形显示
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, fifo_async);
        $fsdbDumpon();
    end

    //赋值
    initial begin
        wr_en = 0;
        rd_en = 0;
        wrst_n = 1;
        rrst_n = 1;

        #10;
        wrst_n = 0;
        rrst_n = 0;

        #20;
        wrst_n = 1;
        rrst_n = 1;

        @(negedge wr_clk)
        wr_data = {$random}%30;//产生0-29之间的正数
        wr_en = 1;

        repeat(7) begin
            @(negedge wr_clk)
            wr_data = {$random}%30;
        end

        @(negedge wr_clk)
        wr_en = 0;

        @(negedge rd_clk)
        rd_en = 1;

        repeat(7) begin
            @(negedge rd_clk);
        end

        @(negedge rd_clk)
        rd_en = 0;

        #150;

        @(negedge wr_clk)
        wr_en = 1;
        wr_data = {$random}%30;

        repeat(15) begin
            @(negedge wr_clk)
            wr_data = {$random}%30;
        end

        @(negedge wr_clk)
        wr_en = 0;

        #50;
        $finish;
    end

endmodule