@isTest
class BracketsTeamUtilitiesTest {
    @isTest
    static void testCanDeleteTeams() {
        List<Brackets_Team__c> teamList = BracketsTestUtilities.createTeamList(
            10
        );
        upsert teamList;
        //not connected to a tournament so its fine.
        system.assert(BracketsTeamUtilities.canDeleteTeams(teamList));

        BracketsTournamentUtilities.CreatingTournamentTree = true;
        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 RoundByRound',
                4
            );
            Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');

            List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
            auxList.add(teamA);
            upsert auxList;

            Brackets_Round__c round = BracketsTestUtilities.createRound(
                tournament,
                1,
                null,
                4,
                'Round1-Test'
            );
            Brackets_Match__c match = BracketsTestUtilities.createMatch(
                teamA,
                null,
                round,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );

            system.assert(!BracketsTeamUtilities.canDeleteTeams(auxList));

            //so now test the trigger
            try {
                delete teamA;
                System.assert(false);
            } catch (Exception e) {
                //correct
            }
        }
    }
}
