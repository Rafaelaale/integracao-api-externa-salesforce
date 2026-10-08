trigger ApiIntegracaoTrigger on Integracao_API__c (after insert) {
    for (Integracao_API__c integracao : Trigger.new) {
        System.enqueueJob(new ApiIntegracaoQueueable(integracao.Id));
    }
}