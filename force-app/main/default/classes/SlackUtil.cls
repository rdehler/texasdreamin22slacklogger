public without sharing class SlackUtil {
    
    public static String SlackURL(){
        List<Slack_Config__mdt> slackURL = [
            SELECT Id, URL__c
            FROM Slack_Config__mdt
        ];
        if(slackURL.size() > 0){
            return slackURL[0].URL__c;
        } else {
            return '';
        }
    }

    public static void pushToSlack(List<Log__c> messages){
        String url = SlackURL();
        for(Log__c log : messages){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('text', formatBody(log));
            gen.writeEndObject();

            String body = gen.getAsString();
            System.debug(body);
            System.enqueueJob(new SlackPostQueueable(url, 'POST', body));
        }
    }

    private static String formatBody(Log__c log){
        String body = '';

        body += 'Message - ' + log.Message__c;
        body += '\n';
        body += 'Exception Message - ' + log.Exception_Message__c;
        body += '\n';
        body += 'ID of Log - ' + log.Id;
        body += '\n';
        body += 'Stack Trace - ' + log.Stack_Trace__c;
        return body;
    }

}
