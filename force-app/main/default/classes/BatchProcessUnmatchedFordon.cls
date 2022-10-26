public class BatchProcessUnmatchedFordon implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id, KundKey__c, FOR_EPOST__c, FOR_NAMN__c, Ingen_Match__c,
                   FOR_ADRESS__c, FOR_POSTADR__c, FOR_TEL__c
            FROM Fordon__c 
            WHERE Ingen_Match__c = true
        ]);
     }
  
     public void execute(Database.BatchableContext BC, List<Fordon__c> fordonList){
        BatchProcessUnmatchedFordonHelper helper = new BatchProcessUnmatchedFordonHelper();
        FordonTriggerHandler processer = new FordonTriggerHandler();
        List<Fordon__c> fordonWithMatch = helper.checkIfFordonOwnerContactExists(fordonList);
        processer.mapFordonToContact(fordonList);
        update fordonWithMatch;

     }

     public void finish(Database.BatchableContext BC){
     }
}