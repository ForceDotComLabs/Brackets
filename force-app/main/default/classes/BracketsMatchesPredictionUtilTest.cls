@isTest
class BracketsMatchesPredictionUtilTest {
    //Test checkExistingPredictions()
    @isTest
    static void testCheckExistingPredictions() {
        //generate Enviroment
        Brackets_Tournament__c myTour = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c myGroup = BracketsTestUtilities.getGroup(myTour.Id);
        Brackets_UserTournament__c uTour = BracketsTestUtilities.createUserTournament(
            UserInfo.getUserId(),
            myTour.Id,
            myGroup.Id
        );
        BracketsTestUtilities.createUserMatchPrediction(
            myTour.Id,
            myGroup.Id,
            uTour.Id
        );
        List<Brackets_UserMatchPred__c> uMatchPred = [
            SELECT
                u.Id,
                u.Brackets_UserTournament__c,
                u.PredictedWinnerBrackets_Team__c,
                u.Brackets_Match__r.HomeBrackets_Team__c,
                u.Brackets_Match__c
            FROM Brackets_UserMatchPred__c u
            WHERE u.Brackets_UserTournament__c = :uTour.Id
        ];

        BracketsMatchesPredictionUtil.checkExistingPredictions(
            uMatchPred,
            Userinfo.getUserId()
        );
        System.assert(myTour != null);

        BracketsMatchesPredictionUtil.save(uMatchPred);
    }
}
