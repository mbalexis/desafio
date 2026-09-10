# Movimentações de cartões com Spark SQL

POC do desafio de engenharia de dados: ler associado, conta, cartão e movimento no PostgreSQL e gerar `movimento_flat.csv`. Cada linha representa um movimento.

A transformação fica em SQL. Python controla a execução e usa a API do PySpark para conectar por JDBC, registrar visões temporárias e escrever o arquivo.

## Executar em outro computador

Instale Docker Desktop com containers Linux no Windows, ou Docker Engine e Docker Compose no Linux. Inicie o Docker e reserve aproximadamente 4 GB de memória. O primeiro build precisa de internet. Python, Java, Spark e PostgreSQL são instalados nos containers.

Copie o projeto completo, incluindo `.env`, e abra o terminal na pasta `desafio`:

```powershell
docker compose run --build --rm etl
```

Esse comando constrói a imagem, inicia o PostgreSQL, aguarda o healthcheck e executa o ETL. O resultado padrão é `output/movimento_flat.csv`. O container do ETL é removido após a execução; o banco continua ativo. Execute o mesmo comando para gerar novamente o CSV.

## Escolher o diretório de saída

Há duas opções. Ambas gravam o arquivo na pasta do computador disponibilizada ao container pelo Compose, sem incluí-lo na imagem. Execute os comandos na pasta do projeto, com o Docker local.

### Opção 1: configurar no `.env`

Configure a pasta no computador alterando `OUTPUT_DIR` no `.env`:

```dotenv
OUTPUT_DIR=C:/Users/SeuUsuario/Desktop/saida
```

Execute na pasta do projeto:

```powershell
docker compose run --build --rm etl
```

O arquivo será gravado na pasta escolhida, com o nome `movimento_flat.csv`. Use barras `/` nos caminhos Windows. No Linux/macOS, informe um caminho como `/home/usuario/saida`.

### Opção 2: informar na linha de comando

No PowerShell, informe a variável e execute o Compose na mesma linha:

```powershell
$env:OUTPUT_DIR = "C:/Users/SeuUsuario/Desktop/saida"; docker compose run --build --rm etl
```

A variável do terminal tem prioridade sobre o `.env` e permanece definida nessa sessão. Para voltar a usar o `.env` nas próximas execuções:

```powershell
Remove-Item Env:OUTPUT_DIR
```

No Linux/macOS, a variável pode valer somente para o comando:

```bash
OUTPUT_DIR="/home/usuario/saida" docker compose run --build --rm etl
```

O Compose mantém `./output` como padrão quando `OUTPUT_DIR` estiver ausente ou vazio. A pasta do computador é montada em `/output`, caminho usado pelo Python. Não é necessário alterar o script ou o Compose para escolher outra pasta.

## Questões da modelagem

Decisões e diferenças em relação ao PDF:

- `data_criacao_cartao` é exigida na saída, mas não aparece no desenho da origem. Foi adicionada `cartao.data_criacao`.
- O PDF mostra `num_cartao` como `int`. Foi adotado `varchar(19)` para preservar zeros à esquerda e comportar números longos, com validação de 13 a 19 dígitos.
- O tipo `tipo_conta` aparece sem valores definidos. Foram assumidos `CORRENTE` e `POUPANCA`.
- A chave estrangeira composta do cartão garante que sua conta pertença ao mesmo associado. O `UNIQUE (id, id_associado)` em conta permite essa referência no PostgreSQL.
