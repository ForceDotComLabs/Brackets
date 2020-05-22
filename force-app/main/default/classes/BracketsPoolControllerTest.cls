@isTest
class BracketsPoolControllerTest {
    @isTest
    static void testTournamentTypes() {
        delete [SELECT Id FROM Brackets_Group__c];
        Brackets_Tournament__c myTour = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c myOpenedGroup = BracketsTestUtilities.getGroup(
            myTour.Id
        );
        upsert myOpenedGroup;
        Brackets_Group__c myClosedGroup = BracketsTestUtilities.getClosedGroup(
            myTour.Id
        );
        Brackets_UserTournament__c uTour = BracketsTestUtilities.createUserTournament(
            UserInfo.getUserId(),
            myTour.Id,
            myOpenedGroup.Id
        );
        BracketsTestUtilities.createUserMatchPrediction(
            myTour.Id,
            myOpenedGroup.Id,
            uTour.Id
        );
        BracketsPoolController controller = new BracketsPoolController();
        Boolean testBool = controller.getCanCreate();
        PageReference testPage = controller.createNewPool();
        testBool = BracketsPoolController.checkObjectCrud('Brackets_Group__c');

        BracketsPoolController.GroupWrap innerClass = new BracketsPoolController.GroupWrap(
            myOpenedGroup
        );
        String testStr = innerClass.getStatus();
        innerClass.hasUserTournaments = true;
        testStr = innerClass.getStatus();

        System.assert(
            controller.groups.size() == 2,
            'The number of groups should be two.'
        );
    }
}
