global class PressRunScheduler implements schedulable{
    global void execute(SchedulableContext sc)
    {
        PressRunSync prp = new PressRunSync();
        database.executebatch(prp);
    }
}