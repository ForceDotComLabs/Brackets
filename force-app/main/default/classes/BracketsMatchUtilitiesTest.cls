@isTest
class BracketsMatchUtilitiesTest {
    //-------------------------------------------------------------------------
    // Test Methods
    //-------------------------------------------------------------------------

    @isTest
    static void testDateMatchesValidation() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Checking dates',
            2
        );
        Brackets_Round__c round = BracketsTestUtilities.createRound(
            tournament,
            1,
            DateTime.now(),
            3,
            'First Round'
        );

        Brackets_Team__c homeTeam, visitorTeam;
        List<Brackets_Match__c> matches = new List<Brackets_Match__c>{
            new Brackets_Match__c(),
            new Brackets_Match__c(),
            new Brackets_Match__c()
        };

        // Standard flow
        matches[0].Schedule__c = DateTime.now().addDays(1);
        matches[0].Brackets_Round__c = round.Id;

        matches[1].Schedule__c = DateTime.now().addDays(2);
        matches[1].Brackets_Round__c = round.Id;

        matches[2].Schedule__c = DateTime.now().addDays(5);
        matches[2].Brackets_Round__c = round.Id;

        insert matches;

        matches[0].FollowingBrackets_Match__c = matches[1].Id;
        matches[1].FollowingBrackets_Match__c = matches[2].Id;

        upsert matches;

        matches[1].Schedule__c = DateTime.now().addDays(3);

        upsert matches;

        system.assert(matches.size() == 3);
    }

    @isTest
    static void testUpdateFollowingMatchesWinner() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Checking winners',
            2
        );
        Brackets_Round__c firstRound = BracketsTestUtilities.createRound(
            tournament,
            1,
            DateTime.now(),
            3,
            'First Round'
        );
        Brackets_Round__c secondRound = BracketsTestUtilities.createRound(
            tournament,
            2,
            DateTime.now().addDays(5),
            5,
            'Second Round'
        );
        List<Brackets_Team__c> teams = BracketsTestUtilities.createTeamList(2);
        insert teams;

        Brackets_Team__c homeTeam, visitorTeam;
        List<Brackets_Match__c> matches = new List<Brackets_Match__c>{
            new Brackets_Match__c(),
            new Brackets_Match__c()
        };

        matches[0].Brackets_Round__c = firstRound.Id;
        matches[0].HomeBrackets_Team__c = teams[0].Id;
        matches[0].VisitorBrackets_Team__c = teams[1].Id;
        matches[1].Brackets_Round__c = secondRound.Id;
        insert matches;

        matches[0].FollowingBrackets_Match__c = matches[1].Id;
        matches[0].HomeScore__c = 25;
        matches[0].VisitorScore__c = 24;
        matches[0].WinnerBrackets_Team__c = teams[0].Id;
        update matches[0];

        Map<Id, Brackets_Match__c> matchesMap = new Map<Id, Brackets_Match__c>();
        matchesMap.put(matches[0].Id, matches[0]);
        System.assert(
            matches[0].HomeBrackets_Team__c == matches[0].WinnerBrackets_Team__c
        );

        //check the first level completed for the matches[0]
        try {
            BracketsMatchUtilities.checkFirstLevelCompleted(
                tournament,
                matchesMap
            );
            System.assert(true, 'This line should be executed.');
        } catch (Exception e) {
            System.assert(false, 'This line shouldn\'t be executed.');
        }

        matchesMap.put(matches[1].Id, matches[1]);
        //check the first level completed for the whole matches
        try {
            BracketsMatchUtilities.checkFirstLevelCompleted(
                tournament,
                matchesMap
            );
            System.assert(false, 'This line shouldn\'t be executed.');
        } catch (Exception e) {
            System.assert(true, 'This line should be executed.');
        }
    }
}
