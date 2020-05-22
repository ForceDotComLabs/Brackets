@isTest
class BracketsJoinInvitedUserTest {
    //Test Join Successfully
    @isTest
    static void test() {
        //Create enviroment
        Brackets_Group__c mGroup = BracketsTestUtilities.getGroup(null);
        Apexpages.currentPage().getParameters().put('gId', mGroup.Id);
        BracketsJoinInvitedUser cTest = new BracketsJoinInvitedUser();
        Test.startTest();
        Pagereference tRef = cTest.index();
        tRef = cTest.cancel();
        tRef = cTest.joinUser();
        Test.stopTest();
        List<Brackets_UserTournament__c> uTour = [
            SELECT Id
            FROM Brackets_UserTournament__c
            WHERE
                User__c = :UserInfo.getUserId()
                AND Brackets_Group__c = :mGroup.Id
        ];
        System.assert(!uTour.isEmpty());
    }

    //Test Not URL parm
    @isTest
    static void test1() {
        //Create enviroment
        Brackets_Group__c mGroup = BracketsTestUtilities.getGroup(null);
        BracketsJoinInvitedUser cTest = new BracketsJoinInvitedUser();
        Test.startTest();
        Pagereference tRef = cTest.index();
        Test.stopTest();
        List<Brackets_UserTournament__c> uTour = [
            SELECT Id
            FROM Brackets_UserTournament__c
            WHERE
                User__c = :UserInfo.getUserId()
                AND Brackets_Group__c = :mGroup.Id
        ];
        System.assert(uTour.isEmpty());
    }

    //Test already Join
    @isTest
    static void test2() {
        //Create enviroment
        Brackets_Tournament__c mTour = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c mGroup = BracketsTestUtilities.getGroup(mTour.Id);
        Brackets_UserTournament__c uTour = BracketsTestUtilities.createUserTournament(
            Userinfo.getUserId(),
            mTour.Id,
            mGroup.Id
        );
        Apexpages.currentPage().getParameters().put('gId', mGroup.Id);

        BracketsJoinInvitedUser cTest = new BracketsJoinInvitedUser();
        Test.startTest();
        Pagereference tRef = cTest.index();
        cTest.getShowButtons();
        Test.stopTest();
        List<Brackets_UserTournament__c> uTr = [
            SELECT Id
            FROM Brackets_UserTournament__c
            WHERE
                User__c = :UserInfo.getUserId()
                AND Brackets_Group__c = :mGroup.Id
        ];
        System.assert(!uTr.isEmpty());
    }
}
