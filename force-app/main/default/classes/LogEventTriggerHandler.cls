public with sharing class LogEventTriggerHandler {

    public static List<Log.LogWrapper> listLogWrapper = new List<Log.LogWrapper>();

    public static void processLogEvents(){
        List<Log__c> logs = new List<Log__c>();
        for(SObject l : Trigger.new){
            logs.add(buildLog((Log_Event__e)l));
        }
        insert logs;
        SlackUtil.pushToSlack(logs);
    }

    private static Log__c buildLog(Log_Event__e e){
        Log__c log = new Log__c();

        Log.LogWrapper wrapper = (Log.LogWrapper) JSON.deserialize(e.Payload__c, Log.LogWrapper.class);
        //listLogWrapper.add(wrapper);
        log.User_Id__c = wrapper.currentUserId;
        log.Class_Name__c = wrapper.className;
        log.Method_Name__c = wrapper.methodName;
        log.Line_Number__c = Double.valueOf(wrapper.lineNum);
        log.Timestamp__c = Datetime.newInstance(wrapper.timestamp);
        log.Log_Number__c = wrapper.logNumber;
        log.Transaction_Limits__c = JSON.serialize(wrapper.transactionLimits);
        log.Exception_Type__c = wrapper.exceptionType;
        log.Exception_Message__c = wrapper.exceptionMessage;
        log.Exception_Cause__c = wrapper.exceptionCause;
        log.Exception_Line_Number__c = wrapper.exceptionLineNumber;
        log.Exception_Stack__c = wrapper.exceptionStack;
        log.Message__c = wrapper.message;
        log.Details__c = wrapper.details;
        log.Record_Context__c = wrapper.recordContext;
        log.Log_Level__c = wrapper.logLevel;
        log.Stack_Trace__c = wrapper.stackTrace;
        return log;
    }


    public LogEventTriggerHandler() {

    }
}
