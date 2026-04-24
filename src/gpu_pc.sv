module gpu_pc(
    input clk,
    input rst,
    input pc_stall,
    input branch_taken,
    output reg signed [31:0] pc,
    input signed [11:0] branch_offset
);

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            pc <= 32'b0;
        end else if (pc_stall) begin
            pc <= pc;
        end else begin
            if (branch_taken) begin
                pc <= pc + branch_offset;
            end else begin
                pc <= pc + 32'd4;
            end
        end
    end
endmodule // gpu_pc
