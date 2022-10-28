global Class OpportunitySurveyEmailScheduler implements Schedulable {

      private static String CRON_EXP = '0 0 0 * * ?';

    global static String scheduleIt() {
        CRON_EXP = '0 0 0 * * ?';
        
        /*DateTime curentTime = System.Now().addMinutes(1);
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        CRON_EXP = '0 ' + min + ' * * * ?';  */
        
        System.debug('CRON_EXP : ' + CRON_EXP);
        
        OpportunitySurveyEmailScheduler sceduleObj = new OpportunitySurveyEmailScheduler();
        return System.schedule('Send Opportunity Survey Emails', CRON_EXP, sceduleObj);
    }
    

     global void execute(SchedulableContext OpportunitySchedulerContext) {
         SendOpportunitySurveyEmails sendOpportunitySurveyEmails = new SendOpportunitySurveyEmails();
         database.executebatch(sendOpportunitySurveyEmails, 100);
     }
}