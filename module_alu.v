
module operacoes (
    input  clk,
    input  wire [2:0] opcode,
    input  wire [15:0] r2,
    input  wire [15:0] r3,
    input  wire [3:0]  D1,       // não usado aqui
    input  wire [6:0]  entrada,  // imediato (MSB = sinal)
    input flag_ram,

    output reg  [15:0] saida,
    output reg fimop
);

parameter INIT_OP = 0, WAIT_OP = 1, RESULTADO = 2;
reg [1:0] estadoOP; 

localparam load = 3'b000,
           add  = 3'b001,
           addi = 3'b010,
           sub  = 3'b011,
           subi = 3'b100,
           mul  = 3'b101;

// Extensão de sinal do imediato (7 -> 16)
wire signed [15:0] imm = {{9{entrada[6]}}, entrada};

// Versões com sinal de r2/r3
wire signed [15:0] r2s = $signed(r2);
wire signed [15:0] r3s = $signed(r3);

// ALU combinacional
reg  signed [15:0] alu;

always @* begin
    INIT_OP: begin
        fimop = 0;
    end

    WAIT_OP: begin
    case (opcode)
        load: alu = imm;
        add : alu = r2s + r3s;
        addi: alu = r2s + imm;
        sub : alu = r2s - r3s;
        subi: alu = r2s - imm;
        mul : alu = r2s * imm;   // resultado truncado para 16 bits
        default: alu = 16'sd0;
    endcase
         
    end

    RESULTADO: begin
        fimop = 1;
    end
end

// Registro da saída (um único estágio)
always @(posedge clk) begin
    case (estadoOP)
        INIT_OP: begin
            estadoOP <= WAIT_OP;
        end
        WAIT_OP: begin
            if (fimop == 1) estadoOP <= RESULTADO;
        end
        RESULTADO: begin
            saida <= alu;
            if (flag_ram) estadoOP <= INIT_OP;   
        end
    endcase

end

endmodule
