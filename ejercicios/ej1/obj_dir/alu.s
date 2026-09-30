/* verilator lint_off IMPORTSTAR */
import tp1_pkg::*;

module alu #(parameter int DATA_WIDTH = 32) (alu_if.alu alu_io);
    logic [DATA_WIDTH-1:0] operand_a, operand_b;
    logic [DATA_WIDTH-1:0] suma, resta, resultado;
    logic carry_suma, overflow_suma, carry_resta, overflow_resta;
    logic carry_resultado, overflow_resultado, opcode_valido;
    logic es_cero, es_negativo;

    assign operand_a = alu_io.operand_a;
    assign operand_b = alu_io.operand_b;
    assign alu_io.result = resultado;

    sumador_flags #(.DATA_WIDTH(DATA_WIDTH)) u_suma (
        .a(operand_a), .b(operand_b), .sum(suma),
        .carry(carry_suma), .overflow(overflow_suma)
    );
    restador_flags #(.DATA_WIDTH(DATA_WIDTH)) u_resta (
        .a(operand_a), .b(operand_b), .resta(resta),
        .carry(carry_resta), .overflow(overflow_resta)
    );
    // Un comparador y un detector de signo compartidos por todas las operaciones.
    comparador #(.DATA_WIDTH(DATA_WIDTH)) u_zero (
        .a(resultado), .b('0), .iguales(es_cero)
    );
    negativo #(.DATA_WIDTH(DATA_WIDTH)) u_negativo (
        .dato(resultado), .negativo(es_negativo)
    );

    // COMPLETAR: las conexiones de las cuatro instancias anteriores.
    // Completar la selección del resultado y de C/V según el opcode.
    always_comb begin
        resultado = '0;
        carry_resultado = 1'b0;
        overflow_resultado = 1'b0;
        opcode_valido = 1'b1;
        case (alu_io.opcode)
            OP_ADD: begin
                // COMPLETAR: seleccionar salidas del sumador.
                    carry_resultado = carry_suma;
                    overflow_resultado = overflow_suma;
                    resultado = suma;

            end
            OP_SUB: begin
                // COMPLETAR: seleccionar salidas del restador.
                    carry_resultado = carry_resta;
                    overflow_resultado = overflow_resta;
                    resultado = resta;
            end
            OP_AND: begin
                // COMPLETAR: operación AND bit a bit.
                    carry_resultado = 1'b0;
                    overflow_resultado = 1'b0;
                    resultado = operand_a & operand_b;
            end
            OP_OR: begin
                // COMPLETAR: operación OR bit a bit.
                    carry_resultado = 1'b0;
                    overflow_resultado = 1'b0;
                    resultado = operand_a | operand_b;
            end
            default: begin
                // COMPLETAR: opcode inválido.
                    carry_resultado = 1'b0;
                    overflow_resultado = 1'b0;
                    resultado = '0;
            end
        endcase
    end

    // COMPLETAR: flags Z/N a partir de los detectores y C/V seleccionadas.
    // Respetar la excepción de opcode inválido (Z/N/C/V = 0100).
    assign alu_io.flags = (alu_io.opcode == OP_ADD) ? '{z: es_cero, n: es_negativo, c: carry_suma,  v: overflow_suma}  :
                          (alu_io.opcode == OP_SUB) ? '{z: es_cero, n: es_negativo, c: carry_resta, v: overflow_resta} :
                          (alu_io.opcode == OP_AND) ? '{z: es_cero, n: es_negativo, c: 1'b0,        v: 1'b0}           :
                          (alu_io.opcode == OP_OR)  ? '{z: es_cero, n: es_negativo, c: 1'b0,        v: 1'b0}           :
                                                      '{z: 1'b0,    n: 1'b1,        c: 1'b0,        v: 1'b0};
endmodule
