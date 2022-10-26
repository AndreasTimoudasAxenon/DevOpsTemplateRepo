@isTest
private class BatchProcessImportObjectsTest {
    

    @TestSetup
    static void makeData(){
        Import_Objekt__c impPersonObj = new Import_Objekt__c();
        impPersonObj.KundKey__c = '1234';
        impPersonObj.FirstName__c = 'Andreas';
        impPersonObj.LastName__c = 'TestPersonAcc';
        impPersonObj.KundKlass__c = 1;
        insert impPersonObj;
        Import_Objekt__c impBusinessObj = new Import_Objekt__c();
        impBusinessObj.KundKey__c = '1233';
        impBusinessObj.Account_Name__c = 'Andreas TestBusinessAcc';
        impBusinessObj.KundKlass__c = 0;
        impBusinessObj.FirstName__c = 'Andreas';
        impBusinessObj.LastName__c = 'TestBusinessAcc';
        insert impBusinessObj;

    }
    
    @isTest
    static void testPersonAccountRecordType(){
        String personAccountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Personkonto').getRecordTypeId();
        Test.startTest();
        Database.executeBatch(new BatchProcessImportObject());
        Test.stopTest();
        Account persAcc = [SELECT RecordType.Id FROM Account WHERE KundKey__c = '1234'];
        List<Contact> persCon = [SELECT Id FROM Contact WHERE Account.KundKey__c = '1234'];
        System.assertEquals(personAccountRecordId, persAcc.RecordType.Id);
        System.assertEquals(1, persCon.size());
    }

    @isTest
    static void testBusinessAccountRecordType(){
        String businessAccountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Test.startTest();
        Database.executeBatch(new BatchProcessImportObject());
        Test.stopTest();
        Account businessAcc = [SELECT RecordType.Id FROM Account WHERE KundKey__c = '1233'];
        System.assertEquals(businessAccountRecordId, businessAcc.RecordType.Id);

    }
    @isTest
    static void testBusinessAccountContactCreation(){
        Test.startTest();
        Database.executeBatch(new BatchProcessImportObject());
        Test.stopTest();
        List<Contact> businessAccContact = [SELECT KundKey__c FROM Contact WHERE KundKey__c = '1233'];
        System.assertEquals(1, businessAccContact.size());
    }

    @isTest
    static void testSyncStatusSucessful(){
        Test.startTest();
        Database.executeBatch(new BatchProcessImportObject());
        Test.stopTest();
        Import_Objekt__c impData = [SELECT Synced__c FROM Import_Objekt__c WHERE KundKey__c = '1233'];
        System.assertEquals(true, impData.Synced__c);    
    }

    

    @isTest        
    static void schedulableTest() {        
        test.starttest();
        BatchProcessImportObjectsSchedulable sh = new BatchProcessImportObjectsSchedulable ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, sh);
        test.stopTest();
    }



}