/**
 * Created by Holden.Parker on 4/11/22.
 */

public with sharing class ContentDocumentLinkTriggerHelper {

    private static final String CONSULTANT_HISTORY = 'Consultant_History__c';
    private static final String APPROVAL = 'Approval__c';
    private static final String ALL_USERS = 'AllUsers';

    public static void beforeInsert(List<ContentDocumentLink> contentDocumentLinks) {
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            if (cdl.LinkedEntityId != null && (getSObjectTypeFromId(cdl.LinkedEntityId) == CONSULTANT_HISTORY||getSObjectTypeFromId(cdl.LinkedEntityId) == APPROVAL)) {
                cdl.Visibility = ALL_USERS;
            }
        }
    }

    private static String getSObjectTypeFromId(Id recordId) {
        String idPrefix = String.valueOf(recordId).substring(0,3);
        String sobjectType;
        Map<String, Schema.SObjectType> describe = Schema.getGlobalDescribe();

        for(String type : describe.keySet()) {
            if (describe.get(type).getDescribe().getKeyPrefix() == idPrefix) {
                sobjectType = type;
            }
        }

        return sobjectType;
    }
    
}