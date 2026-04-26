module rslt_src_mux #(parameter WIDTH=32, LANES=16)  (
    input [WIDTH-1:0] alu_result, dmem_rsult,
    input rslt_src,
    output [WIDTH-1:0] result
);

    assign result = rslt_src ? dmem_rsult : alu_result;
    
endmodule
