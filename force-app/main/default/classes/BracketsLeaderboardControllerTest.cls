@isTest
class BracketsLeaderboardControllerTest {
    @isTest
    static void testSimple() {
        BracketsLeaderboardController controller = new BracketsLeaderboardController();

        List<Brackets_UserTournament__c> l = controller.getLeaders();

        System.assert(l != null);
    }
}
