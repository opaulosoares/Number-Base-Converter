# Conversor de bases em Assembly MIPS
# SSC0902 - Organização e Arquitetura de Computadores
#
# Feito por:
# Natan Henrique Sanches (11795680)
# Paulo Henrique de Souza Soares (11884713)
# Alvaro José Lopes (10873365)
# Osni Brito de Jesus (11857330)

.data

	.align 0

	# Constantes
	MAX_BINARY_DIGITS:	.word		34
	BINARY_BASE:		.word		2
	DECIMAL_BASE:		.word		10
	HEXADEC_BASE:		.word		16	
    
	# Mensagem de erro
	erroBaseInvalida:	.asciiz		"Erro: Dados de entrada inválida. Programa finalizado retornando 1.\n"
	
	# Input
	mensagemTitulo:		.asciiz 	"Bem vindo ao conversor de base!\n"
	mensagemOpcoes:		.asciiz 	"Opções: (B)inário	(D)ecimal 	(H)exadecimal\n"
	requerirBaseInput:	.asciiz 	"Digite a letra correspondente à base numérica de origem: "
	entradaNumero:		.asciiz 	"Digite o número para conversão: "
	requerirBaseOutput:	.asciiz 	"Digite a letra correspondente à base númerica de destino: "
	
	# Output
	mensagemResultado:	.asciiz 	"O número convertido é: "
    
		
.text
		.globl main
		
main:

	jal getInputs				# Recebe os inputs que serão trabalhados
	
	move $a0, $s2				# Argumento 1: Endereço da string do número dado de entrada
	jal stringLength
	move $s6, $v1
	
	move $a0, $s2				# Argumento 1: Endereço da string do número dado de entrada
	move $a1, $s6				# Argumento 2: Tamanho da string do número dado de entrada
	addu $a1, $a1, -1
	move $a2, $s0				# Argumento 3: Endereço da string da base de entrada
	jal convertToDec			# Realiza o pré-processamento e a conversão do número de entrada para decimal
	
	
	# Reserva espaço para armazenar a string com o número convertido
	li $v0, 9
	lw $a0, MAX_BINARY_DIGITS
	syscall

	move $a0, $v1				# Passa o retorno da função convertToDec como parâmetro para a função convertDecToHex
	move $a1, $s4
	move $v1, $v0				# Liga o espaço de memória dinâmico ao registrador de retorno da função
	jal convertDecToBase
	
	move $s2, $v1
	j Exit_SUCCESS

# (Subrotinas de main)
Exit_SUCCESS:
	
	# Exibe a mensagem e o número convertido na tela
	li $v0, 4
    la $a0, mensagemResultado
	syscall
	move $a0, $s2
	syscall

	# Termino do programa
    li $v0, 10
    syscall

Exit_FAILED:

	li $v0, 4
    la $a0, erroBaseInvalida
	syscall

	li $v0, 10
	syscall
	
.include "getInputs.asm"
.include "baseToDec.asm"
.include "decToBase.asm"
.include "utils.asm"
