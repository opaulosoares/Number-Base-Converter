# (Função)
# convertDecToHex: Converte da base decimal para base hexadecimal.
# Argumentos ($a0, $a1): Número inteiro em decimal, base a ser convertida.
# Retorno ($v1): Número convertido em formato de string.
convertDecToBase:
	# t0: Tamanho da nova string.
	# t1: Base de destino.
	# t2: Resto da divisão.
	li $t0, 0
	lb $t1, ($a1)

	# Verifica se a base de destino é binario.
	li	$t9, 'B'
	beq $t1, $t9, setBinaryDest

	li	$t9, 'b'
	beq $t1, $t9, setBinaryDest
	
	# Verifica se a base de destino é decimal.
	li	$t9, 'D'
	beq $t1, $t9, setDecimalDest

	li	$t9, 'd'
	beq $t1, $t9, setDecimalDest
	
	# Verifica se a base de destino é hexadecimal.
	li	$t9, 'H'
	beq $t1, $t9, setHexadecimalDest

	li	$t9, 'h'
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
	divu $a0, $t3				# Divide o número de a0 por $t3	(base).
	mflo $a0				# a0: Quociente da divuisao anterior, armazenando no lugar do antigo dividendo.
	mfhi $t2				# t2: Resto da divisão.

	addu $t2, $t2, 48			# Converte o inteiro para sua representação em ASCII (+48).
	addu $sp, $sp, -1			# Reserva um espaço na pilha.
	sb $t2, ($sp)				# Armazena o caractere na pilha.
	addu $t0, $t0, 1			# Incrementa o tamanho da string com o número convertido.

	j convertDecToHex_BeginLoop

#a0: numero a ser convertido para hexadecimal
convertDecToHex_BeginLoop:
	beqz $a0, convertDecToBase_EndLoop
	divu $a0, $t3				# Divide o número de a0 por $t3	(base).
	mflo $a0					# a0: Quociente da divuisao anterior, armazenando no lugar do antigo divuidendo
	mfhi $t2					# t2: Resto da divisão.

	li $t4, 9					# Se 0 <= resto <= 9, tratar como número.
	ble $t2, $t4, isDigit

	li $t4, 15					# Se resto > 9, tratar como letra.
	ble $t2, $t4, isLetter

# (Subrotinas de convertDecToHex_BeginLoop)
# Realiza a conversão do dígito em decimal para hexadecimal
isDigit:
	addu $t2, $t2, 48			# Converte o inteiro para sua representação em ASCII (+48).
	addu $sp, $sp, -1			# Reserva um espaço na pilha.
	sb $t2, ($sp)				# Armazena o caractere na pilha.
	addu $t0, $t0, 1			# Incrementa o tamanho da string com o número convertido.

	j convertDecToHex_BeginLoop

isLetter:
	addu $t2, $t2, 55			# Converte o inteiro para sua representação em ASCII (+55).
	addu $sp, $sp, -1			# Reserva um espaço na pilha.
	sb $t2, ($sp)				# Armazena o caractere na pilha.
	addu $t0, $t0, 1			# Incrementa o tamanho da string com o número convertido.
	
	j convertDecToHex_BeginLoop

convertDecToBase_EndLoop:
	move $t5, $t0				# Reserva o tamanho total da string em outro registrador.

# (Subrotina de convertDecToHex)
# Recupera os valores armazenados na pilha sequencialmente (invertendo o número).
popFromStack:
	beqz $t0, convertDecToHex_End
	
	lb $t4, ($sp)				# Recupera o byte que estava em $sp (parte da resposta).
	sb $t4, ($v1)				# Salva esse byte recuperado na string final da resposta $v1.
	addu $v1, $v1, 1			# Anda uma posição no ponteiro $v1 que estara pronto para receber o novo byte.
	addu $sp, $sp, 1			# Anda uma posição na pilha.
	addu $t0, $t0, -1			# t0: É o tamanho da resultado, quantidade de vezes que sera feito o loop.
	j popFromStack

convertDecToHex_End:
	sub $v1, $v1, $t5			# Volta o registrador para o endereço raiz da string.
	jr $ra
