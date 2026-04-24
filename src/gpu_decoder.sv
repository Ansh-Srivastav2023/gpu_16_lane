`default_nettype wire

`define NOP             5'b00000
`define RTOR_LOGICAL    5'b00001
`define IMM_LOGICAL     5'b00010
`define ARITHMETIC      5'b00011
`define LOAD            5'b00100
`define BRANCH          5'b00101
`define STORE           5'b00110
`define COMPARE         5'b00111
`define MASK_OPS        5'b01000
`define SYSTEM_OPS      5'b01001
`define EXT_END         5'b11111

module gpu_decoder #(parameter WIDTH = 32) (
        input  wire rst,
        input  wire [4:0] opcode,    //! holds the opcode
        input  wire [3:0] func,

        output reg reg_write,
        output reg mem_write,
        output reg mem_read,
        output reg is_imm,
        output reg is_ext,
        output reg is_end,
        output reg is_branch,
        output reg is_store,
        output reg [1:0] br_type,   //! 00 -> bz, 01 -> bnz, 10 -> j
        output reg [1:0] mask_ops,  //! 00 -> no mask operation, 10 -> mask reset, 11 -> mask with an immediate value
        output reg [4:0] alu_ctrl,
        output reg [3:0] system_ops //! system_ops = 0001 --> cmov, 0010 --> get_laneid, 0100 --> atomadd, 1000 --> redadd
);

    function void rtor_logical_decoder (input [3:0] func, output reg_wt, output [4:0] alu_ctrl);
        reg_wt = 1'b1;
        case (func) 
            4'b0000: alu_ctrl = 5'd31;      // not
            4'b0001: alu_ctrl = 5'd4;       // and
            4'b0010: alu_ctrl = 5'd5;       // or
            4'b0011: alu_ctrl = 5'd6;       // xor
            4'b1001: alu_ctrl = 5'd7;       // shl
            4'b1010: alu_ctrl = 5'd8;       // shr
            4'b1101: alu_ctrl = 5'd10;      // rotl
            4'b1110: alu_ctrl = 5'd11;      // rotr
            default: alu_ctrl = 5'd0;
        endcase
    endfunction

    function void imm_logical_decoder (input [3:0] func, output reg_wt, output is_imm, output [4:0] alu_ctrl);
        reg_wt = 1'b1;
        is_imm = 1'b1;
        case(func)
            4'b0001: alu_ctrl = 5'd4;        // andi
            4'b0010: alu_ctrl = 5'd5;        // ori
            4'b0011: alu_ctrl = 5'd6;        // xori
            4'b1001: alu_ctrl = 5'd7;        // sli
            4'b1010: alu_ctrl = 5'd8;        // sri
            default: alu_ctrl = 5'b0;
        endcase
    endfunction

    function void arithmetic_decoder (input [3:0] func, output reg_wt, is_imm, output [4:0] alu_ctrl);
        reg_wt = 1'b1;
        alu_ctrl = {2'b00, func[2:0]};
        is_imm = func[3];
    endfunction

    function void load_decoder (input [3:0] func, output reg_wt, is_imm, mem_read); // for ld, li and mov
        reg_wt = 1'b1;
        mem_read = func[0];
        is_imm = func[1]; // for li
    endfunction

    function void store_decoder(output mem_wt, is_store, is_imm);
        mem_wt = 1'b1; 
        is_store = 1'b1;
        is_imm = 1'b1;       
    endfunction

    function void branch_decoder (input [3:0] func, output is_branch, is_imm, output [1:0] br_type);
        is_branch = 1'b1;
        is_imm    = func[2];
        br_type   = func[2:1];
    endfunction

    function void compare_decoder(input [3:0] func, output is_imm, output [4:0] alu_ctrl);
        alu_ctrl = 5'd1;            // always subtract and then checks Z and N flag
        is_imm   = func[3];         // selects if immediate or not
    endfunction

    function void mask_decoder(input [3:0] func, output is_imm, output [1:0] mask_ops);
        is_imm = func[1];
        mask_ops = {1'b1, func[1]}; // 10 -> maskrst | 11 -> mask with an immediate value
    endfunction

    function void system_ops_decoder(input [3:0] func, output [3:0] system_ops, output reg_wt, mem_wt);
        system_ops = func;
        reg_wt = ~func[2];
        mem_wt = func[2];
        
    endfunction

    function void ext_end(input [3:0] func, output is_ext, is_end);
        is_ext = func[0];
        is_end = func[1];        
    endfunction

    
    always @(*) begin : main_decoder
        if(~rst) begin
            reg_write   = 0;
            mem_write   = 0;
            is_imm      = 0;
            is_branch   = 0;
            is_store    = 0;
            mask_ops    = 0;
            alu_ctrl    = 0;
            system_ops  = 0;
            is_ext      = 0;
            is_end      = 0;
        end else begin
            reg_write   = 0;
            mem_write   = 0;
            is_imm      = 0;
            is_branch   = 0;
            is_store    = 0;
            mask_ops    = 0;
            alu_ctrl    = 0;
            system_ops  = 0;
            is_ext      = 0;
            is_end      = 0;
            case(opcode)
            `NOP         :    alu_ctrl = 0;
            `RTOR_LOGICAL:    rtor_logical_decoder(func, reg_write, alu_ctrl);
            `IMM_LOGICAL :    imm_logical_decoder(func, reg_write, is_imm, alu_ctrl);
            `ARITHMETIC  :    arithmetic_decoder (func, reg_write, is_imm, alu_ctrl);
            `LOAD        :    load_decoder(func, reg_write, is_imm, mem_read);
            `BRANCH      :    branch_decoder(func, is_branch, is_imm, br_type);
            `STORE       :    store_decoder(mem_write, is_store, is_imm);
            `COMPARE     :    compare_decoder(func, is_imm, alu_ctrl);
            `MASK_OPS    :    mask_decoder(func, is_imm, mask_ops);
            `SYSTEM_OPS  :    system_ops_decoder(func, system_ops, reg_write, mem_write);
            `EXT_END     :    ext_end(func, is_ext, is_end);
            default: begin
                reg_write   = 0;
                mem_write   = 0;
                is_imm      = 0;
                is_branch   = 0;
                is_store    = 0;
                mask_ops    = 0;
                alu_ctrl    = 0;
                system_ops  = 0;
                is_ext      = 0;
                is_end      = 0;
                end
            endcase
        end
    end
endmodule

// module test;

//     reg rst;
//     reg [4:0] opcode;
//     reg [3:0] func;

//     wire reg_write;
//     wire mem_write;
//     wire is_imm;
//     wire is_ext, is_end;
//     wire is_branch;
//     wire is_store;
//     wire [1:0] mask_ops;
//     wire [3:0] system_ops;
//     wire [4:0] alu_ctrl;

//     gpu_decoder dec(
//         rst,
//         opcode,
//         func,

//         reg_write,
//         mem_write,
//         is_imm,
//         is_ext,
//         is_end,
//         is_branch,
//         is_store,
//         mask_ops,
//         system_ops,
//         alu_ctrl
//     );

//     initial begin
//         rst = 0;

//         opcode = 0;
//         func = 1;

//         #10 rst = 1;

//         opcode = `SYSTEM_OPS;
//         #10 

//         opcode = `BRANCH;
//         func   = 2;


//         #10 $finish;
//     end

//     initial begin
//         $monitor("opcode = %b | func = %b | reg_write = %0b | mem_write = %0b | is_imm = %0b | is_ext = %0b | is_end = %0b | is_branch = %0b | is_store = %0b | mask_ops = %b | system_ops = %b | alu_ctrl = %0D", opcode, func, reg_write, mem_write, is_imm, is_ext, is_end, is_branch, is_store, mask_ops, system_ops, alu_ctrl);
//     end    
// endmodule

