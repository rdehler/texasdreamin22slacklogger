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
            return acct;
        } catch(Exception ex){
            new Log(LoggingLevel.ERROR)
            .setMessage('Error retrieving account')
            .setException(ex)
            .write();
            return null;
        }
    }

}
