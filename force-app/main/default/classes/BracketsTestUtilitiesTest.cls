@isTest
class BracketsTestUtilitiesTest {
    @isTest
    static void testRandomWord() {
        System.assert(
            BracketsTestUtilities.createRandomWord() !=
            BracketsTestUtilities.createRandomWord()
        );
    }

    @isTest
    static void testCreateUser() {
        User u = BracketsTestUtilities.createUser();
        system.assert(u != null);
        system.assert(u.Id != null);
    }

    @isTest
    static void testCreateAndUpsertTeam() {
        Brackets_Team__c team = BracketsTestUtilities.createTeam('MyTeam');
        system.assert(team != null);
        system.assert(team.Name == 'MyTeam');
    }

    @isTest
    static void testCreateTeamList() {
        List<Brackets_Team__c> someTeams = BracketsTestUtilities.createTeamList(
            4
        );
        system.assert(someTeams.size() == 4);
    }

    @isTest
    static void testGetRandomTeam() {
        List<Brackets_Team__c> teams = BracketsTestUtilities.createTeamList(2);

        upsert teams;

        Brackets_Team__c t = BracketsTestUtilities.getRandomTeam(teams);
        system.assert(t != null);
        system.assert(t.Name != null && t.Name != '');
    }

    @isTest
    static void testCreateTournamet() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Tournament-',
            2
        );
        system.assert(tournament != null);
    }

    @isTest
    static void testCreateRound() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Tournament-',
            2
        );
        Brackets_Round__c round = BracketsTestUtilities.createSimpleRound(
            tournament
        );
        system.assert(round != null);
    }

    @isTest
    static void testCreateMatch() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Tournament-',
            2
        );
        Brackets_Round__c round = BracketsTestUtilities.createSimpleRound(
            tournament
        );
        Brackets_Match__c match = BracketsTestUtilities.createMatch(
            null,
            null,
            round,
            null
        );

        system.assert(match != null);
    }

    @isTest
    static void testCreateUserTournamet() {
        User user = BracketsTestUtilities.createUser();
        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Tournament-',
            2
        );
        Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
            tournament.Id
        );
        Brackets_UserTournament__c ut = BracketsTestUtilities.createUserTournament(
            user.Id,
            tournament.Id,
            groupp.Id
        );
        system.assert(ut != null);
    }

    @isTest
    static void testCreateUserMatchPrediction() {
        User user = BracketsTestUtilities.createUser();
        Brackets_Tournament__c tournament = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c uGroup = BracketsTestUtilities.getGroup(
            tournament.Id
        );
        Brackets_UserTournament__c ut = BracketsTestUtilities.createUserTournament(
            user.Id,
            tournament.Id,
            uGroup.Id
        );
        Brackets_Round__c round = BracketsTestUtilities.createSimpleRound(
            tournament
        );
        List<Brackets_Team__c> teams = BracketsTestUtilities.createTeamList(2);

        Brackets_Team__c home = teams[0];
        Brackets_Team__c visitor = teams[1];
        upsert teams;

        Brackets_Match__c match = BracketsTestUtilities.createMatch(
            home,
            visitor,
            round,
            null
        );
        Brackets_Team__c winner = home;

        BracketsTestUtilities.createUserMatchPrediction(
            tournament.Id,
            uGroup.Id,
            ut.Id
        );

        List<Brackets_UserMatchPred__c> predictions = [
            SELECT Id
            FROM Brackets_UserMatchPred__c
            WHERE Brackets_UserTournament__c = :ut.Id
        ];
        system.assert(!predictions.isEmpty(), predictions);
    }

    @isTest
    static void testCreateFullTournament() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createFullTournament(
            4,
            BracketsTournamentUtilities.DEFAULT_TOURNAMENT_TYPE
        );
        system.assert(tournament != null);
    }
}
