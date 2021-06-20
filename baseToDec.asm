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

	# Verifica se a base de origem é binario.
	li 	$t1, 'B'
	beq $t8, $t1, setBinaryOrig

	li 	$t1, 'b'
	beq $t8, $t1, setBinaryOrig
	
	# Verifica se a base de origem é decimal.
	li 	$t1, 'D'
	beq $t8, $t1, setDecimalOrig

	li 	$t1, 'd'
	beq $t8, $t1, setDecimalOrig
	
	# Verifica se a base de origem é hexadecimal.
	li 	$t1, 'H'
	beq $t8, $t1, setHexadecimalOrig

	li 	$t1, 'h'
	beq $t8, $t1, setHexadecimalOrig
	

# (Subrotina de convertToDec)
# Define a base a ser usada com base no parâmetro de entrada.
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
# Realiza a conversão Binário -> Decimal (e Decimal -> Decimal).
convertDecimal:
	# t2: Acumuluador intermediário.
	# t3: Byte carregado da string.

	lb $t3, ($a0)			        # Carrega o byte atual da string.
	bgt $a1, 10, Exit_FAILED_Overflow 	# Se o tamanho da string for maior que 10, retorna erro.
	beq $t0, 9, checkDecimalOverflow 	# Quando tiver 9 digitos, confere para não dar overflow.
	bgt $t0, $a1, convertDecimal_EXIT

	addu $t3, $t3, -48			# Remove o valor ASCII, deixando só o valor numérico.
	mulu $t3, $t2, $t3			# Multiplica o valor numérico carregado com a potência da base.
	add $v1, $t3, $v1			# Soma o resultado ao registrador de retorno ($v1).
	mulu $t2, $t1, $t2			# Eleva ao quadrado o valor da potência da base.
	
	addu $a0, $a0, -1			# Vai para o próximo byte da string.
	addu $t0, $t0, 1			# Incrementa o contador do loop.
	
	bgt $t0, 8, checkDecimalOverflow 	# Quando tiver 9 digitos, confere para não dar overflow.
	j convertDecimal

# Confere se o decimal ultrapassa o limite de 4 bytes.
# Entra com o número decimal em $a0 contendo 9 dígitos.
checkDecimalOverflow:
	lb $t3, ($a0)				# $t3: Valor mais significativo de $a0.
	bgt $t3, 52, Exit_FAILED_Overflow	# Se $t3 for superior a 4 (52 - ASCII) seria overflow.
	beq $t3, 52, lessDecimalOverflow	# Caso seja igual a 4, é necessario outra verificação.

# Caso o número decimal tenha 9 dígitos.
# E o mais significativo seja 4.
# Como o número máximo permitido é 4294967295.
lessDecimalOverflow:
	bgt $v1, 294967295, Exit_FAILED_Overflow	# Compara com o maximo valor tirando o número mais significativo.
	
# (Subrotina de convertToDec)
# Realiza a conversão Hexadecimal->Decimal
convertToDecimal_Hex:
	# t3: Byte carregado da string.
	# t4: Comparador de se o dígito é um número (0-9) ou letra (A-F).
	#bgt $s6, 8, Exit_FAILED	# Se o número em hexadecimal tiver mais que 8 digitos é inválido.

	lb $t3, ($a0)				# Carrega o byte atual da string.
	bgt $t0, $a1, convertDecimal_EXIT
	
	# Se o dígito em hexadecimal estiver entre 0 e 9
	li $t4, '9'					# 57 = '9'
	ble $t3, $t4, Hex_isDigit
	
	# Se o dígito em hexadecimal estiver entre A e F
	li $t4, 'F'					# 70 = 'F'
	ble $t3, $t4, Hex_isChar
	
# (Subrotinas de convertToDecimal_Hex)
# Realiza a conversão do dígito em hexadecial para decimal.
Hex_isDigit:
	# t2: Acumuluador intermediário
	addu $t3, $t3, -48		# Remove o valor ASCII (-48), deixando só o valor numérico.
	mulu $t3, $t2, $t3		# Multiplica o valor numérico carregado com a potência da base.
	add $v1, $t3, $v1		# Soma o resultado ao registrador de retorno ($v0).
	mulu $t2, $t1, $t2		# Eleva ao quadrado o valor da potência da base.
	addu $a0, $a0, -1		# Vai para o próximo byte da string.
	addu $t0, $t0, 1		# Incrementa o contador do loop.
	
	j convertToDecimal_Hex

Hex_isChar:
	# t2: Acumuluador intermediário
	addu $t3, $t3, -55		# Remove o valor ASCII (-65), deixando só o valor numérico + 10.
	mulu $t3, $t2, $t3		# Multiplica o valor numérico carregado com a potência da base.
	add $v1, $t3, $v1		# Soma o resultado ao registrador de retorno ($v0).
	mulu $t2, $t1, $t2		# Eleva ao quadrado o valor da potência da base.
	addu $a0, $a0, -1		# Vai para o próximo byte da string.
	addu $t0, $t0, 1		# Incrementa o contador do loop.
	
	j convertToDecimal_Hex
	
convertDecimal_EXIT:
	
	jr $ra

