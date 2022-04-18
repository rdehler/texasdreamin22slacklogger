public without sharing class Log {
    private static final Pattern STACK_LINE = Pattern.compile(
        '\\w+ (\\d+), \\w+ (\\d+)'
    );
    
    private static final String CLASS_NAME;
    private static final Request REQ_INFO;
    private static List<LogWrapper> logQueue = new List<LogWrapper>();
    private static String logLevel;
    private static Integer logNum = 1;
    private static Integer unownedSoqlCost;
    private static Integer unownedCpuCost;

    private final LogWrapper lw;
    private LoggingLevel level;
    private Boolean forceLog = false;
    private Map<String, Object> details;
    private List<Object> values;
    private Integer startCpuTime;
    private Integer startSoqlCount;

    static {
        Integer startingSoqlCount = Limits.getQueries();
        Integer startingCpuTime = Limits.getCpuTime();
        logLevel = getLogLevel();
        CLASS_NAME = Log.class.getName();
        unownedSoqlCost = Limits.getQueries() - startingSoqlCount;
        unownedCpuCost = Limits.getCpuTime() - startingCpuTime;
      }

      public Log(LoggingLevel level) {
        lw = new LogWrapper();
        this.level = level;
        lw.logLevel = level.name();
        // capture performance data of the act of logging
        startCpuTime = Limits.getCpuTime();
        startSoqlCount = Limits.getQueries();
        // build of the supporting data and other baselines
        details = new Map<String, Object>();
        values = new List<Object>();
        lw.logNumber = logNum++;
        lw.timestamp = System.Now().getTime();
        lw.transactionLimits = getLimitsMap();
        lw.currentUserId = UserInfo.getUserId();
        populateStackInfo();
      }
    
      public Log setMessage(String message) {
        lw.message = message;
        return this;
      }
    
      public Log setException(Exception e) {
        if (e != null) {
          lw.exceptionType = e.getTypeName();
          lw.exceptionMessage = e.getMessage();
          lw.exceptionCause = '' + e.getCause();
          lw.exceptionLineNumber = e.getLineNumber();
          lw.exceptionStack = e.getStackTraceString();
        }
        return this;
      }
    
      public Log addDetail(String name, Object o) {
        details.put(name, o);
        return this;
      }
    
      public void write() {
        logQueue.add(lw);
        Log.flush();
      }
    
      public static void flush() {
        try {
          if (logQueue.isEmpty()) {
            return;
          }
          List<Log_Event__e> events = new List<Log_Event__e>();
          for (LogWrapper l : logQueue) {
            events.add(new Log_Event__e(Payload__c = JSON.serialize(l)));
          }
          EventBus.publish(events);
          logQueue.clear();
        } catch (Exception ex) {
          System.debug('Flush failed:' + ex.getMessage());
        }
      }
    
      private void populateStackInfo() {
        List<String> stacktrace = new DmlException()
          .getStackTraceString()
          .split('\n');
    
        // trim off self-referencing stack lines
        for (Integer i = stacktrace.size() - 1; i >= 0; i--) {
          if (stacktrace.get(i).startsWith('Class.' + CLASS_NAME + '.')) {
            stacktrace.remove(i);
          }
        }
        // capture the remaining stack trace
        lw.stackTrace = String.join(stacktrace, '\n');
    
        Map<String, String> stackData = decomposeStackLine(stacktrace[0]);
        lw.className = stackData.get('class');
        lw.methodName = stackData.get('method');
        lw.lineNum = stackData.get('lineNum');
      }

      private static String getLogLevel() {
        return LoggingLevel.FINEST.name();
      }

      private static Map<String, String> decomposeStackLine(String s) {
        // Split into method path and line-column
        List<String> lineParts = s.split(':');
        // Break the method into parts
        List<String> pathParts = lineParts[0].split('\\.');
        // Pop the leading "Class" text
        if ('Class'.equals(pathParts.get(0))) {
          pathParts.remove(0);
        }
        // pull the method name from the tip of the list
        String method = pathParts.remove(pathParts.size() - 1);
        // build the classname from the remaining parts
        String className = String.join(pathParts, '.');
        // if the classname was empty, probably Anon Apex, copy the value back
        if (String.isEmpty(className)) {
          className = method;
        }
        // retrieve the line number
        Matcher matcher = STACK_LINE.matcher(lineParts[1].trim());
        matcher.find();
        String lineNum = matcher.group(1);
        String columnNum = matcher.group(2);
        // build the return object
        return new Map<String, String>{
          'class' => className,
          'method' => method,
          'lineNum' => lineNum,
          'columNum' => columnNum
        };
      }

      public static Map<String, Integer> getLimitsMap() {
        Map<String, Integer> limitsData = new Map<String, Integer>();
        limitsData.put('AggregateQueries', Limits.getAggregateQueries());
        limitsData.put('LimitAggregateQueries', Limits.getLimitAggregateQueries());
        limitsData.put('AsyncCalls', Limits.getAsyncCalls());
        limitsData.put('LimitAsyncCalls', Limits.getLimitAsyncCalls());
        limitsData.put('Callouts', Limits.getCallouts());
        limitsData.put('LimitCallouts', Limits.getLimitCallouts());
        limitsData.put('CpuTime', Limits.getCpuTime());
        limitsData.put('LimitCpuTime', Limits.getLimitCpuTime());
        limitsData.put('DMLRows', Limits.getDMLRows());
        limitsData.put('LimitDMLRows', Limits.getLimitDMLRows());
        limitsData.put('DMLStatements', Limits.getDMLStatements());
        limitsData.put('LimitDMLStatements', Limits.getLimitDMLStatements());
        limitsData.put('EmailInvocations', Limits.getEmailInvocations());
        limitsData.put('LimitEmailInvocations', Limits.getLimitEmailInvocations());
        limitsData.put('FutureCalls', Limits.getFutureCalls());
        limitsData.put('LimitFutureCalls', Limits.getLimitFutureCalls());
        limitsData.put('HeapSize', Limits.getHeapSize());
        limitsData.put('LimitHeapSize', Limits.getLimitHeapSize());
        limitsData.put('MobilePushApexCalls', Limits.getMobilePushApexCalls());
        limitsData.put(
          'LimitMobilePushApexCalls',
          Limits.getLimitMobilePushApexCalls()
        );
        limitsData.put('PublishImmediateDML', Limits.getPublishImmediateDML());
        limitsData.put(
          'LimitPublishImmediateDML',
          Limits.getLimitPublishImmediateDML()
        );
        limitsData.put('Queries', Limits.getQueries());
        limitsData.put('LimitQueries', Limits.getLimitQueries());
        limitsData.put('QueryLocatorRows', Limits.getQueryLocatorRows());
        limitsData.put('LimitQueryLocatorRows', Limits.getLimitQueryLocatorRows());
        limitsData.put('QueryRows', Limits.getQueryRows());
        limitsData.put('LimitQueryRows', Limits.getLimitQueryRows());
        limitsData.put('QueueableJobs', Limits.getQueueableJobs());
        limitsData.put('LimitQueueableJobs', Limits.getLimitQueueableJobs());
        limitsData.put('SoslQueries', Limits.getSoslQueries());
        limitsData.put('LimitSoslQueries', Limits.getLimitSoslQueries());
        return limitsData;
      }

      public class LogWrapper {
        public Id currentUserId; // User Id of the current context user
        public String className; // The class name that emitted the log event
        public String methodName; // The method name that emmitted the log event
        public String lineNum; // The line number that emitted the log event
        public long timestamp; // moment the log event was emitted
        public Integer logNumber;
        public Map<String, Integer> transactionLimits; // current snapshot of limit data
        public String exceptionType;
        public String exceptionMessage;
        public String exceptionCause;
        public Integer exceptionLineNumber;
        public String exceptionStack;
        public String message;
        public String details; // messages and objects stringified into the log, stored as JSON
        public String recordContext; // if applicable, the identifier of the record involved in the current request
        public String logLevel; // LoggingLevel value (DEBUG, INFO, WARN, ERROR, ETC...)
        public String stackTrace; // How we got to this emit
      }
}
