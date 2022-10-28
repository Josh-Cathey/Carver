trigger ContactTrigger on Contact (after insert, after update) {
    if(Trigger.isAfter) {
        List<Contact> profilesInReview = ContactTriggerHandler.getProfilesInReview(Trigger.OldMap, Trigger.NewMap);
        if(profilesInReview.size() > 0 ) {
            ContactTriggerHandler.submitContactsForApproval(profilesInReview);
        }
    }
}