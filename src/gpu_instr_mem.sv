module gpu_instr_mem #(parameter WIDTH = 32) (
    input clk, rst,
    input [WIDTH-1:0] pc,
    output reg [WIDTH-1:0] instruction);

    reg [31:0] instr_mem [0:63];

    always @(posedge clk) begin
        if(~rst) 
            instruction <= instr_mem[0];
        else
            instruction <= instr_mem[pc];
    end

endmodule
