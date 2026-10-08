# Integração API Externa com Salesforce

Projeto de integração assíncrona entre Salesforce e uma API externa utilizando Apex, Queueable Apex, Named Credential, tratamento de erros, registro do processamento e testes automatizados.

## Objetivo

Enviar dados de registros do objeto `Integracao_API__c` para uma API externa por meio de uma chamada HTTP assíncrona.

O processamento é iniciado automaticamente pelo trigger após a criação de um registro.

## Arquitetura

O fluxo da integração funciona da seguinte forma:

1. Um registro é criado em `Integracao_API__c`.
2. O trigger `ApiIntegracaoTrigger` é executado após a inserção.
3. O trigger enfileira o `ApiIntegracaoQueueable`.
4. O Queueable consulta o registro criado.
5. A classe `ApiIntegracaoService` monta o corpo JSON.
6. O Salesforce realiza uma requisição HTTP `POST`.
7. O resultado da API é gravado no próprio registro de integração.

## Componentes Apex

### ApiIntegracaoTrigger

Executado após a inserção de registros em `Integracao_API__c`.

Responsabilidade:

- Enfileirar o processamento assíncrono da integração.

### ApiIntegracaoQueueable

Responsável por:

- Executar o processamento fora da transação principal.
- Consultar o registro de integração.
- Chamar o serviço HTTP.
- Atualizar o registro com o resultado do processamento.

### ApiIntegracaoService

Responsável por:

- Montar o corpo da requisição.
- Interpretar o payload JSON.
- Executar a chamada HTTP.
- Registrar código e corpo da resposta.
- Tratar respostas de sucesso.
- Tratar respostas de erro.
- Registrar exceções inesperadas.

### ApiIntegracaoHttpMock

Mock utilizado nos testes automatizados para simular a resposta da API externa.

### ApiIntegracaoTest

Classe de teste que valida:

- Criação do registro de integração.
- Execução automática do trigger.
- Enfileiramento do Queueable.
- Chamada HTTP simulada.
- Processamento de uma resposta HTTP 201.
- Atualização dos campos de sucesso.

## Objeto Integracao_API__c

O objeto armazena os dados e o resultado de cada tentativa de integração.

Campos principais:

- `Status__c`
- `External_Id__c`
- `Payload__c`
- `Request_Body__c`
- `Response_Body__c`
- `Error_Message__c`
- `Http_Status_Code__c`
- `Processed_At__c`

## Status do processamento

Os status utilizados são:

- `Processando`: processamento iniciado.
- `Sucesso`: API retornou código HTTP entre 200 e 299.
- `Erro`: API retornou erro ou ocorreu uma exceção.

## Endpoint utilizado

A classe `ApiIntegracaoService` utiliza a seguinte referência:

```text
callout:External_API/api/v1/integracoes
```

A Named Credential utilizada pelo projeto possui o nome:

```text
External_API
```

O endereço base da API ainda precisa ser definido no ambiente Salesforce. O valor não foi incluído no código para evitar o uso de uma URL incorreta.

## Configuração da Named Credential

Antes de utilizar a integração com uma API real, é necessário configurar na org Salesforce:

- Named Credential com o nome `External_API`.
- URL base da API externa.
- Método de autenticação exigido pela API.
- Credenciais ou token armazenados de forma segura.
- Acesso do usuário à configuração necessária.

O token ou segredo de autenticação não deve ser armazenado no código Apex, no repositório Git ou em campos comuns do Salesforce.

## Testes

O teste automatizado utiliza `HttpCalloutMock`, portanto não depende de uma API externa real.

Comando para executar o teste:

```text
sf apex run test --tests ApiIntegracaoTest --target-org estudo --result-format human --wait 10
```

Resultado validado:

- 1 teste executado.
- 100% de aprovação.
- Processamento assíncrono validado.
- Resposta HTTP 201 simulada.
- Registro atualizado com status `Sucesso`.

## Deploy

Para implantar o projeto completo na org configurada:

```text
sf project deploy start --source-dir force-app/main/default --target-org estudo
```

Para verificar o status do projeto:

```text
sf project retrieve start --target-org estudo
```

## Boas práticas aplicadas

- Uso de Queueable Apex para processamento assíncrono.
- Uso de Named Credential para separar endpoint e autenticação do código.
- Ausência de tokens e segredos no código-fonte.
- Tratamento de respostas HTTP de sucesso e erro.
- Registro dos dados enviados e recebidos.
- Tratamento de exceções.
- Uso de mock para testes de callout.
- Teste do fluxo completo iniciado pelo trigger.
- Limitação do tamanho dos textos armazenados nos campos.

## Próximas configurações

- Definir a URL base da API externa.
- Configurar a Named Credential `External_API`.
- Definir o método de autenticação da API.
- Validar uma chamada em ambiente de homologação.
- Adicionar testes para respostas HTTP de erro.
- Adicionar testes para exceções de callout.
- Publicar o projeto em um repositório GitHub.