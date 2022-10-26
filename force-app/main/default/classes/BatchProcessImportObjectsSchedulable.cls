public class BatchProcessImportObjectsSchedulable implements Schedulable{
    public void execute(SchedulableContext sc){
        BatchProcessImportObject b = new BatchProcessImportObject();
        database.executeBatch(b);
    }
}