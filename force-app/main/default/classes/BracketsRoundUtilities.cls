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

public with sharing class BracketsRoundUtilities {
    public static final String roundAfterDeadline = 'The current deadline is after previous rounds';
    public static final String roundBeforeDeadline = 'The current deadline is before following rounds';
    public static final String roundNameUnique = 'The round name must be unique in a tournament.';

    /**
     * Set the RoundNumber__c
     * @parms insertedRounds : A list of inserted rounds for this tournament
     */
    public static void roundNumberOnInsert(
        List<Brackets_Round__c> insertedRounds
    ) {
        System.debug('\n\n***RoundNumberOnInsert');
        List<Id> roundTournamentIds = new List<Id>();
        Map<Id, Brackets_Round__c> tournamentRounds = new Map<Id, Brackets_Round__c>();
        Double iter;
        for (Brackets_Round__c nRound : insertedRounds) {
            if (nRound.Brackets_Tournament__c != null) {
                roundTournamentIds.add(nRound.Brackets_Tournament__c);
            }
        }

        Map<Id, Brackets_Tournament__c> tournaments = new Map<Id, Brackets_Tournament__c>(
            [
                SELECT MaxRoundNumber__c
                FROM Brackets_Tournament__c
                WHERE Id IN :roundTournamentIds
            ]
        );
        System.debug('\n\n***Tournaments ' + tournaments);
        Map<Id, Integer> auxMap = new Map<Id, Integer>();

        for (Brackets_Round__c nRound : insertedRounds) {
            if (auxMap.get(nRound.Brackets_Tournament__c) == null) {
                auxMap.put(nRound.Brackets_Tournament__c, 1);
            }

            iter = (tournaments.get(nRound.Brackets_Tournament__c)
                    .MaxRoundNumber__c == null)
                ? 0
                : tournaments.get(nRound.Brackets_Tournament__c)
                        .MaxRoundNumber__c;

            nRound.RoundNumber__c =
                iter + auxMap.get(nRound.Brackets_Tournament__c);
            auxMap.put(
                nRound.Brackets_Tournament__c,
                auxMap.get(nRound.Brackets_Tournament__c) + 1
            );
        }
    }

    /**
     * Method used to insert External Ids on Round objects
     * @param roundList : A list of Rounds to set the ExtrenalId
     */
    //RSC Do we need this?
    /*
    public static void addExternalId( List<Brackets_Round__c> roundList ){
        
        for( Brackets_Round__c round : roundList ){
            if( round.ExternalId__c == null ){
                round.ExternalId__c = BracketsTournamentUtilities.generateRandomExternalId();
            }
        }
    }
    */

    /**
     * Check the integrity between rounds of the same tournaments
     *
     * @param roundListToCheck   a list of rounds.
     */
    public static void checkRoundsIntegrity(
        List<Brackets_Round__c> roundListToCheck
    ) {
        System.debug('CheckRoundsIntegrityRSC');

        List<Brackets_Round__c> roundList = new List<Brackets_Round__c>();
        List<Id> tournamentIds = new List<Id>();

        for (Brackets_Round__c round : roundListToCheck) {
            tournamentIds.add(round.Brackets_Tournament__c);
        }

        List<Brackets_Round__c> existingRounds = [
            SELECT Deadline__c, RoundNumber__c, Name, Brackets_Tournament__c
            FROM Brackets_Round__c
            WHERE Brackets_Tournament__c IN :tournamentIds
            ORDER BY RoundNumber__c ASC
        ];

        for (Brackets_Round__c currentExisting : existingRounds) {
            for (Brackets_Round__c newRound : roundListToCheck) {
                if (newRound.Id != currentExisting.Id) {
                    // check round name is unique per tournament
                    Boolean roundNameIsNotUnique =
                        currentExisting.Brackets_Tournament__c ==
                        newRound.Brackets_Tournament__c &&
                        (newRound.Name == currentExisting.Name);
                    // check current deadline is before to previous rounds.
                    Boolean roundAfter =
                        currentExisting.Brackets_Tournament__c ==
                        newRound.Brackets_Tournament__c &&
                        (newRound.RoundNumber__c <
                        currentExisting.RoundNumber__c &&
                        newRound.Deadline__c > currentExisting.Deadline__c);

                    // check current deadline is after to following rounds.
                    Boolean roundBefore =
                        currentExisting.Brackets_Tournament__c ==
                        newRound.Brackets_Tournament__c &&
                        (newRound.RoundNumber__c >
                        currentExisting.RoundNumber__c &&
                        newRound.Deadline__c < currentExisting.Deadline__c);

                    if (roundAfter) {
                        System.debug('\n\n\nRoundAfter');
                        System.debug('currentExisting: ' + currentExisting);
                        System.debug('newRound: ' + newRound);
                        newRound.Deadline__c.addError(roundAfterDeadline);
                    }

                    if (roundBefore) {
                        System.debug('\n\nSurprise here I am roundbefore');
                        System.debug(
                            '\n\n\nDeadlineXX ToCheck ' + newRound.Deadline__c
                        );
                        System.debug(
                            'Identifying the roundToCheck ' + newRound.name
                        );

                        System.debug(
                            '\n\n\nDeadlineXX Round' +
                            currentExisting.Deadline__c
                        );
                        System.debug(
                            'Identifying the round ' + currentExisting.name
                        );
                        newRound.Deadline__c.addError(roundBeforeDeadline);
                    }

                    if (roundNameIsNotUnique) {
                        newRound.Name.addError(roundNameUnique);
                    }
                }
            }
        }
    }

    /**
     *   Given a list of rounds, check if there changes in them to update the tournament.
     *
     *   @param newRoundList a list of match sobjects
     */
    public static void publishOff(List<Brackets_Round__c> newRoundList) {
        List<Id> tournamentIdList = new List<Id>();
        List<Id> roundIdList = new List<Id>();
        for (Brackets_Round__c round : newRoundList) {
            roundIdList.add(round.Id);
        }
        for (Brackets_Round__c round : [
            SELECT Id, Brackets_Tournament__c
            FROM Brackets_Round__c
            WHERE
                Brackets_Tournament__r.isChild__c = false
                AND Id IN :roundIdList
        ]) {
            tournamentIdList.add(round.Brackets_Tournament__c);
        }

        List<Brackets_Tournament__c> tournamentList = [
            SELECT Id, Allow_Update__c
            FROM Brackets_Tournament__c
            WHERE Id IN :tournamentIdList
        ];
        BracketsTournamentUtilities.publishTournamentOff(tournamentList);
    }
}
