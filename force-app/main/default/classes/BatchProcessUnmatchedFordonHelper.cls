public class BatchProcessUnmatchedFordonHelper {
    /**
     * Checks if a fordon has an matching Contact based on KundKey__c
     * if match Ingen_Match__c is set to FALSE
     * 
     * @param fordonList: List of Fordon__c records before insert
     * 
     * return a updated list of fordonList
     */
    FordonTriggerUtils fordonUtils;

    public BatchProcessUnmatchedFordonHelper(){
        fordonUtils = new FordonTriggerUtils();
    }

    public List<Fordon__c> checkIfFordonOwnerContactExists(List<Fordon__c> fordonList){
        List<Fordon__c> updatedStatusFordonList = new List<Fordon__c>();
        Set<String> fordonKundKeySet = fordonUtils.createFordonKundKeySet(fordonList);
        //Get related Contacts based on KundKey__c
        List<Contact> relatedContacts = [SELECT Id, Account.KundKey__c FROM Contact WHERE Account.KundKey__c IN :fordonKundKeySet];
        Map<String, Contact> relatedContactsKundKeyMap = fordonUtils.createContactKundKeyMap(relatedContacts);
        for(Fordon__c fordon: fordonList){
            //Get owner from Contact Map with matching KundKey__c
            Contact ownerContactRecord = relatedContactsKundKeyMap.get(fordon.KundKey__c);
            if(ownerContactRecord != null){
                fordon.Ingen_Match__c = false;
                updatedStatusFordonList.add(fordon);
            }
        }
        return updatedStatusFordonList;
    }
}