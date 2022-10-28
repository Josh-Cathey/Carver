/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    26 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
global class AdVic_IntuitRefresh implements Schedulable {

    global void execute(SchedulableContext context) {
        AdVic_Intuit_Util.refreshAccessToken();
    }
}