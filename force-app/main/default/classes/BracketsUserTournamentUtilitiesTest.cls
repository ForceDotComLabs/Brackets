@isTest
class BracketsUserTournamentUtilitiesTest {
    @isTest
    static void allMethods() {
        delete [SELECT id FROM Brackets_UserTournament__c];
        Brackets_UserTournament__c userTournamentRetrieved;
        Brackets_Tournament__c myTour = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c myGroup = BracketsTestUtilities.getGroup(myTour.Id);
        Brackets_UserTournament__c uTour = BracketsTestUtilities.createUserTournament(
            UserInfo.getUserId(),
            myTour.Id,
            myGroup.Id
        );

        List<Brackets_UserTournament__c> userTournaments = BracketsUserTournamentUtilities.getUserTournaments(
            myTour.Id,
            myGroup.Id,
            UserInfo.getUserId()
        );
        System.assert(
            !userTournaments.isEmpty(),
            'Should have a user tournament with group ' +
            myGroup.Id +
            ' and tournament ' +
            myTour.Id
        );
        userTournamentRetrieved = userTournaments.get(0);
        System.assert(userTournamentRetrieved.Id == uTour.Id);

        userTournaments = BracketsUserTournamentUtilities.getUserTournamentsFromUser(
            UserInfo.getUserId()
        );
        System.assert(
            !userTournaments.isEmpty(),
            'Should have a user tournament with group ' +
            myGroup.Id +
            ' and tournament ' +
            myTour.Id
        );

        BracketsUserTournamentUtilities.save(userTournaments);
        BracketsUserTournamentUtilities.checkJoinedTournaments(userTournaments);
        BracketsUserTournamentUtilities.userSuscribe(userTournaments);
    }
}
