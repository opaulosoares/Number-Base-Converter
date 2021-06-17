.data

	.align 0

	# Constantes
	MAX_BINARY_DIGITS:	.word		33
	BINARY_BASE:		.word		2
	DECIMAL_BASE:		.word		10
	HEXADEC_BASE:		.word		16	
    
	# Mensagens de erro
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

# (Subrotina de main)
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

# (Função)
# convertDecToHex: Converte da base decimal para base hexadecimal
# Argumentos ($a0, $a1): Número inteiro em decimal, base a ser convertida
# Retorno ($v1): Número convertido em formato de string
convertDecToBase:
	# t0: Tamanho da nova string
	# t1: Base de destino
	# t2: Resto da divuisão
	li $t0, 0
	lb $t1, ($a1)

	# Verifica se a base de destino é binario
	li $t9, 66					
	beq $t1, $t9, setBinaryDest
	
	# Verifica se a base de destino é decimal
	li $t9, 68
	beq $t1, $t9, setDecimalDest
	
	# Verifica se a base de destino é hexadecimal
	li $t9, 72
	beq $t1, $t9, setHexadecimalDest

setBinaryDest:
	
	lw $t3, BINARY_BASE
	j convertDecToHex_BeginLoop

setDecimalDest:
	
	lw $t3, DECIMAL_BASE
	j convertDecToHex_BeginLoop

setHexadecimalDest:
	
	lw $t3, HEXADEC_BASE
	j convertDecToHex_BeginLoop
	

convertDecToBase_BeginLoop:
	beqz $a0, convertDecToBase_EndLoop
	divu $a0, $t3				# Divide o numero de a0 por $t3	(base)
	mflo $a0					# a0: Quociente da divuisao anterior, armazenando no lugar do antigo divuidendo
	mfhi $t2					# t2: Resto da divuisao 

	addu $t2, $t2, 48			# Converte o inteiro para sua representação em ASCII (+48)
	addu $sp, $sp, -1			# Reserva um espaço na pilha
	sb $t2, ($sp)				# Armazena o caractere na pilha
	addu $t0, $t0, 1			# Incrementa o tamanho da string com o número convertido

	j convertDecToHex_BeginLoop

#a0: numero a ser convertido para hexadecimal
convertDecToHex_BeginLoop:
	beqz $a0, convertDecToBase_EndLoop
	divu $a0, $t3				# Divide o numero de a0 por $t3	(base)
	mflo $a0					# a0: Quociente da divuisao anterior, armazenando no lugar do antigo divuidendo
	mfhi $t2					# t2: Resto da divuisao 

	li $t4, 9					# Se 0 <= resto <= 9, tratar como número
	ble $t2, $t4, isDigit

	li $t4, 15					# Se resto > 9, tratar como letra
	ble $t2, $t4, isLetter

# (Subrotinas de convertDecToHex_BeginLoop)
# Realiza a conversão do dígito em decimal para hexadecimal
isDigit:
	addu $t2, $t2, 48			# Converte o inteiro para sua representação em ASCII (+48)
	addu $sp, $sp, -1			# Reserva um espaço na pilha
	sb $t2, ($sp)				# Armazena o caractere na pilha
	addu $t0, $t0, 1			# Incrementa o tamanho da string com o número convertido

	j convertDecToHex_BeginLoop

isLetter:
	addu $t2, $t2, 55			# Converte o inteiro para sua representação em ASCII (+55)
	addu $sp, $sp, -1			# Reserva um espaço na pilha
	sb $t2, ($sp)				# Armazena o caractere na pilha
	addu $t0, $t0, 1			# Incrementa o tamanho da string com o número convertido
	
	j convertDecToHex_BeginLoop

convertDecToBase_EndLoop:
	move $t5, $t0				# Reserva o tamanho total da string em outro registrador

# (Subrotina de convertDecToHex)
# Recupera os valores armazenados na pilha sequencialmente (invertendo o número)
popFromStack:
	beqz $t0, convertDecToHex_End
	
	lb $t4, ($sp)				# Recupera o byte que estava em $sp (parte ta resposta)
	sb $t4, ($v1)				# Salva esse byte recuperado na string final da resposta $v1
	addu $v1, $v1, 1			# Anda uma posição no ponteiro $v1 que estara pronto para receber o novo byte
	addu $sp, $sp, 1			# Anda uma posição na pilha
	addu $t0, $t0, -1			# t0: É o tamanho da resultado, quantidade de vezes que sera feito o loop
	j popFromStack

convertDecToHex_End:
	sub $v1, $v1, $t5			# Volta o registrador para o endereço raiz da string
	jr $ra


# (Função)
# stringLength: Informa o tamanho da string
# Argumentos ($a0): endereço da string
# Retorno ($v1): tamanho da string
stringLength:
	li $v1, 0				
	li $t1, 10

stringLength_beginLoop:
	lb $t0, ($a0)
	beq $t0, $t1, stringLength_endLoop
	addu $v1, $v1, 1
	addu $a0, $a0, 1
	j stringLength_beginLoop

stringLength_endLoop:
	jr $ra 

# (Função)
# convertToDec: Converte um número numa base qualquer para decimal
# Parâmetros ($a0, $a1, $a2): Endereço da string do número, tamanho da string, base de origem
# Retorno ($v1): Número convertido para decimal
convertToDec:
	# t0: Contador do loop
	# t1: Valor da base
	# v1: Decimal de retorno
	li $t0, 0			
	li $t2, 1
	li $v1, 0
	add $a0, $a0, $a1
	lb $t8, ($a2)		

	# Verifica se a base de origem é binario
	li $t9, 66					
	beq $t8, $t9, setBinaryOrig
	
	# Verifica se a base de origem é decimal
	li $t9, 68
	beq $t8, $t9, setDecimalOrig
	
	# Verifica se a base de origem é hexadecimal
	li $t9, 72
	beq $t8, $t9, setHexadecimalOrig 

# (Subrotina de convertToDec)
# Define a base a ser usada com base no parâmetro de entrada
setBinaryOrig:
	
	lw $t1, BINARY_BASE
	j convertDecimal

setDecimalOrig:
	
	lw $t1, DECIMAL_BASE
	j convertDecimal

setHexadecimalOrig:
	
	lw $t1, HEXADEC_BASE
	j convertToDecimal_Hex

# (Subrotina de convertToDec)
# Realiza a conversão Binário->Decimal (e Decimal->Decimal)
convertDecimal:
	# t2: Acumuluador intermediário
	# t3: Byte carregado da string

	lb $t3, ($a0)			# Carrega o byte atual da string
	bgt $t0, $a1, convertDecimal_EXIT

	addu $t3, $t3, -48		# Remove o valor ASCII, deixando só o valor numérico
	mulu $t3, $t2, $t3		# Multiplica o valor numérico carregado com a potência da base
	add $v1, $t3, $v1		# Soma o resultado ao registrador de retorno ($v1)
	mulu $t2, $t1, $t2		# Eleva ao quadrado o valor da potência da base
	
	addu $a0, $a0, -1		# Vai para o próximo byte da string
	addu $t0, $t0, 1		# Incrementa o contador do loop
	
	bgt $t0, 8, checkDecimalOverflow #Quando tiver 9 digitos confere para nao dar overflow
	j convertDecimal

# Confere se o decimal ultrapassa o limite de 4 bytes
# Entra com o numero decimal em $a0 contendo 9 digitos
checkDecimalOverflow:
	lb $t3, ($a0)						# $t3: Valor mais significativo de $a0
	bgt $t3, 52, Exit_FAILED			# Se $t3 for superior a 4 (52 - ASCII) seria overflow
	beq $t3, 52, lessDecimalOverflow	# Caso seja igual a 4, é necessario outra verificação

# Caso o numero decimal tenha 9 digitos
# E o mais significativo seja 4
# Como o numero max permitido é 4294967295
lessDecimalOverflow:
	bgt $v1, 294967295, Exit_FAILED	# Compara com o maximo valor tirando o numero mais significativo
	
# (Subrotina de convertToDec)
# Realiza a conversão Hexadecimal->Decimal
convertToDecimal_Hex:
	# t3: Byte carregado da string
	# t4: Comparador de se o dígito é um número (0-9) ou letra (A-F)
	#bgt $s6, 8, Exit_FAILED		# Se o numero em hexadecimal tiver mais que 8 digitos é invalido

	lb $t3, ($a0)			# Carrega o byte atual da string
	bgt $t0, $a1, convertDecimal_EXIT
	
	# Se o dígito em hexadecimal estiver entre 0 e 9
	li $t4, 57				# 57 = '9'
	ble $t3, $t4, Hex_isDigit
	
	# Se o dígito em hexadecimal estiver entre A e F
	li $t4, 70				# 70 = 'F'
	ble $t3, $t4, Hex_isChar
	
# (Subrotinas de convertToDecimal_Hex)
# Realiza a conversão do dígito em hexadecial para decimal
Hex_isDigit:
	# t2: Acumuluador intermediário
	addu $t3, $t3, -48		# Remove o valor ASCII (-48), deixando só o valor numérico
	mulu $t3, $t2, $t3		# Multiplica o valor numérico carregado com a potência da base
	add $v1, $t3, $v1		# Soma o resultado ao registrador de retorno ($v0)
	mulu $t2, $t1, $t2		# Eleva ao quadrado o valor da potência da base
	addu $a0, $a0, -1		# Vai para o próximo byte da string
	addu $t0, $t0, 1		# Incrementa o contador do loop
	
	j convertToDecimal_Hex

Hex_isChar:
	# t2: Acumuluador intermediário
	addu $t3, $t3, -55		# Remove o valor ASCII (-65), deixando só o valor numérico + 10
	mulu $t3, $t2, $t3		# Multiplica o valor numérico carregado com a potência da base
	add $v1, $t3, $v1		# Soma o resultado ao registrador de retorno ($v0)
	mulu $t2, $t1, $t2		# Eleva ao quadrado o valor da potência da base
	addu $a0, $a0, -1		# Vai para o próximo byte da string
	addu $t0, $t0, 1		# Incrementa o contador do loop
	
	j convertToDecimal_Hex
	
convertDecimal_EXIT:
	
	jr $ra
	
# (Função)
# getInputs: Recebe os inputs de entrada.
# Parâmetros: nenhum.
# Retorno:
# 	$s0: Endereço da string da base de origem
# 	$s1: Tamanho de $s0
# 	$s2: Endereço da string do número a ser convertido
# 	$s3: Tamanho de $s2
# 	$s4: Endereço da string da base de destino
# 	$s5: Tamanho de $s4
getInputs:

	# Salva a referência da main na pilha
	addu $sp, $sp, -4
	sw $ra, ($sp)		

	# Exibe a mensagem de título na tela	
	li $v0, 4
    la $a0, mensagemTitulo
    syscall
    
    # Exibe a mensagem de opções na tela
	li $v0, 4
    la $a0, mensagemOpcoes
    syscall
    
    # Requere a entrada da base de origem
	li $v0, 4
    la $a0, requerirBaseInput
    syscall
    
    # Lê o caractere da base de entrada
    # $s0 = String pointer
    # $s1 = String length
    li $v0, 8
    li $a1, 10
	syscall

	# Checa a validade da string de entrada
	jal checkBaseInput

    move $s0, $a0		# Mover o endereço de a0 para s0
    move $s1, $a1		# Mover o endereço de a1 para s1
    
    # Requere o número a ser convertido
	li $v0, 4
    la $a0, entradaNumero
    syscall
    
    # Lê o número de entrada
    # $s2 = String pointer
    # $s3 = String length
    li $v0, 8
    lw $a1, MAX_BINARY_DIGITS
    syscall

	# Checa a validade da string de entrada
	jal checkNumberInput

    move $s2, $a0		# Mover o endereço de a0 para s2
    move $s3, $a1		# Mover o endereço de a1 para s3

	# Requere a entrada da base de destino
	li $v0, 4
    la $a0, mensagemOpcoes
    syscall
    la $a0, requerirBaseOutput
    syscall

    # Lê o caractere da base de saída
    # $s4 = String pointer
    # $s5 = String length
    li $v0, 8
    li $a1, 10
    syscall

	# Checa a validade da string de entrada
	jal checkBaseInput

    move $s4, $a0		# Mover o endereço de a0 para s4
    move $s5, $a1		# Mover o endereço de a1 para s5

	lw $ra, ($sp) 		# Recupera o endereço de retorno da main
    	
    jr $ra
	
# (Subrotina de getInput)
# Checa se o número informado de entrada é compatível com a base escolhida
checkNumberInput:

	# t0: Base dada de entrada
	# t1: Registrador temporário para comparação
	# t2: Endereço da string do número de entrada
	lb $t0, ($s0)		# Carrega a base proposta de entrada
	la $t2, ($a0)		# Carrega o endereço da string do número

	# Verifica se a base de origem é binária
	li $t1, 66			# 66 = 'B'
	beq $t0, $t1, checkBinary
	
	# Verifica se a base de origem é decimal
	li $t1, 68			# 68 = 'D'
	beq $t0, $t1, checkDecimal
	
	# Verifica se a base de origem é hexadecimal
	li $t1, 72			# 72 = 'H'
	li $t9, 0
	beq $t0, $t1, checkHexadecimal

# Confere se todos os dígitos estão entre 0 e 1
checkBinary:
	
	li $t1, 10			# 10 = '\n'
	lb $t3, ($t2)		# Carrega o byte atual da string do número
	beq	$t1, $t3, return_SUCCESS

	# Se menor que 0, indicar falha.
	li $t1, 48			# 48 = '0'
	blt $t3, $t1, Exit_FAILED
	
	# Se maior que 1, indicar falha.
	li $t1, 49 			# 49 = '1'
	bgt $t3, $t1, Exit_FAILED
	
	addu $t2, $t2, 1	# Incrementa o ponteiro da string
	j checkBinary

# Confere se todos os dígitos estão entre 0 e 9
checkDecimal:

	li $t1, 10			# 10 = '\n'
	lb $t3, ($t2)		# Carrega o byte atual da string do número
	beq	$t1, $t3, return_SUCCESS

	# Se menor que 0, indicar falha.
	li $t1, 48			# 48 = '0'
	blt $t3, $t1, Exit_FAILED
	
	# Se maior que 9, indicar falha.
	li $t1, 57 			# 57 = '9'
	bgt $t3, $t1, Exit_FAILED
	
	addu $t2, $t2, 1	# Incrementa o ponteiro da string
	
	j checkDecimal
		
# Confere se todos os dígitos estão entre 0 e 9 ou A e F
checkHexadecimal:

	
	li $t1, 10	
	lb $t3, ($t2)
	beq	$t1, $t3, return_SUCCESS

	# Se menor que 0, indicar falha.
	li $t1, 48			# 48 = '0'
	blt $t3, $t1, Exit_FAILED
	
	# Se maior que 9, checar se é letra.
	li $t1, 57  		# 57 = '9'
	bgt $t3, $t1, checkHexadecimal_secondCheck

	# Se chegar nesse bloco, o dígito está entre 0 e 9
	addu $t2, $t2, 1
	
	j checkHexadecimal


checkHexadecimal_secondCheck:
	
	
	# Se menor que 'A', indicar falha.
	li $t1, 65  		# 65 = 'A'
	blt $t3, $t1, Exit_FAILED

	# Se maior que 'F', indicar falha.
	li $t1, 70  		# 70 = 'F'
	bgt $t3, $t1, Exit_FAILED

	# Se chegar nesse bloco, o dígito está entre A e F
	addu $t2, $t2, 1
	addu $t9, $t9, 1		# Contador do tamanho da string que contem o numero em hexadecimal
	bgt $t9, 8, Exit_FAILED		# Se o numero em hexadecimal tiver mais que 8 digitos é invalido
	
	j checkHexadecimal

# (Subrotina de getInput)
# Checa se a base informada de entrada é compatível com as opções e a formatação proposta
checkBaseInput:

	lb $t0, ($a0)

	# Verifica se a base de origem é binario
	li $t1, 66			# 66 = 'B'			
	beq $t0, $t1, checkStringInput
	
	# Verifica se a base de origem é decimal
	li $t1, 68  		# 68 = 'D'
	beq $t0, $t1, checkStringInput
	
	# Verifica se a base de origem é hexadecimal
	li $t1, 72  		# 72 = 'H'
	beq $t0, $t1, checkStringInput

	j Exit_FAILED

# Checa se a formatação está como o esperado
checkStringInput:
	
	lb $t0, 1 ($a0)		# Pega 1 byte após o primeiro byte da string
	li $t1, 10  		# 10 = '\n'
	beq $t0, $t1, return_SUCCESS

	j Exit_FAILED

return_SUCCESS:

	jr $ra
