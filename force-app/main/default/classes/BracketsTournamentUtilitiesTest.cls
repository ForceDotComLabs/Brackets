@isTest
class BracketsTournamentUtilitiesTest {
    @isTest
    static void testRoundCount() {
        system.assert(BracketsTournamentUtilities.roundCount(4) == 2);
        system.assert(BracketsTournamentUtilities.roundCount(5) == 0);
        system.assert(BracketsTournamentUtilities.roundCount(32) == 5);
    }

    @isTest
    static void testCreateTournamentTree() {
        Brackets_Tournament__c tournament = new Brackets_Tournament__c();
        tournament.Name = 'Test';
        tournament.TeamCount__c = 8;

        insert tournament;

        system.assert(tournament.Id != null);
    }

    @isTest
    static void testCreateNFLPlayoffs() {
        Brackets_Tournament__c tournament = new Brackets_Tournament__c();
        tournament.Name = 'Test';
        tournament.Type__c = BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE;

        insert tournament;

        system.assert(tournament.Id != null);
    }

    @isTest
    static void testCheckTeamCountNotUpdateable() {
        Brackets_Tournament__c tournament = new Brackets_Tournament__c();
        tournament.Name = 'Test';
        tournament.Type__c = BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE;

        insert tournament;

        tournament.TeamCount__c = 18;

        try {
            upsert tournament;
        } catch (DmlException e) {
            system.assert(
                e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')
            );
        }
    }

    @isTest
    static void testTournamentList() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        Brackets_Tournament__c tournament = new Brackets_Tournament__c();
        tournament.Name = 'Test';
        tournament.Type__c = BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE;
        tournament.isChild__c = true;
        insert tournament;

        List<ID> ids = new List<ID>();
        ids.add(tournament.id);

        List<Brackets_Tournament__c> tours = BracketsTournamentUtilities.getTournamentList(
            ids
        );
        System.assert(tours.size() == 1);
        System.assert(tours.get(0).name == tournament.name);

        List<Brackets_Tournament__c> tours2 = BracketsTournamentUtilities.getTournamentList(
            1
        );
        System.assert(tours2.size() == 1);
    }
}
