/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/

public with sharing class BracketsMatchesPredictionUtil {
    /**
     *	Upsert a list of match predictions in the database, filtering by the ones which have a predicted winner.
     *
     *	@param 			a list of match predictions
     */
    public static void save(
        List<Brackets_UserMatchPred__c> userMatchPredictions
    ) {
        List<Brackets_UserMatchPred__c> userMatchPredictionsToSave = new List<Brackets_UserMatchPred__c>();
        for (
            Brackets_UserMatchPred__c userMatchPrediction : userMatchPredictions
        ) {
            if (userMatchPrediction.PredictedWinnerBrackets_Team__c != null) {
                userMatchPredictionsToSave.add(userMatchPrediction);
            }
        }
        if (!userMatchPredictionsToSave.isEmpty()) {
            upsert userMatchPredictionsToSave;
        }
    }

    /**
     *  	Given an json string, save the information contained in it.
     *
     * 	@param jsonString	a string with json formant content.
     */
    public static void saveFromJSON(String jsonString, Id UserId) {
        List<Brackets_UserMatchPred__c> matchesPredictionsToUpdate;
        List<Id> predictionIdListToUpdate;
        List<Id> matchesIdList;

        BracketsUserMatchJSONObjectHandler handler;

        handler = new BracketsUserMatchJSONObjectHandler();
        handler.processJSON(jsonString);

        matchesPredictionsToUpdate = checkExistingPredictions(
            handler.matchesPredictionList,
            userId
        );

        // are there any predictions that

        // update the existing matches predictions
        if (!matchesPredictionsToUpdate.isEmpty()) {
            update matchesPredictionsToUpdate;
        }

        // insert the new matches predictions
        if (!handler.matchesPredictionList.isEmpty()) {
            insert handler.matchesPredictionList;
        }
    }

    /**
     * Check if a group of user have predicted these matches, if they have been done remove from the new list and do an updation.
     *
     * @param userMatchPredictionsNew 	a list of match predictions.
     */
    public static List<Brackets_UserMatchPred__c> checkExistingPredictions(
        List<Brackets_UserMatchPred__c> userMatchPredictionsNew,
        Id userId
    ) {
        Brackets_UserMatchPred__c userMatchPrediction;
        Brackets_UserMatchPred__c userMatchPredictionNew;
        Set<Id> matchIdSet = new Set<Id>();
        Boolean predictionIsAlreadyDone = false;
        List<Id> tournamentIds = new List<Id>();
        List<Brackets_UserMatchPred__c> userMatchPredictionToUpdateList = new List<Brackets_UserMatchPred__c>();
        for (Integer j = 0; j < userMatchPredictionsNew.size();) {
            userMatchPredictionNew = userMatchPredictionsNew.get(j);
            //check if not exist the match for this prediction
            if (
                !matchIdSet.contains(userMatchPredictionNew.Brackets_Match__c)
            ) {
                matchIdSet.add(userMatchPredictionNew.Brackets_Match__c);
                j++;
            } else {
                userMatchPredictionsNew.remove(j);
            }
            tournamentIds.add(
                userMatchPredictionNew.Brackets_UserTournament__c
            );
        }
        List<Brackets_UserMatchPred__c> userMatchPredictions = [
            SELECT
                Id,
                Brackets_UserTournament__c,
                Brackets_UserTournament__r.User__c,
                Brackets_Match__c
            FROM Brackets_UserMatchPred__c
            WHERE
                Brackets_UserTournament__c IN :tournamentIds
                AND Brackets_Match__c IN :matchIdSet
                AND Brackets_UserTournament__r.User__c = :userId
        ];

        //Iterate over Brackets_UserMatchPred__c's objects checking if the match's prediction has been done by the same user.
        for (Integer i = 0; i < userMatchPredictions.size(); i++) {
            userMatchPrediction = userMatchPredictions.get(i);
            for (Integer j = 0; j < userMatchPredictionsNew.size(); j++) {
                userMatchPredictionNew = userMatchPredictionsNew.get(j);
                predictionIsAlreadyDone =
                    userMatchPrediction.Id != userMatchPredictionNew.Id &&
                    userMatchPrediction.Brackets_UserTournament__r.User__c ==
                    userId &&
                    userMatchPrediction.Brackets_UserTournament__c ==
                    userMatchPredictionNew.Brackets_UserTournament__c &&
                    userMatchPrediction.Brackets_Match__c ==
                    userMatchPredictionNew.Brackets_Match__c;
                if (predictionIsAlreadyDone) {
                    // if there is an existing prediction update the predicted winner team and add to the new list to upate.
                    userMatchPrediction.PredictedWinnerBrackets_Team__c = userMatchPredictionNew.PredictedWinnerBrackets_Team__c;
                    // remove the new prediction from the list of prediction to insert.
                    userMatchPredictionsNew.remove(j);
                    // add to tne updated list.
                    userMatchPredictionToUpdateList.add(userMatchPrediction);
                    break;
                }
            }
        }
        // return the existing prediction with the predicted.
        return userMatchPredictionToUpdateList;
    }

    /**
     * Updates the points of the user after a match result is updated depending on user prediction.
     *
     * @param matchesForUpdate List of matches to be updated
     */
    public static void updateUserMatchPredictionPoints(
        List<Brackets_Match__c> matchesForUpdate
    ) {
        String query;
        Brackets_Match__c match;
        Id winner;
        Decimal scorePoints;
        List<Brackets_UserMatchPred__c> predictions = new List<Brackets_UserMatchPred__c>();
        String mfuIdsArrayString = '(';
        for (Brackets_Match__c mfu : matchesForUpdate) {
            mfuIdsArrayString += '\'' + mfu.Id + '\',';
        }
        if (!matchesForUpdate.isEmpty()) {
            mfuIdsArrayString = mfuIdsArrayString.substring(
                0,
                mfuIdsArrayString.length() - 1
            );
        }
        mfuIdsArrayString += ')';

        query = 'Select Id, PredictedWinnerBrackets_Team__c, Points__c, Brackets_Match__r.WinnerBrackets_Team__c,Brackets_Match__r.Brackets_Round__r.ScorePoints__c';
        query += ' From Brackets_UserMatchPred__c ';
        query +=
            ' where Brackets_Match__r.Id in ' +
            mfuIdsArrayString +
            ' and Brackets_Match__r.WinnerBrackets_Team__c != null';
        predictions = Database.query(query);
        predictions = updatePointsMatched(predictions);

        // Save results
        massUpdate(predictions, query);
    }

    public static List<Brackets_UserMatchPred__c> updatePointsMatched(
        List<Brackets_UserMatchPred__c> predictions
    ) {
        List<Brackets_UserMatchPred__c> predictionsToUpdate = new List<Brackets_UserMatchPred__c>();
        for (Brackets_UserMatchPred__c prediction : predictions) {
            if (
                prediction.PredictedWinnerBrackets_Team__c ==
                prediction.Brackets_Match__r.WinnerBrackets_Team__c
            ) {
                prediction.Points__c = prediction.Brackets_Match__r.Brackets_Round__r.ScorePoints__c;
                predictionsToUpdate.add(prediction);
            }
        }
        return predictionsToUpdate;
    }

    /**
     * 	Check if in the context the dml rows limit are exceeded execute the dml operation in a batch context.
     */
    private static void massUpdate(
        List<Brackets_UserMatchPred__c> predictions,
        String query
    ) {
        if (predictions.size() > 0) {
            if (predictions.size() >= Limits.getLimitDmlRows() / 2) {
                Database.executeBatch(
                    new BracketsBatchUserMatchPrediction(query),
                    Limits.getLimitDmlRows() / 2
                );
            } else {
                update predictions;
            }
        }
    }
}
