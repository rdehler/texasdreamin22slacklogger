public without sharing class SlackPostQueueable implements System.Queueable, Database.AllowsCallouts {
    
    private final String url;
    private final String method;
    private final String body;

    public SlackPostQueueable(String url, String method, String body) {
        this.url = url;
        this.method = method;
        this.body = body;
    }

    public void execute(System.QueueableContext ctx){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setBody(body);
        Http http = new Http();
        HttpResponse res = http.send(req);
    }
}
