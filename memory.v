// certo memoria 
module memoria (
input wire [2:0] opcode,
    input  wire        clk,     // Clock do sistema
    input  wire        enviar, // botao para enviar
    input wire [3:0] r2,
    input  wire [3:0]  D1,    // Endereço (4 bits = 16 registradores)
    input  wire [6:0] entrada,    // Imediato
    output reg [15:0] saida        // Dado de saída (16 bits)
);
    reg [15:0] ram [15:0]; //memoria
    wire [15:0] dado_R1; //valor que será recebido em R1
    wire [15:0] dado_R2;
    wire [15:0] dado_R3;
    wire [15:0] resultado;
    wire flag_ula_wire;
    reg flag_ram = 0; //flag para indicar a operação da ram
    wire r3 = entrada[6:3]; // tirei r3 de input e limito da entrada do imediato


    parameter INIT = 0, WAIT = 1, READ = 2, WRITE = 3;
    reg[1:0] estado_atual = 0; // comeca no INIT


    assign dado_R2 = ram[r2]; //valor no endereço R2
    assign dado_R3 = ram [r3]; //valor no endereço R3
   
    
   
    // Registrador para armazenar o endereço de leitura
    reg [3:0] D1_reg;

    // Inicialização e operação síncrona
    always @(posedge clk) begin
        case(estado_atual)
        INIT: begin
            ram[0]  <= 16'h0000;
            ram[1]  <= 16'h0000;
            ram[2]  <= 16'h0000;
            ram[3]  <= 16'h0000;
            ram[4]  <= 16'h0000;
            ram[5]  <= 16'h0000;
            ram[6]  <= 16'h0000;
            ram[7]  <= 16'h0000;
            ram[8]  <= 16'h0000;
            ram[9]  <= 16'h0000;
            ram[10] <= 16'h0000;
            ram[11] <= 16'h0000;
            ram[12] <= 16'h0000;
            ram[13] <= 16'h0000;
            ram[14] <= 16'h0000;
            ram[15] <= 16'h0000;
            flag_ram <= 0;
            estado_atual <= WAIT;
        end

        WAIT: begin
            if (enviar) begin // botao rever 
                if (opcode == 3'b110) estado_atual <= INIT;
                else estado_atual <= READ;
                end
            end

        READ: begin
            D1_reg <= D1;
            if (flag_ula_wire == 1) begin
                estado_atual <= WRITE;
            end
        end
       
        WRITE: begin
            ram[D1] <= resultado;
            saida <= ram[D1];
            flag_ram <= 1; //ram terminou de escrever
            if (flag_ula_wire == 0) begin
                estado_atual <= WAIT;
            end
        end
        endcase

    end


operacoes operation(
    .clk(clk),
    .opcode(opcode),
    .r2(dado_R2),
    .r3(dado_R3),
    .entrada(entrada),
    .saida(resultado),
    .fimop(flag_ula_wire),
    .flag_ram(flag_ram)
);


endmodule
