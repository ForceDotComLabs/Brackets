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
public with sharing class BracketsTreeViewFootball {
    //-------------------------------------------------------------------------
    // Constants & Variables
    //-------------------------------------------------------------------------

    public static final String CHAMPIONSHIP_FLAG = 'NFL_SUPERBOWL';

    private BracketsTreeView parent = null; /* Prototypal inheritance */
    private Integer currentInitHeight = 0;
    private Integer currentBlockHeight = 0;

    private Map<String, String> nextMatchPredictionMap = new Map<String, String>();

    //-------------------------------------------------------------------------
    // Getters and Setters
    //-------------------------------------------------------------------------

    public List<BracketsTreeView.RoundData> orderedAFCRounds { get; set; }
    public List<BracketsTreeView.RoundData> orderedNFCRounds { get; set; }
    public BracketsTreeView.MatchData biggame { get; set; }

    public String getTournamentId() {
        return this.parent.tournamentId;
    }
    public String getGroupId() {
        return this.parent.groupId;
    }
    public Brackets_Tournament__c getTournament() {
        return this.parent.tournament;
    }
    public Brackets_UserTournament__c getUserTournament() {
        return this.parent.userTournament;
    }
    public String getTournamentClass() {
        return this.parent.tournamentClass;
    }

    public List<Brackets_Match__c> getMatches() {
        return this.parent.matchesByPosition;
    }

    //-------------------------------------------------------------------------
    // Constructors
    //-------------------------------------------------------------------------

    /**
     * Create a new controller instance
     */
    public BracketsTreeViewFootball(BracketsTreeView parentTree) {
        this.parent = parentTree;
        this.orderedAFCRounds = populateRoundData(
            BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
        );
        this.orderedNFCRounds = populateRoundData(
            BracketsTournamentUtilities.NFL_CONFERENCE_NATIONAL
        );
        this.biggame = populatebiggame();
    }

    //-------------------------------------------------------------------------
    // Private methods
    //-------------------------------------------------------------------------

    /**
     * Populate round datatypes
     *
     * @param conference NFL conference (or division)
     * @result           List of round data
     */
    private List<BracketsTreeView.RoundData> populateRoundData(
        String conference
    ) {
        List<Brackets_Match__c> conferenceMatches = this.parent.filterMatchesByConference(
            conference
        );
        Brackets_Round__c currentRound = null;
        List<Brackets_Match__c> currentRoundMatches = new List<Brackets_Match__c>();
        List<Brackets_Match__c> nextRoundMatches = new List<Brackets_Match__c>();

        List<BracketsTreeView.RoundData> result = new List<BracketsTreeView.RoundData>();
        BracketsTreeView.RoundData rdt = null;

        this.currentInitHeight = 0;
        this.currentBlockHeight = 0;

        for (Integer i = 0; i < 3; i++) {
            currentRound = this.parent.roundsByNumber[i];

            rdt = new BracketsTreeView.RoundData();
            rdt.round = currentRound;
            rdt.className = 'round';

            if (this.parent.isGroupByRound()) {
                if (
                    currentRound.Deadline__c == null ||
                    (currentRound.Deadline__c <= Date.today())
                ) {
                    rdt.className += ' round-disabled';
                }
            }

            // First round
            if (i == 0) {
                currentRoundMatches = this.parent.filterMatchesByRound(
                    currentRound.Id,
                    conferenceMatches
                );
                nextRoundMatches = this.parent.getNextMatches(
                    currentRoundMatches
                );
            } else {
                // Inner round
                currentRoundMatches = nextRoundMatches;
                nextRoundMatches = this.parent.getNextMatches(
                    currentRoundMatches
                );
            }

            this.currentBlockHeight = 40 * Math.pow(2, i).intValue();
            this.currentInitHeight =
                this.currentInitHeight + this.currentBlockHeight / 2;

            rdt.matches = populateMatchData(
                conference,
                currentRound,
                i,
                currentRoundMatches
            );
            result.add(rdt);
        }

        if (conference == BracketsTournamentUtilities.NFL_CONFERENCE_NATIONAL) {
            List<BracketsTreeView.RoundData> reverseResult = new List<BracketsTreeView.RoundData>();

            // Reverse List
            for (Integer j = (result.size() - 1); j >= 0; j--) {
                reverseResult.add(result[j]);
            }

            result = reverseResult;
        }

        return result;
    }

    /**
     * Populate match datatypes
     *
     * @param conference  NFL conference or division
     * @param round       Round where the match is being played
     * @param roundNumber Order number of the round
     * @param source      List of source matches
     * @return            List of match data
     */
    private List<BracketsTreeView.MatchData> populateMatchData(
        String conference,
        Brackets_Round__c round,
        Integer roundNumber,
        List<Brackets_Match__c> source
    ) {
        List<BracketsTreeView.MatchData> result = new List<BracketsTreeView.MatchData>();
        Integer matchCount = roundNumber == 0 ? 4 : (roundNumber == 1 ? 2 : 1);
        Integer matchIndex = -1;

        for (Integer i = 0; i < matchCount; i++) {
            if (roundNumber == 0) {
                if (i == 0) {
                    matchIndex = 0;
                } else {
                    if (i == 3) {
                        matchIndex = 1;
                    } else {
                        matchIndex = -1;
                    }
                }
            } else {
                matchIndex = i;
            }
            //matchIndex = roundNumber == 0 ? ( i == 0 ? 0 : ( i == 3 ? 1 : -1) ) : i;
            result.add(
                populateMatchData(
                    conference,
                    round,
                    roundNumber,
                    (matchIndex == -1 ? null : source[matchIndex]),
                    i
                )
            );
        }

        return result;
    }

    /**
     * Populate match datatype
     *
     * @param conference  NFL conference or division
     * @param round       Round where the match is being played
     * @param roundNumber Order number of current round
     * @param match       Source match
     * @param matchNumber Order number of current match
     * @return            Match data
     */
    private BracketsTreeView.MatchData populateMatchData(
        String conference,
        Brackets_Round__c round,
        Integer roundNumber,
        Brackets_Match__c match,
        Integer matchNumber
    ) {
        BracketsTreeView.MatchData md = new BracketsTreeView.MatchData();

        md.spacerHeight = roundNumber == 0
            ? this.currentBlockHeight
            : (matchNumber == 0
                    ? this.currentInitHeight
                    : this.currentBlockHeight);
        md.blockHeight = this.currentBlockHeight - 2;

        // Empty match
        if (roundNumber == 0 && (matchNumber == 1 || matchNumber == 2)) {
            //updated from 'match hidden' 12/22
            md.className = 'spacer';
        } else {
            // Match
            md.className = 'match';

            if (match != null) {
                md.match = match;
                md.home = populateTeamData(
                    conference,
                    round,
                    roundNumber,
                    match,
                    matchNumber,
                    this.parent.teamMap.get(match.HomeBrackets_Team__c),
                    true
                );
                md.visitor = populateTeamData(
                    conference,
                    round,
                    roundNumber,
                    match,
                    matchNumber,
                    this.parent.teamMap.get(match.VisitorBrackets_Team__c),
                    false
                );

                if (match.WinnerBrackets_Team__c != null) {
                    md.winner.team = this.parent.teamMap.get(
                        match.WinnerBrackets_Team__c
                    );
                }

                if (this.parent.predictionMapByMatch.get(match.Id) != null) {
                    md.prediction.team = this.parent.teamMap.get(
                        this.parent.predictionMapByMatch.get(match.Id)
                            .PredictedWinnerBrackets_Team__c
                    );
                }
            }

            // Draw spacer?
            if (roundNumber == 0 && matchNumber == 0) {
                md.spacer = false;
            }
        }

        // Conference final
        if (roundNumber == 2) {
            md.isFinal = true;
        }

        return md;
    }

    /**
     * Populate team datatype
     *
     * @param conference  NFL conference or division
     * @param round       Current round
     * @param roundNumber Order number of current round
     * @param match       Current match
     * @param matchNumber Order number of current match
     * @param team        Source team
     * @param isHome      True if the source team is the home team
     * @return            Team data
     */
    private BracketsTreeView.TeamData populateTeamData(
        String conference,
        Brackets_Round__c round,
        Integer roundNumber,
        Brackets_Match__c match,
        Integer matchNumber,
        Brackets_Team__c team,
        Boolean isHome
    ) {
        BracketsTreeView.TeamData td = new BracketsTreeView.TeamData();
        Boolean locked = true;
        Brackets_Team__c predTeam = null;
        Id predId = null;
        Id predMatchId = null;

        td.className = 'team';
        td.className += isHome ? ' home' : ' visitor';

        if (conference == CHAMPIONSHIP_FLAG) {
            td.className += isHome ? ' champion-left' : ' champion-right';
        } else {
            // Tree nodes
            if (
                roundNumber == 2 ||
                (roundNumber == 1 &&
                ((matchNumber == 0 && isHome) || (matchNumber == 1 && !isHome)))
            ) {
                td.className += ' inner';
            }
        }

        // Match locked/unlocked
        if (!this.parent.lockMatch(match, round)) {
            locked = false;
            if (conference != CHAMPIONSHIP_FLAG) {
                td.className += ' unlocked ';
            }
        }

        if (!locked) {
            td.className += ' draggable ';
        }

        // Score
        td.score = isHome
            ? match.HomeScore__c.intValue()
            : match.VisitorScore__c.intValue();

        // Prediction
        if (isHome && this.parent.homePredictionMap.get(match.Id) != null) {
            predMatchId = this.parent.homePredictionMap.get(match.Id);
            predTeam = this.parent.teamMap.get(
                this.parent.predictionMapByMatch.get(predMatchId)
                    .PredictedWinnerBrackets_Team__c
            );

            td.predId = this.parent.predictionMapByMatch.get(predMatchId).Id;
        } else if (
            !isHome && this.parent.visitorPredictionMap.get(match.Id) != null
        ) {
            predMatchId = this.parent.visitorPredictionMap.get(match.Id);
            predTeam = this.parent.teamMap.get(
                this.parent.predictionMapByMatch.get(predMatchId)
                    .PredictedWinnerBrackets_Team__c
            );

            td.predId = this.parent.predictionMapByMatch.get(predMatchId).Id;
        }

        // Team
        if (team != null && predTeam != null) {
            td.team = team;
            td.predicted = predTeam;
            td.className += predTeam.Id == team.Id ? ' success' : ' failure';
        } else if (team != null && predTeam == null) {
            td.team = team;
        } else if (team == null && predTeam != null) {
            td.predicted = predTeam;
            td.className += ' prediction droppable';
        } else {
            td.className += conference != CHAMPIONSHIP_FLAG
                ? ' team-empty droppable'
                : ' champion-empty droppable';
        }

        return td;
    }

    /**
     * Populate final
     */
    private BracketsTreeView.MatchData populatebiggame() {
        Brackets_Round__c lastRound = this.parent.roundsByNumber[
                this.parent.roundsByNumber.size() - 1
            ];
        Integer lastRoundNumber = lastRound.RoundNumber__c.intValue();
        Brackets_Match__c sbmatch;
        Brackets_Team__c champion;
        BracketsTreeView.MatchData sbmdata = new BracketsTreeView.MatchData();
        BracketsTreeView.TeamData td = new BracketsTreeView.TeamData();
        Brackets_Team__c predTeam = null;

        sbmdata.className = 'match';

        // Block round
        if (this.parent.isGroupByRound()) {
            if (
                lastRound.Deadline__c == null ||
                (lastRound.Deadline__c <= Date.today())
            ) {
                sbmdata.extraInfo = 'round-disabled';
            }
        }

        // Filter matches
        for (Brackets_Match__c m : this.parent.matchMap.values()) {
            if (
                m.Brackets_Round__r.RoundNumber__c.intValue() == lastRoundNumber
            ) {
                sbmatch = m;
                break;
            }
        }

        champion = this.parent.teamMap.get(sbmatch.WinnerBrackets_Team__c);

        // Populate Home/Visitor
        sbmdata.match = sbmatch;
        sbmdata.home = populateTeamData(
            CHAMPIONSHIP_FLAG,
            lastRound,
            lastRoundNumber,
            sbmatch,
            0,
            this.parent.teamMap.get(sbmatch.HomeBrackets_Team__c),
            true
        );
        sbmdata.visitor = populateTeamData(
            CHAMPIONSHIP_FLAG,
            lastRound,
            lastRoundNumber,
            sbmatch,
            0,
            this.parent.teamMap.get(sbmatch.VisitorBrackets_Team__c),
            false
        );

        if (sbmatch.WinnerBrackets_Team__c != null) {
            sbmdata.winner.team = this.parent.teamMap.get(
                sbmatch.WinnerBrackets_Team__c
            );
        }

        if (this.parent.predictionMapByMatch.get(sbmatch.Id) != null) {
            sbmdata.prediction.team = this.parent.teamMap.get(
                this.parent.predictionMapByMatch.get(sbmatch.Id)
                    .PredictedWinnerBrackets_Team__c
            );
        }

        // biggame champion
        td.className = 'team superchampion';

        // biggame prediction
        if (this.parent.predictionMapByMatch.get(sbmatch.Id) != null) {
            td.predId = this.parent.predictionMapByMatch.get(sbmatch.Id).Id;
            predTeam = this.parent.teamMap.get(
                this.parent.predictionMapByMatch.get(sbmatch.Id)
                    .PredictedWinnerBrackets_Team__c
            );
        }

        // Champion
        if (champion != null && predTeam != null) {
            td.team = champion;
            td.predicted = predTeam;
            td.className += predTeam.Id == champion.Id
                ? ' success'
                : ' failure';
        } else if (champion != null && predTeam == null) {
            td.team = champion;
        } else if (champion == null && predTeam != null) {
            td.predicted = predTeam;
            td.className += ' prediction droppable';
        } else {
            td.className += ' superchampion-empty droppable';
        }

        sbmdata.champion = td;

        return sbmdata;
    }
}
