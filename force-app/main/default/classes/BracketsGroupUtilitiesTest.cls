@isTest
class BracketsGroupUtilitiesTest {
    @isTest
    static void testBasics() {
        System.assert(BracketsGroupUtilities.BET_TYPE_BY_ROUND != null);
        System.assert(BracketsGroupUtilities.BET_TYPE_FULL_TOURNAMENT != null);
    }

    @isTest
    static void testGetGroups() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;
        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 RoundByRound',
                4
            );

            List<Id> ts = new List<Id>();
            ts.add(tournament.Id);

            Brackets_Group__c groupA = BracketsTestUtilities.getGroup(
                tournament.Id,
                BracketsGroupUtilities.BET_TYPE_BY_ROUND
            );
            Brackets_Group__c groupB = BracketsTestUtilities.getGroup(
                tournament.Id,
                BracketsGroupUtilities.BET_TYPE_BY_ROUND
            );

            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupA.Id
            );

            Map<Id, List<Brackets_Group__c>> results = BracketsGroupUtilities.getGroups(
                ts,
                testUser.id
            );

            System.assert(results != null);
            System.assert(results.get(tournament.id) != null);
            System.assert(results.get(tournament.id).size() == 1);

            Map<Id, List<Brackets_Group__c>> results2 = BracketsGroupUtilities.getGroups(
                ts,
                null
            );

            System.assert(results2 != null);
            System.assert(results2.get(tournament.id) != null);
            System.assert(results2.get(tournament.id).size() == 2);

            //just get the group
            List<Brackets_Group__c> groups = BracketsGroupUtilities.getGroups(
                tournament.id,
                testUser.id
            );
            System.assert(groups.size() == 1);
        }

    }
}
