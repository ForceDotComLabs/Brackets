@isTest
class BracketsTreeViewControllerTest {
    @isTest
    static void testConstructors() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
            tournament.Id
        );
        Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
            Userinfo.getUserId(),
            tournament.Id,
            groupp.Id
        );

        //constructor without parameters

        BracketsTreeViewController controller = new BracketsTreeViewController();
        controller.groupId = groupp.Id;
        controller.isLocked = false;

        System.assert(controller.getIsRenderable());

        System.assert(controller.tournamentId == tournament.Id);

        System.assert(controller.nflTree == null);
        System.assert(controller.stdTree != null);
    }
}
