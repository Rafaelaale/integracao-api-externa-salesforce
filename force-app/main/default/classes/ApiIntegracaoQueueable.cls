public with sharing class ApiIntegracaoQueueable implements Queueable, Database.AllowsCallouts {
    private Id integracaoId;

    public ApiIntegracaoQueueable(Id integracaoId) {
        this.integracaoId = integracaoId;
    }

    public void execute(QueueableContext contexto) {
        Integracao_API__c integracao = [
            SELECT Id,
                   Name,
                   Status__c,
                   External_Id__c,
                   Payload__c,
                   Request_Body__c,
                   Response_Body__c,
                   Error_Message__c,
                   Http_Status_Code__c,
                   Processed_At__c
            FROM Integracao_API__c
            WHERE Id = :integracaoId
            LIMIT 1
        ];

        ApiIntegracaoService.processar(integracao);
        update integracao;
    }
}