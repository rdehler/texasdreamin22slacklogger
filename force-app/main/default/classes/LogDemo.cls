public with sharing class LogDemo {

    @AuraEnabled
    public static Integer divide(Integer numerator, Integer denominator){
        try {
            return numerator/denominator;
        } catch(Exception ex){
            new Log(LoggingLevel.ERROR)
            .setMessage('Divide Error')
            .setException(ex)
            .write();
            return null;
        }
    }

    @AuraEnabled
    public static Account createAccount(String accountName){
        try {
            Account acct = new Account(Name = accountName);
            insert acct;
            acct = [
                SELECT Id, Name
                FROM Account
                WHERE Name = :accountName
                LIMIT 1
                ];

            return acct;
        } catch(Exception ex){
            new Log(LoggingLevel.ERROR)
            .setMessage('Error creating account')
            .setException(ex)
            .write();
            return null;
        }
    }

}
