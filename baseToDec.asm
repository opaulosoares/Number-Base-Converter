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

	lb $t3, ($a0)						# Carrega o byte atual da string
	bgt $t0, $a1, convertDecimal_EXIT

	addu $t3, $t3, -48			# Remove o valor ASCII, deixando só o valor numérico
	mulu $t3, $t2, $t3			# Multiplica o valor numérico carregado com a potência da base
	add $v1, $t3, $v1			# Soma o resultado ao registrador de retorno ($v1)
	mulu $t2, $t1, $t2			# Eleva ao quadrado o valor da potência da base
	
	addu $a0, $a0, -1			# Vai para o próximo byte da string
	addu $t0, $t0, 1			# Incrementa o contador do loop
	
	bgt $t0, 8, checkDecimalOverflow 	#Quando tiver 9 digitos confere para nao dar overflow
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
	bgt $v1, 294967295, Exit_FAILED		# Compara com o maximo valor tirando o numero mais significativo
	
# (Subrotina de convertToDec)
# Realiza a conversão Hexadecimal->Decimal
convertToDecimal_Hex:
	# t3: Byte carregado da string
	# t4: Comparador de se o dígito é um número (0-9) ou letra (A-F)
	#bgt $s6, 8, Exit_FAILED	# Se o numero em hexadecimal tiver mais que 8 digitos é invalido

	lb $t3, ($a0)				# Carrega o byte atual da string
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
	
.include "main.asm"
