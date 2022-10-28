/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Target_ListTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Target_ListTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Target_List__c());
    }
}