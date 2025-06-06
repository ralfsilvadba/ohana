# Monitoramento Proativo de Banco de Dados

Este projeto fornece uma interface web para monitorar proativamente bancos de dados. O frontend é construído com HTML, CSS e JavaScript e está preparado para ser hospedado no GitHub Pages. O backend é uma API simples em Python utilizando Flask.

## Estrutura

- `frontend/` - arquivos estáticos para a interface web.
- `backend/` - aplicação Flask com APIs para login e gerenciamento de alertas.

## Como Executar o Backend

1. Instale as dependências:
   ```bash
   pip install -r backend/requirements.txt
   ```
2. Defina as variáveis de ambiente de conexão com o MySQL (ou utilize a variável `DATABASE_URL` fornecida pela Railway):
   ```bash
   export MYSQLHOST=<host>
   export MYSQLUSER=<usuario>
   export MYSQLPASSWORD=<senha>
   export MYSQLDATABASE=<banco>
   export MYSQLPORT=<porta>
   ```
3. Inicie o servidor:
   ```bash
   python backend/app.py
   ```

A aplicação será executada em `http://localhost:5000` por padrão.

## Docker

Também é possível executar o backend em um contêiner. Para construir a imagem e
subir o container localmente, execute:

```bash
docker build -t ohana-backend .
docker run -p 5000:5000 --env MYSQLHOST=<host> --env MYSQLUSER=<usuario> \
    --env MYSQLPASSWORD=<senha> --env MYSQLDATABASE=<banco> \
    ohana-backend
```

O contêiner utilizará a variável `PORT` fornecida pela Railway quando implantado
na plataforma.

## Hospedagem do Frontend

Para disponibilizar o frontend no GitHub Pages, envie o conteúdo da pasta `frontend` para a branch `gh-pages` de seu repositório.
