public with sharing class ApiIntegracaoService {
    private static final String ENDPOINT = 'callout:External_API/api/v1/integracoes';

    public static Integracao_API__c processar(Integracao_API__c integracao) {
        integracao.Status__c = 'Processando';
        integracao.Error_Message__c = null;
        integracao.Processed_At__c = null;

        String corpoRequisicao = montarCorpoRequisicao(integracao);
        integracao.Request_Body__c = corpoRequisicao;

        HttpRequest requisicao = new HttpRequest();
        requisicao.setEndpoint(ENDPOINT);
        requisicao.setMethod('POST');
        requisicao.setHeader('Content-Type', 'application/json');
        requisicao.setHeader('Accept', 'application/json');
        requisicao.setTimeout(120000);
        requisicao.setBody(corpoRequisicao);

        try {
            HttpResponse resposta = new Http().send(requisicao);
            Integer codigoStatus = resposta.getStatusCode();

            integracao.Http_Status_Code__c = codigoStatus;
            integracao.Response_Body__c = limitarTexto(
                resposta.getBody(),
                131072
            );
            integracao.Processed_At__c = Datetime.now();

            if (codigoStatus >= 200 && codigoStatus < 300) {
                integracao.Status__c = 'Sucesso';
            } else {
                integracao.Status__c = 'Erro';
                integracao.Error_Message__c = limitarTexto(
                    'A API retornou HTTP ' + codigoStatus + ': ' + resposta.getStatus(),
                    255
                );
            }
        } catch (Exception erro) {
            integracao.Status__c = 'Erro';
            integracao.Processed_At__c = Datetime.now();
            integracao.Error_Message__c = limitarTexto(
                erro.getTypeName() + ': ' + erro.getMessage(),
                255
            );
        }

        return integracao;
    }

    private static String montarCorpoRequisicao(
        Integracao_API__c integracao
    ) {
        Map<String, Object> corpo = new Map<String, Object>{
            'integrationId' => integracao.Id,
            'externalId' => integracao.External_Id__c,
            'name' => integracao.Name,
            'payload' => interpretarPayload(integracao.Payload__c)
        };

        return JSON.serialize(corpo);
    }

    private static Object interpretarPayload(String payload) {
        if (String.isBlank(payload)) {
            return new Map<String, Object>();
        }

        try {
            return JSON.deserializeUntyped(payload);
        } catch (Exception erro) {
            return new Map<String, Object>{
                'rawPayload' => payload
            };
        }
    }

    private static String limitarTexto(String valor, Integer limite) {
        if (valor == null || valor.length() <= limite) {
            return valor;
        }

        return valor.substring(0, limite);
    }
}








