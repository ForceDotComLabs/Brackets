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

public with sharing class BracketsMatchUtilities {
    public static final String TEAM_JUST_SELECTED = 'Some of the teams have been selected for another match in this round.';
    public static final String FIRST_ROUND_NOT_COMPLETED = 'Cannot publish. All starting matches much be complete before publishing. Check your matches and start again.';
    public static Boolean SKIP_TRIGGER = false;

    /**
     * Check if all statics list of Tournament and Rounds are setted;
     * @params newMatchList
     */
    public static void getTriggerInstance(
        List<Brackets_Match__c> newMatchList
    ) {
        BracketsTriggerUtilities.newTriggerInstance(newMatchList);
    }

    /**
     * Check if Scheduler Match is greater than its predecessors and lower than the following match
     * @param matchesNew a list of matches.
     */
    public static void dateMatchesValidation(
        List<Brackets_Match__c> matchesNew
    ) {
        BracketsTriggerUtilities.newTriggerInstance(matchesNew);
        Datetime mySchedule;

        for (
            Brackets_Match__c currentMatch : BracketsTriggerUtilities.triggerListObject.values()
        ) {
            Brackets_Match__c cMatch = BracketsTriggerUtilities.triggerListObject.get(
                currentMatch.Id
            );
            Brackets_Match__c fMatch = BracketsTriggerUtilities.triggerMatchMap.get(
                currentMatch.FollowingBrackets_Match__c
            );

            if (fMatch != null) {
                mySchedule = fMatch.Schedule__c;
                if (currentMatch.Schedule__c > mySchedule) {
                    cMatch.Schedule__c.addError(
                        'The date of a match must be lower than its successor [successor match] ' +
                        fMatch.id +
                        ' [scheduled] ' +
                        mySchedule
                    );
                    return;
                }
            }
            for (
                Brackets_Match__c verList : BracketsTriggerUtilities.triggerMatchList
            ) {
                fMatch = BracketsTriggerUtilities.triggerListObject.get(
                    currentMatch.Id
                );
                if (verList.FollowingBrackets_Match__c == fMatch.Id) {
                    if (fMatch.Schedule__c < verList.Schedule__c) {
                        cMatch.Schedule__c.addError(
                            'The date of a match must be greater than its predecessor'
                        );
                    }
                }
            }
        }
    }

    /**
     *	Check if teams for new matches have been assigned the another matches in the same round.
     *
     *	@param userMatchPredictionsNew 	a list of matches.
     */
    public static void checkExistMatchesInRound(
        List<Brackets_Match__c> matchesNew
    ) {
        BracketsTriggerUtilities.newTriggerInstance(matchesNew);
        List<Brackets_Match__c> matches = new List<Brackets_Match__c>();
        Boolean homeTeamInMatch = false;
        Boolean visitorTeamInMatch = false;
        Brackets_Round__c roundMatchNew;
        Brackets_Round__c roundMatch;
        Decimal roundMatchNewNumber;
        Decimal roundMatchNumber;
        Decimal diffRounds;

        for (Integer j = 0; j < matchesNew.size(); j++) {
            for (
                Brackets_Match__c m : BracketsTriggerUtilities.triggerMatchList
            ) {
                roundMatch = BracketsTriggerUtilities.triggerRoundMap.get(
                    m.Brackets_Round__c
                );
                roundMatchNew = BracketsTriggerUtilities.triggerRoundMap.get(
                    matchesNew.get(j).Brackets_Round__c
                );
                roundMatchNewNumber = (Decimal) roundMatch.get(
                    'RoundNumber__c'
                );
                roundMatchNumber = (Decimal) roundMatchNew.get(
                    'RoundNumber__c'
                );
                diffRounds = Math.abs(roundMatchNewNumber - roundMatchNumber);
                if (diffRounds <= 1) {
                    matches.add(
                        BracketsTriggerUtilities.triggerMatchMap.get(m.Id)
                    );
                }
            }
        }

        // Iterate over the matches to found if the team has already been used
        for (Brackets_Match__c matchNew : matchesNew) {
            for (Brackets_Match__c match : matches) {
                if (
                    match.Id != matchNew.Id &&
                    match.Brackets_Round__c == matchNew.Brackets_Round__c
                ) {
                    homeTeamInMatch = existsTeamInMatch(
                        matchNew.HomeBrackets_Team__c,
                        match
                    );
                    visitorTeamInMatch = existsTeamInMatch(
                        matchNew.VisitorBrackets_Team__c,
                        match
                    );
                    if (homeTeamInMatch || visitorTeamInMatch) {
                        System.debug(
                            '12345: [match1] ' +
                            match.Id +
                            ' [match2] ' +
                            matchNew.Id +
                            ' [team] '
                        );
                        break;
                    }
                }
            }

            if (homeTeamInMatch) {
                matchNew.HomeBrackets_Team__c.addError(TEAM_JUST_SELECTED);
            } else if (visitorTeamInMatch) {
                matchNew.VisitorBrackets_Team__c.addError(TEAM_JUST_SELECTED);
            }
        }
    }

    /**
     * Given the winners of the matches, each one is set to the following match if exists one.
     * @param matches List of new matches
     */
    public static void updateFollowingMatches(List<Brackets_Match__c> matches) {
        BracketsTriggerUtilities.newTriggerInstance(matches);
        List<Brackets_Match__c> followingMatches = new List<Brackets_Match__c>();

        for (Brackets_Match__c match : matches) {
            if (
                match.FollowingBrackets_Match__c != null &&
                match.WinnerBrackets_Team__c != null
            ) {
                followingMatches.add(
                    BracketsTriggerUtilities.triggerMatchMap.get(
                        match.FollowingBrackets_Match__c
                    )
                );
            }
        }

        for (
            Brackets_Match__c match : BracketsTriggerUtilities.triggerListObject.values()
        ) {
            for (Brackets_Match__c followingMatch : followingMatches) {
                if (
                    match.FollowingBrackets_Match__c == followingMatch.Id &&
                    followingMatch.WinnerBrackets_Team__c == null
                ) {
                    if (match.FollowingIsHome__c) {
                        followingMatch.HomeBrackets_Team__c = match.WinnerBrackets_Team__c;
                    } else {
                        followingMatch.VisitorBrackets_Team__c = match.WinnerBrackets_Team__c;
                    }
                    break;
                } else {
                    BracketsTriggerUtilities.triggerListObject.get(match.Id)
                        .WinnerBrackets_Team__c.addError(
                            'You must remove the Teams from the next match first.'
                        );
                    return;
                }
            }
        }

        try {
            if (!followingMatches.isEmpty()) {
                BracketsMatchUtilities.SKIP_TRIGGER = true;
                update followingMatches;
                BracketsMatchUtilities.SKIP_TRIGGER = false;
            }
        } catch (Exception e) {
            BracketsTriggerUtilities.triggerListObject.values()
                .get(0)
                .WinnerBrackets_Team__c.addError(e.getMessage());
        }
    }

    /**
     * Check if the Match is following of an other, if it is, the teams can not be changed or seted.
     * @param matchListNew
     * @param matchListOld
     */
    public static void checkSetTeam(
        List<Brackets_Match__c> matchListNew,
        List<Brackets_Match__c> matchListOld
    ) {
        Brackets_Match__c matchNew;
        Brackets_Match__c matchOld;

        for (Integer x = 0; x < matchListOld.size(); x++) {
            matchNew = matchListNew.get(x);
            matchOld = matchListOld.get(x);

            if (
                (matchOld.HomeBrackets_Team__c !=
                matchNew.HomeBrackets_Team__c) ||
                (matchOld.VisitorBrackets_Team__c !=
                matchNew.VisitorBrackets_Team__c)
            ) {
                for (
                    Brackets_Match__c m : BracketsTriggerUtilities.triggerMatchList
                ) {
                    if (m.FollowingBrackets_Match__c == matchOld.Id) {
                        Brackets_Round__c cRound = BracketsTriggerUtilities.triggerRoundMap.get(
                            m.Brackets_Round__c
                        );
                        Brackets_Tournament__c cTour = BracketsTriggerUtilities.triggerTournamentMap.get(
                            cRound.Brackets_Tournament__c
                        );
                        //System.assert(false,cRound.RoundNumber__c);
                        if (
                            cTour.Type__c !=
                            BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE ||
                            cRound.RoundNumber__c != 1
                        ) {
                            matchNew.addError('Teams can not be changed');
                            return;
                        } else {
                            if (cRound.RoundNumber__c == 1) {
                                if (
                                    (m.Position__c == 1 ||
                                    m.Position__c == 3) &&
                                    (matchOld.HomeBrackets_Team__c !=
                                    matchNew.HomeBrackets_Team__c)
                                ) {
                                    matchNew.addError(
                                        'Teams can not be changed'
                                    );
                                    return;
                                } else if (
                                    (m.Position__c == 2 ||
                                    m.Position__c == 4) &&
                                    (matchOld.VisitorBrackets_Team__c !=
                                    matchNew.VisitorBrackets_Team__c)
                                ) {
                                    matchNew.addError(
                                        'Teams can not be changed'
                                    );
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * When Winner team is removed from some match, we need check if the following match Winner team is also set
     * so we block the update, else we need remove the team from following match
     * @param matchListNew
     * @param matchListOld
     */
    public static void checkRemovedTeam(
        List<Brackets_Match__c> matchListNew,
        List<Brackets_Match__c> matchListOld
    ) {
        BracketsTriggerUtilities.newTriggerInstance(matchListNew);
        List<Brackets_Match__c> newList = BracketsTriggerUtilities.triggerListObject.values();
        List<Brackets_Match__c> mList = new List<Brackets_Match__c>();
        Brackets_Match__c matchNew;
        Brackets_Match__c matchOld;

        for (Integer x = 0; x < matchListNew.size(); x++) {
            matchNew = matchListNew.get(x);
            matchOld = matchListOld.get(x);
            if (
                !matchNew.isLocked__c &&
                matchNew.WinnerBrackets_Team__c == null &&
                (matchNew.WinnerBrackets_Team__c !=
                matchOld.WinnerBrackets_Team__c)
            ) {
                //First of all, check if the follower match have WinnerTeam
                Brackets_Match__c fMatch = BracketsTriggerUtilities.triggerMatchMap.get(
                    matchOld.FollowingBrackets_Match__c
                );

                if (fMatch != null && fMatch.WinnerBrackets_Team__c != null) {
                    matchNew.WinnerBrackets_Team__c.addError(
                        'Team can\'t be removed because the next match have a Winner Team'
                    );
                } else if (fMatch != null) {
                    if (
                        fMatch.HomeBrackets_Team__c ==
                        matchOld.WinnerBrackets_Team__c
                    ) {
                        fMatch.HomeBrackets_Team__c = null;
                    } else {
                        fMatch.VisitorBrackets_Team__c = null;
                    }
                    fMatch.VisitorScore__c = 0;
                    fMatch.HomeScore__c = 0;
                    mList.add(fMatch);
                }
            }
        }
        if (!mList.isEmpty()) {
            BracketsMatchUtilities.SKIP_TRIGGER = true;
            update mList;
            BracketsMatchUtilities.SKIP_TRIGGER = false;
        }
    }

    /**
     *	If the Winner team is set, the previous match is locked in order to avoid tournament inconsistences.
     *	@param mListNew
     *	@param oListNew
     */
    public static void setWinnerTeam(
        List<Brackets_Match__c> mListNew,
        List<Brackets_Match__c> mListOld
    ) {
        List<Brackets_Match__c> lockedMatchList = new List<Brackets_Match__c>();
        for (Integer x = 0; x < mListNew.size(); x++) {
            if (mListNew.get(x).WinnerBrackets_Team__c != null) {
                for (
                    Brackets_Match__c match : BracketsTriggerUtilities.triggerMatchList
                ) {
                    if (
                        match.FollowingBrackets_Match__c == mListNew.get(x).Id
                    ) {
                        if (match != null) {
                            match.isLocked__c = true;
                            lockedMatchList.add(match);
                        }
                    }
                }
            }
        }
        BracketsMatchUtilities.SKIP_TRIGGER = true;
        if (!lockedMatchList.isEmpty()) {
            Database.update(lockedMatchList);
        }
        BracketsMatchUtilities.SKIP_TRIGGER = false;
    }

    public static void checkLocked(
        List<Brackets_Match__c> mListOld,
        List<Brackets_Match__c> mListNew
    ) {
        for (Integer x = 0; x < mListNew.size(); x++) {
            if (mListOld.get(x).isLocked__c) {
                mListNew.get(x).addError('This Match can not be updated');
            }
        }
    }

    /**
     *	Given a team id, returns true if it is in the match, otherwise false.
     *
     *	@param teamId
     *	@param match
     *	@return  if exists the team in the match
     */
    private static Boolean existsTeamInMatch(
        Id teamId,
        Brackets_Match__c match
    ) {
        return teamId != null &&
            (teamId == match.HomeBrackets_Team__c ||
            teamId == match.VisitorBrackets_Team__c);
    }

    /**
     * Method used to insert External Ids on Match objects
     * @param matchList
     */
    //TODO do we need this?
    /*
	public static void addExternalId( List<Brackets_Match__c> matchList ){
		
		for( Brackets_Match__c match : matchList ){
			if( match.ExternalId__c == null ){
				match.ExternalId__c = BracketsTournamentUtilities.generateRandomExternalId();
			}
		}
	}
	*/

    /**
     *	Given one list of mathces, check if there changes in them to update the tournament.
     *
     *	@param newMatchList	a list of match sobjects
     */
    public static void publishOff(List<Brackets_Match__c> newMatchList) {
        BracketsMatchUtilities.getTriggerInstance(newMatchList);
        BracketsTournamentUtilities.publishTournamentOff(
            BracketsTriggerUtilities.triggerTournamentList
        );
    }

    /**
     *	Check the teams for the matches of first level if they are filled.
     *
     * 	@param tournament
     */
    public static void checkFirstLevelCompleted(
        Brackets_Tournament__c tournament,
        Map<Id, Brackets_Match__c> matches
    ) {
        Brackets_Match__c match;
        Id matchFollowingId;
        List<Brackets_Match__c> matchesFirstRound = new List<Brackets_Match__c>();
        Set<Id> allMatchesId = new Set<Id>();
        // in this set are the id with more than one reference of the match in the following match field.
        Set<Id> matchesIdWithFollowging = new Set<Id>();
        // in this set are the id with no references of this match in the following match field.
        Set<Id> matchesIdWithOutFollowing = new Set<Id>();
        // in this set are the id with any reference of the match in the following match field.
        Set<Id> matchesIdPotencial = new Set<Id>();

        // obtain whole the matches id from a tournament
        allMatchesId.addAll(matches.keySet());
        matchesIdWithOutFollowing = allMatchesId;

        // obtain the matches id which are set as following match
        for (Id matchId : matches.keySet()) {
            match = matches.get(matchId);
            matchFollowingId = match.FollowingBrackets_Match__c;
            if (matchId != null) {
                if (matchesIdPotencial.contains(matchFollowingId)) {
                    matchesIdWithFollowging.add(matchFollowingId);
                } else {
                    // in this case add the id because there's more than one reference of the match.
                    matchesIdPotencial.add(matchFollowingId);
                }
            }
        }

        // obtain the matches id which are not following of any match
        matchesIdWithOutFollowing.removeAll(matchesIdWithFollowging);
        // obtain the matches id which are referenced one time in the followingMatch field.
        matchesIdPotencial.removeAll(matchesIdWithFollowging);
        for (Id matchId : matchesIdWithOutFollowing) {
            match = matches.get(matchId);
            matchesFirstRound.add(match);
        }

        checkCompletedMatches(matchesFirstRound, matchesIdPotencial);
    }

    public static Map<String, Brackets_Match__c> getMatchesMap(
        List<String> matchesId
    ) {
        return new Map<String, Brackets_Match__c>(
            [
                SELECT
                    Id,
                    ExternalId__c,
                    HomeBrackets_Team__c,
                    VisitorBrackets_Team__c
                FROM Brackets_Match__c
                WHERE id IN :matchesId
            ]
        );
    }

    /**
     *	Check if a list of matches have their teams set.
     *
     *	@param matches			a list of matches
     *	@param matchesIdSet		a set of matches id to check both teams or not
     */
    private static void checkCompletedMatches(
        List<Brackets_Match__c> matches,
        Set<Id> matchesIdSet
    ) {
        Boolean checkCompletedMatch = true;
        for (Brackets_Match__c match : matches) {
            checkCompletedMatch =
                (matchesIdSet.contains(match.Id) &&
                (match.HomeBrackets_Team__c != null ||
                match.VisitorBrackets_Team__c != null)) ||
                (match.HomeBrackets_Team__c != null &&
                match.VisitorBrackets_Team__c != null);
            if (!checkCompletedMatch) {
                break;
            }
        }
        if (!checkCompletedMatch) {
            throw new CustomException(
                BracketsMatchUtilities.FIRST_ROUND_NOT_COMPLETED
            );
        }
    }

    public class CustomException extends Exception {
    }
}
