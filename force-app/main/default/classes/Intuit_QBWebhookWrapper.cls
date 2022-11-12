/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    10 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
public with sharing class Intuit_QBWebhookWrapper {

    public List<eventNotifications> eventNotifications;

    public class eventNotifications {
        public String realmId;
        public DataChangeEvent DataChangeEvent;
    }

    public class DataChangeEvent{
        public List<entities> entities;
    }

    public class entities{
        public String name;
        public String id;
        public String operation;
        public String lastUpdated;
    }

    public static Intuit_QBWebhookWrapper jsonParse(String jsonBody) {
        return (Intuit_QBWebhookWrapper) JSON.deserialize(jsonbody, Intuit_QBWebhookWrapper.class);
    }
}