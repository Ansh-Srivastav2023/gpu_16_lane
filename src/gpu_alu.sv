module gpu_alu #(parameter WIDTH = 32) (
    input  rst,
    input  [4:0] alu_ctrl,
    input  signed [WIDTH-1:0] rdA, //! received data A
    input  signed [WIDTH-1:0] rdB, //! received data B
    input  is_imm,
    input  [11:0] imm_val,
    
    output Z,
    output N, 
    output P, //! P = Even Parity Flag
    output reg CY,
    output reg signed [WIDTH-1:0] alu_result
    );


    wire [WIDTH-1:0] data1;
    wire [WIDTH-1:0] data2;


    assign data1 = rdA;
    assign data2 = is_imm ? {{20{imm_val[11]}}, imm_val[11:0]} : rdB;


    function automatic signed [WIDTH:0] add_sub (input signed [WIDTH-1:0] dataA, dataB, input is_sub);
        add_sub = {1'b0, dataA} + {1'b0, (dataB ^ {WIDTH{is_sub}})} + is_sub;
    endfunction

    function automatic signed [WIDTH-1:0] rotl (input signed [WIDTH-1:0] dataA, input signed [WIDTH-1:0] dataB);
        rotl = (dataA << dataB) | (dataA >> (32-dataB));
    endfunction

    function automatic signed [WIDTH-1:0] rotr (input signed [WIDTH-1:0] dataA, input signed [WIDTH-1:0] dataB);
        rotr = (dataA >> dataB) | (dataA << (32-dataB));
    endfunction

    always @(*) begin
        alu_result = 0;
        CY = 0;
        if(~rst) begin
            alu_result = 32'b0;
            CY = 0;
        end
        else begin
            case(alu_ctrl) 
            5'd0: {CY, alu_result} = add_sub(data1, data2, 1'b0);
            5'd1: {CY, alu_result} = add_sub(data1, data2, 1'b1);
            5'd2: alu_result = data1 * data2;
            5'd3: alu_result = data1 / data2;
            5'd4: alu_result = data1 & data2;
            5'd5: alu_result = data1 | data2;
            5'd6: alu_result = data1 ^ data2;
            5'd7: alu_result = data1 << data2;
            5'd8: alu_result = data1 >> data2;
            5'd9: alu_result = $signed(data1) >>> data2;
            5'd10: alu_result = rotl(data1, data2);               // rotate left
            5'd11: alu_result = rotr(data1, data2);               // rotate right
            5'd31: alu_result = ~data1;

            default: begin
                alu_result = 0;
                CY = 0;
            end
            endcase
        end
    end

    assign Z = !(|alu_result);
    assign P = !(^alu_result);
    assign N = alu_result[WIDTH-1];

endmodule // gpu_alu

