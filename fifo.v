
module fifo #(
    parameter WIDTH =8,
    parameter DEPTH=8
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
  	input wire [WIDTH-1:0] data_in,
  	output reg [WIDTH-1:0] data_out,
    output wire full,
    output wire empty,
    output wire almost_full,
    output wire almost_empty,
    output reg overflow,
    output reg underflow
);
    localparam PTR_WIDTH = $clog2(DEPTH) ;
  
    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;

    reg[$clog2(DEPTH):0]count;
  	reg [WIDTH-1:0] mem [0:DEPTH-1];

    wire write_allowed;
    wire read_allowed;

    assign write_allowed=wr_en && !full;
    assign read_allowed=rd_en && !empty;

    assign full=(count==DEPTH-1);
    assign empty=(count==0);
    assign almost_empty=(count==1);
    assign almost_full=(count==DEPTH-2);

    always @(posedge clk)begin
        if (rst) begin
            wr_ptr<=0;
            rd_ptr<=0;
            count<=0;
            data_out<=0;
            overflow<=0;
            underflow<=0;
        end else begin
            overflow<=wr_en && full;
            underflow<=rd_en && empty;

            if(write_allowed)begin
                mem[wr_ptr]<=data_in;
                wr_ptr<=(wr_ptr==DEPTH-1)?0:wr_ptr+1;
            end

            if(read_allowed)begin
                data_out<=mem[rd_ptr];
                rd_ptr<=(rd_ptr==DEPTH-1)?0:rd_ptr+1;
            end

            case ({write_allowed,read_allowed})
                2'b10:count<=count+1;
                2'b01:count<=count-1;
                default:count<=count;
            endcase
        end
    end
endmodule

