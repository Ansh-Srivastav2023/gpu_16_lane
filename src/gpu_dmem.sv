module gpu_dmem #(parameter WIDTH = 32) (
        input clk, rst,
        input [WIDTH-1:0] addr,
        input mem_write, mem_read,
        input [WIDTH-1:0] wt_data,
        output reg [WIDTH-1:0] dout
    );

    reg [31:0] dmem [0:1023];

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            dout <= 'b0;
        end else if(mem_read) begin
            dout <= dmem[addr];
        end else if(mem_write) begin
            dmem[addr] <= wt_data;
        end
    end

endmodule
