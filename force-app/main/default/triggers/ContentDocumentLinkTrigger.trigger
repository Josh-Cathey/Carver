/**
 * Created by Holden.Parker on 4/11/22.
 */

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        ContentDocumentLinkTriggerHelper.beforeInsert(trigger.new);
    }

}