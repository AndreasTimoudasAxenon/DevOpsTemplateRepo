public class BatchProcessImportObject implements Database.Batchable<SObject>, Database.stateful{

    private static String getSObjectFields(String SObjectAPIName){
        Set<String> SobjectFields = Schema.getGlobalDescribe().get(SObjectAPIName).getDescribe().fields.getMap().keySet();
        String queryString = 'SELECT ' + String.join(new List<String>(SobjectFields), ', ') + ' FROM ' + SObjectAPIName + ' WHERE Synced__c=false';
        System.debug(queryString);
        return queryString;
    }

 
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Query all fields
        String query = getSObjectFields('Import_Objekt__c');
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext bc, List<Import_Objekt__c> data){
        //Store businessObjects & businessAccounts in different list for Contact lookup
        List<Import_Objekt__c> importObjSyncStatus = new List<Import_Objekt__c>();
        List<Import_Objekt__c> businessObjects = new List<Import_Objekt__c>();
        List<Import_Objekt__c> personObjects = new List<Import_Objekt__c>();

        List<Account> businessAccounts = new List<Account>();
        List<Account> personAccounts = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        //Create Account objects
        for(Import_Objekt__c dataObj: data){
            if(dataObj.KundKlass__c == 0){
                Account businessAcct = CreateAccountFromImport.mapImportToAccount(dataObj);
                businessAccounts.add(businessAcct);
                businessObjects.add(dataObj);
            } else{
                Account personAcct = CreateAccountFromImport.mapImportToPersonAccount(dataObj);
                personAccounts.add(personAcct);
                personObjects.add(dataObj);
            }
        }
        

        //Insert/Update Accounts
        Schema.SobjectField kundKeyField = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('KundKey__c');
        List<Import_Objekt__c> insertedPersonAccountStatus = doUpsert(personAccounts, kundKeyField, personObjects, 'Upsert PersonAccount Error', true);
        List<Import_Objekt__c> insertedBusinessAccountStatus = doUpsert(businessAccounts, kundKeyField, businessObjects, 'Upsert BusinessAccount Error', true);

        //Map for businessAccounts with KundKey__c as key
        Map<String, Account> businessAccountsMap = new Map<String, Account>();
        for(Account business: businessAccounts){
            businessAccountsMap.put(business.KundKey__c, business);
        }

        for(Import_Objekt__c businessObj: insertedBusinessAccountStatus){
            //Get accountId for businessContact
            if(businessObj.Synced__c == true){
                Id accountId = businessAccountsMap.get(businessObj.KundKey__c).Id;
                Contact businessContact = CreateContactFromImport.createAccountContact(businessObj, accountId);
                contactsToInsert.add(businessContact);
            }
        }

        //Insert/Update contacts
        Schema.SobjectField kundKeyContactfield = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('KundKey__c');
        List<Import_Objekt__c> insertedBusinessContactsStatus = doUpsert(contactsToInsert, kundKeyContactfield, businessObjects, 'Upsert Contact Error', false);


     }

    public static List<Import_Objekt__c> doUpsert(List<sObject> sObjectsToInsert, Schema.sObjectField mapKey, 
                                                    List<Import_Objekt__c> syncStatusList, String errorMsgPrefix, Boolean erasePreviousError){
        List<Import_Objekt__c> importObjSyncStatus = new List<Import_Objekt__c>();
        Map<String, Database.UpsertResult> resultInsertedsObjects = upsertResultMap(sObjectsToInsert, mapKey);
        for(Import_Objekt__c syncOjb: syncStatusList){
            Database.UpsertResult syncObjStatus = resultInsertedsObjects.get(syncOjb.KundKey__c);
            if(syncObjStatus != null){
                if(syncObjStatus.isSuccess()){
                    syncOjb.Synced__c = true;
                    importObjSyncStatus.add(syncOjb);
                } else {
                    for(Database.Error err : syncObjStatus.getErrors()){
                        syncOjb.Synced__c = false;
                        syncOjb.Felmeddelande__c = erasePreviousError == true ? '' : syncOjb.Felmeddelande__c;
                        syncOjb.Felmeddelande__c += errorMsgPrefix + ': ' + err.getMessage() + ' StatusCode: ' + err.getStatusCode() + '\r\n';
                        importObjSyncStatus.add(syncOjb);
                    }
                }
            }
        }
        update syncStatusList;
        return syncStatusList;
    }


     /**
     * @description Method to insert objects to DataBase with improved audit
     * @param sObjects - sObjects to be insert
     * @param field - field that identifies Saveresult with inserted object
     * @return map where key is a value from field specified as param: field
     * and the value is Save result for sObject which is identified by key
     */
    public static Map<String,Database.UpsertResult> upsertResultMap(List<SObject> sObjects, Schema.sObjectField field) {
        Map<String,Database.UpsertResult> saveResultByField = new Map<String,Database.UpsertResult>();
        List<Database.UpsertResult> results = Database.upsert(sObjects, field, false);
        for (Integer i = 0;i<sObjects.size();i++) {
            saveResultByField.put((String)sObjects.get(i).get(field),results.get(i));
        }
        return  saveResultByField;
    }
 
    public void finish(Database.BatchableContext bc){
    }
 }

