module sync_fifo (clk, rst, wirte_enable, read_enable, write_data, read_data,empty, full);
  input       clk;
  input       rst;
  input       wirte_enable;
  input       read_enable;
  input [7:0] write_data;
  output      empty;
  output      full;
  output [7:0] read_data;
  reg    [7:0]  mem[15:0]; //16×8 RAM
  reg    [7:0]  read_data;
  wire   [3:0]  write_addr_a, read_addr_a; // accessing address
  reg    [4:0]  write_addr_e, read_addr_e; // extended address

  // extended address add one MSB bit than accessing address
  // write_addr_e[4] & read_addr_e[4] are used for empty/full flag generation
  assign write_addr_a = write_addr_e[3:0];
  assign read_addr_a  = read_addr_e[3:0];

  //read operation
  always @ (posedge clk, negedge rst )  begin
    if(!rst) begin
      read_addr_e <= 5'b0;
    end else begin
      if(empty == 0 && read_enable == 1) begin // reading condition :not empty and read enable
        read_data <= mem[read_addr_a];
        read_addr_e <= read_addr_e + 1;
      end
    end
  end //read operation 

      // write operation 
      always @ (posedge clk , negedge rst) begin
        if (!rst) begin
          write_addr_e <= 5'b0;
        end else begin
          if(full == 0 && wirte_enable == 1) begin //writing condition: not full and write enable
            mem[write_addr_a] <= write_data;
            write_addr_e <= write_addr_e + 1;
          end
        end
      end // wirte operation

      // empty and full status flag generation
      assign empty = (read_addr_e == write_addr_e)  ? 1 : 0;
      assign full = (read_addr_e[4] != write_addr_e[4] && read_addr_e[3:0] == write_addr_e[3:0])  ? 1:  0;

endmodule 











