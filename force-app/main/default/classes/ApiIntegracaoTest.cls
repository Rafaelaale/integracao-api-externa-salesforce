@IsTest
private class ApiIntegracaoTest {
    @IsTest
    static void deveProcessarIntegracaoComSucesso() {
        Test.setMock(HttpCalloutMock.class, new ApiIntegracaoHttpMock());

        Test.startTest();

        Integracao_API__c integracao = new Integracao_API__c(
            External_Id__c = 'EXT-TEST-001',
            Payload__c = '{"cliente":"Rafael","origem":"teste"}'
        );
        insert integracao;

        Test.stopTest();

        Integracao_API__c resultado = [
            SELECT Status__c,
                   External_Id__c,
                   Payload__c,
                   Request_Body__c,
                   Response_Body__c,
                   Error_Message__c,
                   Http_Status_Code__c,
                   Processed_At__c
            FROM Integracao_API__c
            WHERE Id = :integracao.Id
        ];

        System.assertEquals('Sucesso', resultado.Status__c);
        System.assertEquals('EXT-TEST-001', resultado.External_Id__c);
        System.assertEquals(201, resultado.Http_Status_Code__c);
        System.assertNotEquals(null, resultado.Request_Body__c);
        System.assertNotEquals(null, resultado.Response_Body__c);
        System.assertEquals(null, resultado.Error_Message__c);
        System.assertNotEquals(null, resultado.Processed_At__c);
    }
}