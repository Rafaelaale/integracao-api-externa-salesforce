@IsTest
global class ApiIntegracaoHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest requisicao) {
        HttpResponse resposta = new HttpResponse();
        resposta.setStatusCode(201);
        resposta.setStatus('Created');
        resposta.setHeader('Content-Type', 'application/json');
        resposta.setBody('{"success":true,"message":"Integração processada com sucesso","externalId":"EXT-001"}');
        return resposta;
    }
}