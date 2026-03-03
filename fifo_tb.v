`timescale 1ns/1ps

module fifo_tb;

    parameter WIDTH = 8;
    parameter DEPTH = 4;

    reg clk;
    reg rst;

    reg wr_en;
    reg rd_en;
    reg  [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;

    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    wire overflow;
    wire underflow;

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .overflow(overflow),
        .underflow(underflow)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    reg [WIDTH-1:0] ref_mem [0:DEPTH-2];
    integer ref_wr_ptr;
    integer ref_rd_ptr;
    integer ref_count;
    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, fifo_tb);

        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        ref_wr_ptr = 0;
        ref_rd_ptr = 0;
        ref_count  = 0;

        #20 rst = 0;

        for (i = 0; i < DEPTH-1; i = i + 1) begin
          @(negedge clk);
            wr_en = 1;
            data_in = i;

            ref_mem[ref_wr_ptr] = i;
            ref_wr_ptr = ref_wr_ptr + 1;
            ref_count  = ref_count + 1;
        end

      @(negedge clk);
wr_en = 0;

@(posedge clk);   

if (!full)
    $display("ERROR: FIFO should be full");  
      @(negedge clk);
        wr_en = 1;

      @(negedge clk);
        wr_en = 0;

        if (!overflow)
            $display("ERROR: Overflow not detected");

        for (i = 0; i < DEPTH-1; i = i + 1) begin
          @(negedge clk);
            rd_en = 1;

          @(negedge clk);

            if (data_out !== ref_mem[ref_rd_ptr])
                $display("ERROR: Data mismatch. Expected %0d Got %0d",
                         ref_mem[ref_rd_ptr], data_out);

            ref_rd_ptr = ref_rd_ptr + 1;
            ref_count  = ref_count - 1;

            rd_en = 0;
        end

      @(negedge clk);

if (!empty)
    $display("ERROR: FIFO should be empty");

      @(negedge clk);
        rd_en = 1;

      @(negedge clk);
        rd_en = 0;

        if (!underflow)
            $display("ERROR: Underflow not detected");

        #20 $finish;
    end

endmodule
