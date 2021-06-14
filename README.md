# T1-ORGCOMP
Assembly is my passion
- tratar erros de input
- tratar bit de sinal
- é pra funcional com 32 bits então deve ser tratado o bit de sinal
- checar se o número é maior que 32 bits
- como detectar se é maior que 32 bits?
- possivel detectar se é maior que o INT_MAX é varrendo a string e contando o strlen
- "294.967.295" de "4.294.967.295" -> o primeiro cabe em um registrador de 32 bits, basta verificar o primeiro caractere
