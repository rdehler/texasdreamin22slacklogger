public with sharing class LogDemo {
    
    @AuraEnabled
    public static void failureWithLog(){
        try {
            update new User();
        } catch(Exception ex){
            new Log(LoggingLevel.ERROR)
            .setMessage('Test Error Message')
            .setException(ex)
            .write();
        }
    }

    @AuraEnabled
    public static void multipleFailuresWithLog(){
        try {
            

            try {
                Integer numerator = 41;
                Integer denominator = 0;
                Integer i = numerator/denominator;
            } catch(Exception ex){
                new Log(LoggingLevel.ERROR)
                .setMessage('You are dividing by zero!')
                .setException(ex)
                .write();
            }

            try {
                Account acct = [
                    SELECT Name
                    FROM Account
                    WHERE Name = 'Some Gibberish'
                    LIMIT 1
                ];
                String name = acct.Name;
            } catch (NullPointerException npe){
                new Log(LoggingLevel.ERROR)
                .setMessage('Account name is null')
                .setException(npe)
                .write();
                throw npe;
            } 

        } catch(Exception ex){
            new Log(LoggingLevel.ERROR)
            .setMessage('Generic Exception')
            .setException(ex)
            .write();
        }
    }
}
