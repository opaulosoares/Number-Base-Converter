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
