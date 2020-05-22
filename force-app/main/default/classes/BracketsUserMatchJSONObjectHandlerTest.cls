@isTest
class BracketsUserMatchJSONObjectHandlerTest {
    @isTest
    static void testProcessJSON() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
            tournament.Id
        );
        Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');
        Brackets_Team__c teamB = BracketsTestUtilities.createTeam('B-Team');

        List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
        auxList.add(teamA);
        auxList.add(teamB);
        upsert auxList;

        Brackets_Round__c round = BracketsTestUtilities.createSimpleRound(
            tournament
        );
        Brackets_Match__c match = BracketsTestUtilities.createMatch(
            teamA,
            teamB,
            round,
            null
        );
        Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
            Userinfo.getUserId(),
            tournament.Id,
            groupp.Id
        );
        String jsonString =
            '{ "0" : { "matchId" : "' +
            match.Id +
            '" ,"userTour" : "' +
            userTournament.Id +
            '", "teamId" : "' +
            teamA.Id +
            '" , "userPred" : "" }}';

        BracketsUserMatchJSONObjectHandler handler = new BracketsUserMatchJSONObjectHandler();
        handler.processJSON(jsonString);
        System.assert(
            handler.matchesPredictionList.size() == 1,
            'Should have a user match prediction empty at least.'
        );
        Brackets_UserMatchPred__c prediction = handler.matchesPredictionList.get(
            0
        );
        System.assert(
            prediction.Brackets_Match__c == match.Id &&
            prediction.Brackets_UserTournament__c == userTournament.Id &&
            prediction.PredictedWinnerBrackets_Team__c == teamA.Id,
            'This prediction should have a match ' +
            match.Id +
            ' ,an userTournament ' +
            userTournament.Id +
            ' and a predictedWinnerTeam ' +
            teamA.Id
        );
    }

    @isTest
    static void testProcessWrongJSON() {
        String jsonString = ' "0" : { "matchId" : "" ,"userTour" : "", "teamId" : "" , "userPred" : "" }}';
        BracketsUserMatchJSONObjectHandler handler = new BracketsUserMatchJSONObjectHandler();
        try {
            handler.processJSON(jsonString);
            System.assert(false, 'This line shouldn\'t be executed');
        } catch (Exception e) {
            System.assert(
                true,
                'An error should happen when parsing the JSON.'
            );
        }
    }
}
