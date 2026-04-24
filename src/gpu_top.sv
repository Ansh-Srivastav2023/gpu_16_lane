module gpu_top #(parameter WIDTH=32, LANES=16) 
                (input clk, rst,
                output [LANES-1:0] Z);

    wire [4:0] alu_ctrl;
    wire [LANES-1:0] N, CY, P;
    wire [LANES*WIDTH-1:0] alu_data1, alu_data2;
    wire [LANES*WIDTH-1:0] alu_result;
    wire [11:0] imm_val;

    wire [WIDTH-1:0] instruction;
    wire [WIDTH-1:0] pc;

    wire is_imm;
    wire pc_stall;
    wire is_ext, is_end, is_store;
    wire is_branch, mem_write;
    wire mem_read, reg_write;

    wire branch_taken, ps_stall;
    wire [11:0] branch_offset;

    reg Z_out;

    assign imm_val = {instruction[15:12], instruction[7:0]};
    
    // gpu alus
    genvar alu_i;
    generate
        for(alu_i=0; alu_i<LANES; alu_i++) begin : ALU_array
            gpu_alu alu_inst (.rst(rst), 
                        .alu_ctrl(alu_ctrl), 
                        .rdA(alu_data1[alu_i*WIDTH +: WIDTH]), 
                        .rdB(alu_data2[alu_i*WIDTH +: WIDTH]),
                        .Z(Z[alu_i]), 
                        .N(N[alu_i]), 
                        .P(P[alu_i]),
                        .is_imm(is_imm),
                        .imm_val(imm_val),
                        .CY(CY[alu_i]), 
                        .alu_result(alu_result[alu_i*WIDTH +: WIDTH]));
        end
    endgenerate


    // holding the zero
    wire [LANES-1:0] delayed_Z;
    buf #2 b0 (delayed_Z, Z);
    always @(posedge clk) begin
        if(~rst)
            Z_out <= 0;
        else
            Z_out <= &delayed_Z;
    end
    assign branch_taken = is_branch & Z_out;


    // gpu instruction memory
    gpu_instr_mem gpu_instr_mem(.clk(clk), 
        .rst(rst),
        .pc(pc),
        .instruction(instruction));


    // gpu pc
    gpu_pc gpu_pc (.clk(clk), .rst(rst), 
        .pc(pc), 
        .branch_taken(branch_taken), 
        .pc_stall(pc_stall),
        .branch_offset(branch_offset));


    // gpu decoder
    gpu_decoder gpu_decoder(.rst(rst),
        .opcode(instruction[31-:5]),
        .func(instruction[11-:4]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .is_imm(is_imm),
        .is_ext(is_ext),
        .is_end(is_end),
        .is_branch(is_branch),
        .is_store(is_store),
        .br_type(br_type),
        .mask_ops(mask_ops),
        .alu_ctrl(alu_ctrl),
        .system_ops(system_ops));


    // gpu_dmem
    genvar dmem_i;
    generate
        for (int dmem_i=0; dmem_i<LANES; ++dmem_i) begin
            gpu_dmem gpu_dmem(
                .clk(clk), .rst(rst), 
                .addr(alu_result[dmem_i*WIDTH+:WIDTH]),
                .mem_write(mem_write),
                .mem_read(mem_read),
                .wt_data(wt_data),
                .dout(dout));
        end        
    endgenerate


endmodule
