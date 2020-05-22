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

public with sharing class BracketsTournamentUtilities {
    //-------------------------------------------------------------------------
    // Constants & Variables
    //-------------------------------------------------------------------------
    public static final Integer DEFAULT_ROUND_SCORE_POINTS = 1;
    public static final String DEFAULT_TOURNAMENT_TYPE = 'Standard';
    public static final String STANDARD_TOURNAMENT_TYPE = 'Standard';
    public static final String NFL_PLAYOFF_TOURNAMENT_TYPE = 'NFL Playoff';
    public static final String NFL_CONFERENCE_AMERICAN = 'AFC';
    public static final String NFL_CONFERENCE_NATIONAL = 'NFC';

    private static final String DEFAULT_ROUND_NAME_PREFIX = 'Round ';
    private static final String NOT_POW_TWO_TEAM_COUNT = 'This number must be power of two, for example: 2,4,8,16,32,64,128,256, ..';
    private static final String FIELD_NOT_UPDATEABLE = 'This field is not updatable.';
    private static final String NFL_TEAM_COUNT_ERROR = 'NFL team count must be 12';
    private static final Integer NFL_PLAYOFF_TEAMS = 12;
    private static final Integer TEAMS_COUNT_MAX = 32;

    public static Boolean CreatingTournamentTree = false;

    //-------------------------------------------------------------------------
    // Public Methods
    //-------------------------------------------------------------------------

    /**
     *   Create a tournament skeleton
     *
     *   @param  tournamentCol Tournament insert list
     */
    public static void createTournamentTree(
        List<Brackets_Tournament__c> tournamentCol
    ) {
        Integer teamCount, roundCount;
        Id playoffCol = null;
        Id standardCol = null;
        Map<Id, Integer> teamsCol = new Map<Id, Integer>();
        Map<Id, Integer> roundsCol = new Map<Id, Integer>();

        for (Brackets_Tournament__c tournament : tournamentCol) {
            if (tournament.Type__c == NFL_PLAYOFF_TOURNAMENT_TYPE) {
                playoffCol = tournament.Id;
            } else {
                standardCol = tournament.Id;
                teamCount = (tournament.TeamCount__c == null)
                    ? 0
                    : Math.floor(tournament.TeamCount__c).intValue();
                roundCount = roundCount(teamCount);
            }
            break;
        }

        if (playoffCol != null) {
            BracketsTournamentUtilities.createNFLPlayoffTournamentTree(
                playoffCol
            );
        }

        if (standardCol != null) {
            if (teamCount > TEAMS_COUNT_MAX) {
                BracketsTournamentUtilities.createTournamentTreeFuture(
                    standardCol,
                    teamCount,
                    roundCount
                );
            } else {
                BracketsTournamentUtilities.createTournamentTreeCall(
                    standardCol,
                    teamCount,
                    roundCount
                );
            }
        }
    }

    /**
     *   Create a NFL Playoff tournament
     *
     *   @param  tournamentCol Set of tournament identifiers
     */
    public static void createNFLPlayoffTournamentTree(Id tid) {
        createNFLPlayoffTournamentTreeMethod(tid);
    }

    /**
     *   Create a standard tournament skeleton for each tournament
     *
     *   @param  tournamentCol Set of tournament identifiers
     *   @param  teamsCount    Number of teams for each tournament
     *   @param  roundsCount   Number of rounds for each tournament
     */
    public static void createTournamentTreeCall(
        Id tid,
        Integer teamsCount,
        Integer roundsCount
    ) {
        createTournamentTreeMethod(tid, teamsCount, roundsCount);
    }

    @future
    public static void createTournamentTreeFuture(
        Id tid,
        Integer teamsCount,
        Integer roundsCount
    ) {
        createTournamentTreeCall(tid, teamsCount, roundsCount);
    }

    /**
     *   Check if the team count is power of 2 and return the number of rounds
     *
     *   @param teamCount Total of teams
     *   @return          Number of Rounds
     */
    public static Integer roundCount(Integer teamCount) {
        Integer i = teamCount;
        Integer r = 0;

        while (i > 1) {
            if (Math.mod(i, 2) == 0) {
                i = i / 2;
                r = r + 1;
            } else {
                return 0;
            }
        }

        return r;
    }

    /**
     *   Method used to generate random alfa-numeric strings
     *
     *   @return result
     */
    //TODO Delete
    /*
    public Static String generateRandomExternalId(){
        
        String[] code   = new String[]{'A','B','C','D','E','F','G','H','I','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'};
        String result   = '';
        
        for( Integer i = 0; i < 10; i++ ){
            Integer index = Math.mod(  (Math.random() * 100).intValue(), 60);
            result += code[ index ]; 
        }
        
        return result;
    }
    */

    /**
     *   Method used to insert External Ids on tournament objects
     *
     *   @param tournamentList
     */
    //TODO DELETE
    /*
    public static void addExternalId( List<Brackets_Tournament__c> tournamentList ){

        for( Brackets_Tournament__c tour : tournamentList ){
            if( tour.ExternalId__c == null ){
                tour.ExternalId__c = BracketsTournamentUtilities.generateRandomExternalId();            
            }
        }
    }
	*/
    /**
     *   Given a list of tournament, check the teamCount field if it is pow of 2.
     *
     *   @param tournamentList   A list of tournament.
     */
    public static void checkTeamCount(
        List<Brackets_Tournament__c> tournamentList
    ) {
        Integer roundCount;
        Integer teamCount;
        for (Brackets_Tournament__c tournament : tournamentList) {
            if (
                tournament.Type__c == DEFAULT_TOURNAMENT_TYPE &&
                tournament.TeamCount__c != null
            ) {
                teamCount = Math.floor(tournament.TeamCount__c).intValue();
                roundCount = BracketsTournamentUtilities.roundCount(teamCount);
                if (teamCount != 0 && roundCount == 0) {
                    tournament.addError(NOT_POW_TWO_TEAM_COUNT);
                }
            } else if (tournament.Type__c == NFL_PLAYOFF_TOURNAMENT_TYPE) {
                tournament.TeamCount__c = NFL_PLAYOFF_TEAMS;
            }
        }
    }

    /**
     *   Given a two list of tournament sobjects, checks the field named TeamCount__c is not updateable.
     */
    public static void checkTeamCountNotUpdateable(
        List<Brackets_Tournament__c> tournamentNewList,
        List<Brackets_Tournament__c> tournamentOldList
    ) {
        Brackets_Tournament__c oldTournament, newTournament;
        for (Integer i = 0; i < tournamentNewList.size(); i++) {
            oldTournament = tournamentOldList.get(i);
            newTournament = tournamentNewList.get(i);
            if (newTournament.Type__c == NFL_PLAYOFF_TOURNAMENT_TYPE) {
                if (
                    newTournament.TeamCount__c.intValue() != NFL_PLAYOFF_TEAMS
                ) {
                    newTournament.TeamCount__c.addError(NFL_TEAM_COUNT_ERROR);
                }
            } else if (
                oldTournament.TeamCount__c != newTournament.TeamCount__c
            ) {
                newTournament.TeamCount__c.addError(FIELD_NOT_UPDATEABLE);
            }
        }
    }

    /**
     *   Given a list of tournament ids, returns a list of tournament sobjects.
     *
     *   @param tournamentList       a list of tournament ids.
     *   @return                     a list of tournament sobjects.
     */
    public static List<Brackets_Tournament__c> getTournamentList(
        List<Id> tournamentIdList
    ) {
        return [
            SELECT Id, Name
            FROM Brackets_Tournament__c
            WHERE Id IN :tournamentIdList
        ];
    }

    /**
     *   Return a list of imported tournaments to be updated, the ones with oldest LastModifiedDate field.
     *
     *   @param size     number of tournament
     *   @return         a list of imported tournament
     */
    public static List<Brackets_Tournament__c> getTournamentList(Integer size) {
        return [
            SELECT Id, Update_Source__c, LastModifiedDate
            FROM Brackets_Tournament__c
            WHERE isChild__c = true
            ORDER BY LastModifiedDate ASC
            LIMIT :size
        ];
    }

    /**
     *   Create a tournament skeleton
     *
     *   @param  tournamentId Tournament identifier
     *   @param  teamCount    Number of teams
     *   @param  roundCount   Number of rounds
     */

    public static void createTournamentTreeMethod(
        String tournamentId,
        Integer teamCount,
        Integer roundCount
    ) {
        // Set global flag
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        if (tournamentId != null) {
            // Create Rounds
            Brackets_Round__c round;
            List<Brackets_Round__c> roundCol = new List<Brackets_Round__c>();

            for (Integer i = 0; i < roundCount; i++) {
                round = new Brackets_Round__c();

                round.Brackets_Tournament__c = tournamentId;
                round.ScorePoints__c = DEFAULT_ROUND_SCORE_POINTS;
                round.Name = DEFAULT_ROUND_NAME_PREFIX + (i + 1).format();
                round.RoundNumber__c = i + 1;

                roundCol.add(round);
            }

            insert roundCol;

            // Create Matches
            Integer matchCount = teamCount;
            List<Brackets_Match__c> currRoundMatches = new List<Brackets_Match__c>();
            List<Brackets_Match__c> prevRoundMatches = new List<Brackets_Match__c>();
            Brackets_Match__c match;
            Integer currMatch;

            for (
                Integer roundNumber = 0; roundNumber < roundCount; roundNumber++
            ) {
                matchCount = matchCount / 2;
                prevRoundMatches = currRoundMatches;
                currRoundMatches = new List<Brackets_Match__c>();

                // Create current round matches
                for (Integer k = 0; k < matchCount; k++) {
                    match = new Brackets_Match__c();

                    match.Brackets_Round__c = roundCol[roundNumber].Id;
                    match.Position__c = k + 1;

                    currRoundMatches.add(match);
                }

                insert currRoundMatches;

                // Link previous round matches
                if (prevRoundMatches.size() != 0) {
                    for (
                        Integer prevMatch = 0;
                        prevMatch < prevRoundMatches.size();
                        prevMatch++
                    ) {
                        currMatch = Math.floor(prevMatch / 2).intValue();
                        prevRoundMatches[prevMatch]
                            .FollowingBrackets_Match__c = currRoundMatches[
                                currMatch
                            ]
                            .Id;
                        prevRoundMatches[prevMatch]
                            .FollowingIsHome__c = Math.mod(prevMatch, 2) == 0
                            ? true
                            : false;
                    }

                    update prevRoundMatches;
                }
            }
        }

        // Unset global flag
        BracketsTournamentUtilities.CreatingTournamentTree = false;
    }

    /**
     *   Create a NFL Playoff tournament
     *
     *   @param  tournamentId Tournament identifier
     */
    public static void createNFLPlayoffTournamentTreeMethod(
        String tournamentId
    ) {
        // Set global flag
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        if (tournamentId != null) {
            // Create Rounds
            List<Brackets_Round__c> roundCol = BracketsTournamentUtilities.createNFLRounds(
                tournamentId
            );

            /**
             * Hack to fix security scanner bugs
             */
            // Init matches
            List<Brackets_Match__c> allNFLMatches = new List<Brackets_Match__c>();
            Brackets_Match__c mTemp;
            for (Integer i = 0; i < 11; i++) {
                mTemp = new Brackets_Match__c();

                if (i < 4) {
                    mTemp.Brackets_Round__c = roundCol[0].Id;
                } else if (i >= 4 && i < 8) {
                    mTemp.Brackets_Round__c = roundCol[1].Id;
                } else if (i >= 8 && i < 10) {
                    mTemp.Brackets_Round__c = roundCol[2].Id;
                } else {
                    mTemp.Brackets_Round__c = roundCol[3].Id;
                }

                allNFLMatches.add(mTemp);
            }

            insert allNFLMatches;

            // Create Matches
            BracketsTournamentUtilities.createNFLWCRoundMatches(allNFLMatches);

            //   2. Divisional Round
            BracketsTournamentUtilities.createNFLDRoundMatches(allNFLMatches);

            //   3. Conference Championships
            BracketsTournamentUtilities.createNFLCRoundMatches(allNFLMatches);

            //   4. Super Bowl
            BracketsTournamentUtilities.createNFLSuperBowlMatch(allNFLMatches);

            upsert allNFLMatches;
        }

        // Unset global flag
        BracketsTournamentUtilities.CreatingTournamentTree = false;
    }

    //-------------------------------------------------------------------------
    // Private methods
    //-------------------------------------------------------------------------

    /**
     *   Create NFL playoff rounds
     *
     *   @param tournamentId Id of the new tournament
     *   @return             List of NFL playoff rounds
     */
    private static List<Brackets_Round__c> createNFLRounds(
        String tournamentId
    ) {
        Brackets_Round__c round;
        List<Brackets_Round__c> roundCol = new List<Brackets_Round__c>();

        // Wild Card Round
        round = new Brackets_Round__c();

        round.Brackets_Tournament__c = tournamentId;
        round.ScorePoints__c = 5;
        round.Name = 'Wild Card Round';
        round.RoundNumber__c = 1;

        roundCol.add(round);

        // Divisional Round
        round = new Brackets_Round__c();

        round.Brackets_Tournament__c = tournamentId;
        round.ScorePoints__c = 7;
        round.Name = 'Divisional Round';
        round.RoundNumber__c = 2;

        roundCol.add(round);

        // Conference championship
        round = new Brackets_Round__c();

        round.Brackets_Tournament__c = tournamentId;
        round.ScorePoints__c = 11;
        round.Name = 'Conference Championship';
        round.RoundNumber__c = 3;

        roundCol.add(round);

        // Super Bowl
        round = new Brackets_Round__c();

        round.Brackets_Tournament__c = tournamentId;
        round.ScorePoints__c = 17;
        round.Name = 'Super Bowl';
        round.RoundNumber__c = 4;

        roundCol.add(round);

        insert roundCol;

        return roundCol;
    }

    /**
     *   Create NFL Playoff "Wild Card Round" matches
     */
    public static void createNFLWCRoundMatches(
        List<Brackets_Match__c> matchCol
    ) {
        // First Match
        matchCol[0].Position__c = 1;
        matchCol[0].Conference__c = NFL_CONFERENCE_AMERICAN;
        matchCol[0]
            .Description__c = 'Wild Card 1 ( Team 1 ) vs Division Winner 4 ( Team 2 )';
        matchCol[0].FollowingIsHome__c = true;
        matchCol[0].FollowingBrackets_Match__c = matchCol[4].Id;

        // Second Match
        matchCol[1].Position__c = 2;
        matchCol[1].Conference__c = NFL_CONFERENCE_AMERICAN;
        matchCol[1]
            .Description__c = 'Division Winner 3 ( Team 1 ) vs Wild Card 2 ( Team 2 )';
        matchCol[1].FollowingIsHome__c = false;
        matchCol[1].FollowingBrackets_Match__c = matchCol[5].Id;

        // Third Match
        matchCol[2].Position__c = 3;
        matchCol[2].Conference__c = NFL_CONFERENCE_NATIONAL;
        matchCol[2]
            .Description__c = 'Wild Card 1 ( Team 1 ) vs Division Winner 4 ( Team 2 )';
        matchCol[2].FollowingIsHome__c = true;
        matchCol[2].FollowingBrackets_Match__c = matchCol[6].Id;

        // Fourth Match
        matchCol[3].Position__c = 4;
        matchCol[3].Conference__c = NFL_CONFERENCE_NATIONAL;
        matchCol[3]
            .Description__c = 'Division Winner 3 ( Team 1 ) vs Wild Card 2 ( Team 2 )';
        matchCol[3].FollowingIsHome__c = false;
        matchCol[3].FollowingBrackets_Match__c = matchCol[7].Id;
    }

    /**
     *   Create NFL Playoff "Divisional Round" matches
     */
    public static void createNFLDRoundMatches(
        List<Brackets_Match__c> matchCol
    ) {
        // First Match
        matchCol[4].Position__c = 1;
        matchCol[4].Conference__c = NFL_CONFERENCE_AMERICAN;
        matchCol[4]
            .Description__c = 'DW 4, WC 1 or WC 2 ( Team 1 ) vs Division Winner 1 ( Team 2 )';
        matchCol[4].FollowingIsHome__c = true;
        matchCol[4].FollowingBrackets_Match__c = matchCol[8].Id;

        // Second Match
        matchCol[5].Position__c = 2;
        matchCol[5].Conference__c = NFL_CONFERENCE_AMERICAN;
        matchCol[5]
            .Description__c = 'Division Winner 2 ( Team 1 ) vs DW 3, DW 4 or WC 1 ( Team 2 )';
        matchCol[5].FollowingIsHome__c = false;
        matchCol[5].FollowingBrackets_Match__c = matchCol[8].Id;

        // Third Match
        matchCol[6].Position__c = 3;
        matchCol[6].Conference__c = NFL_CONFERENCE_NATIONAL;
        matchCol[6]
            .Description__c = 'DW 4, WC 1 or WC 2 ( Team 1 ) vs Division Winner 1 ( Team 2 )';
        matchCol[6].FollowingIsHome__c = true;
        matchCol[6].FollowingBrackets_Match__c = matchCol[9].Id;

        // Fourth Match
        matchCol[7].Position__c = 4;
        matchCol[7].Conference__c = NFL_CONFERENCE_NATIONAL;
        matchCol[7]
            .Description__c = 'Division Winner 2 ( Team 1 ) vs DW 3, DW 4 or WC 1 ( Team 2 )';
        matchCol[7].FollowingIsHome__c = false;
        matchCol[7].FollowingBrackets_Match__c = matchCol[9].Id;
    }

    /**
     *   Create NFL Playoff "Conference Championship" round matches
     */
    public static void createNFLCRoundMatches(
        List<Brackets_Match__c> matchCol
    ) {
        // AFC Championship match
        matchCol[8].Position__c = 1;
        matchCol[8].Conference__c = NFL_CONFERENCE_AMERICAN;
        matchCol[8].Description__c = 'DR1 ( Team 1 ) vs DR2  ( Team 2 )';
        matchCol[8].FollowingIsHome__c = true;
        matchCol[8].FollowingBrackets_Match__c = matchCol[10].Id;

        // NFC Championship match
        matchCol[9].Position__c = 2;
        matchCol[9].Conference__c = NFL_CONFERENCE_NATIONAL;
        matchCol[9].Description__c = 'DR3 ( Team 1 ) vs DR4 ( Team 2 )';
        matchCol[9].FollowingIsHome__c = false;
        matchCol[9].FollowingBrackets_Match__c = matchCol[10].Id;
    }

    /**
     *   Create NFL Playoff "Super Bowl" match
     */
    public static void createNFLSuperBowlMatch(
        List<Brackets_Match__c> matchCol
    ) {
        matchCol[10].Position__c = 1;
        matchCol[10]
            .Description__c = 'AFC Champion ( Team 1 ) vs NFC Champion ( Team 2 )';
    }

    /**
     *   Given two list of tournaments, update the field Allow_Update if there are changes.
     *
     *   @param newTournamentList    a list of tournament sobjects
     */
    public static void publishOff(
        List<Brackets_Tournament__c> newList,
        List<Brackets_Tournament__c> oldList
    ) {
        System.debug('1234: in publish off');
        for (Integer i = 0; i < newList.size(); i++) {
            if (
                newList.get(i).Allow_Update__c && oldList.get(i).Allow_Update__c
            ) {
                System.debug('1234: here I am turning allow update off');
                newList.get(i).Allow_Update__c = false;
            }
        }
    }

    /**
     *   Given a list of tournaments, update the tournaments modified.
     *
     *   @param tournamentList   a list of tournament sobjects
     */
    public static void publishTournamentOff(
        List<Brackets_Tournament__c> tournamentList
    ) {
        for (Brackets_Tournament__c tournament : tournamentList) {
            tournament.Allow_Update__c = false;
        }
        update tournamentList;
    }

    public static void checkIfIsPublished(List<Brackets_Tournament__c> myTour) {
        for (Brackets_Tournament__c to : myTour) {
            System.assert(
                !to.Allow_Update__c,
                'This Tournament can not be deleted!'
            );
        }
    }
}
