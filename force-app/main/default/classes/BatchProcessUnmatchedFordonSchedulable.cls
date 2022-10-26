public class BatchProcessUnmatchedFordonSchedulable implements Schedulable{
    public void execute(SchedulableContext sc){
        BatchProcessUnmatchedFordon b = new BatchProcessUnmatchedFordon();
        database.executeBatch(b);
    }
}