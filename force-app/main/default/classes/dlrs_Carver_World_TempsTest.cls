/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Carver_World_TempsTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Carver_World_TempsTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Carver_World_Temps__c());
    }
}