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

public with sharing class BracketsTreeViewStandard {
    //-------------------------------------------------------------------------
    // Constants & Variables
    //-------------------------------------------------------------------------

    public static final String FINAL_FLAG = 'CHAMPIONSHIP';

    private BracketsTreeView parent = null;
    private Integer currentInitHeight = 0;
    private Integer currentBlockHeight = 0;

    //-------------------------------------------------------------------------
    // Getters and Setters
    //-------------------------------------------------------------------------

    public List<BracketsTreeView.RoundData> orderedRounds { get; set; }

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
    public BracketsTreeViewStandard(BracketsTreeView parentTree) {
        this.parent = parentTree;
        this.orderedRounds = populateRoundData();
    }

    //-------------------------------------------------------------------------
    // Private methods
    //-------------------------------------------------------------------------

    /**
     * Populate round datatypes
     */
    private List<BracketsTreeView.RoundData> populateRoundData() {
        Brackets_Round__c currentRound = null;
        List<Brackets_Match__c> currentRoundMatches = new List<Brackets_Match__c>();
        List<Brackets_Match__c> nextRoundMatches = new List<Brackets_Match__c>();

        List<BracketsTreeView.RoundData> result = new List<BracketsTreeView.RoundData>();
        BracketsTreeView.RoundData rdt = null;
        Integer roundTotal = this.parent.roundsByNumber.size() - 1;

        this.currentInitHeight = 0;
        this.currentBlockHeight = 0;

        for (Integer i = 0; i < this.parent.roundsByNumber.size(); i++) {
            currentRound = this.parent.roundsByNumber[i];

            rdt = new BracketsTreeView.RoundData();
            rdt.round = currentRound;
            rdt.className = 'round';

            // Block round
            //RSC Legacy
            /*
			if( this.parent.isGroupByRound() ){
				if( currentRound.Deadline__c == null || (currentRound.Deadline__c <= Date.today()) ){
					rdt.className += ' round-disabled';
				}
			}
			*/

            // First round
            if (i == 0) {
                currentRoundMatches = this.parent.filterMatchesByRound(
                    currentRound.Id,
                    this.parent.matchesByPosition
                );
                nextRoundMatches = this.parent.getNextMatches(
                    currentRoundMatches
                );
            } else if (i == roundTotal) {
                // Final
                currentRoundMatches = nextRoundMatches;
            } else {
                // Inner round
                currentRoundMatches = nextRoundMatches;
                nextRoundMatches = this.parent.getNextMatches(
                    currentRoundMatches
                );
            }

            this.currentBlockHeight = 40 * Math.pow(2, i).intValue();

            rdt.matches = populateMatchData(
                currentRound,
                i,
                currentRoundMatches,
                (i == roundTotal ? true : false)
            );
            result.add(rdt);
        }

        return result;
    }

    /**
     * Populate match datatypes
     */
    private List<BracketsTreeView.MatchData> populateMatchData(
        Brackets_Round__c round,
        Integer roundNumber,
        List<Brackets_Match__c> source,
        Boolean isFinal
    ) {
        List<BracketsTreeView.MatchData> result = new List<BracketsTreeView.MatchData>();

        for (Integer i = 0; i < source.size(); i++) {
            result.add(
                populateMatchData(round, roundNumber, source[i], i, isFinal)
            );
        }

        return result;
    }

    /**
     * Populate match datatype
     */
    private BracketsTreeView.MatchData populateMatchData(
        Brackets_Round__c round,
        Integer roundNumber,
        Brackets_Match__c match,
        Integer matchNumber,
        Boolean isFinal
    ) {
        BracketsTreeView.MatchData md = new BracketsTreeView.MatchData();

        md.isFinal = isFinal;
        md.className = 'match';
        md.spacerHeight = roundNumber == 0
            ? this.currentBlockHeight
            : (matchNumber == 0
                    ? this.currentInitHeight
                    : this.currentBlockHeight);
        md.blockHeight = this.currentBlockHeight - 2;

        if (matchNumber == 0) {
            this.currentInitHeight = this.currentBlockHeight / 2;
        }

        if (match != null) {
            md.match = match;
            md.home = populateTeamData(
                round,
                roundNumber,
                match,
                this.parent.teamMap.get(match.HomeBrackets_Team__c),
                true
            );
            md.visitor = populateTeamData(
                round,
                roundNumber,
                match,
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

        // Champion
        if (isFinal) {
            md.champion = populateChampion(
                match,
                this.parent.teamMap.get(match.WinnerBrackets_Team__c)
            );
        }

        return md;
    }

    /**
     * Populate team datatype
     */
    private BracketsTreeView.TeamData populateTeamData(
        Brackets_Round__c round,
        Integer roundNumber,
        Brackets_Match__c match,
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

        // Not first round
        if (roundNumber != 0) {
            td.className += ' inner';
        }

        // Match locked/unlocked
        if (!this.parent.lockMatch(match, round)) {
            locked = false;
            td.className += ' unlocked';
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
            td.className += ' team-empty droppable';
        }

        td.className += !locked ? ' draggable' : '';

        return td;
    }

    /**
     * Populate final
     */
    private BracketsTreeView.TeamData populateChampion(
        Brackets_Match__c match,
        Brackets_Team__c champion
    ) {
        BracketsTreeView.TeamData td = new BracketsTreeView.TeamData();
        Brackets_Team__c predTeam = null;

        td.className = 'team champion';

        // Prediction
        if (this.parent.predictionMapByMatch.get(match.Id) != null) {
            td.predId = this.parent.predictionMapByMatch.get(match.Id).Id;
            predTeam = this.parent.teamMap.get(
                this.parent.predictionMapByMatch.get(match.Id)
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
            td.className += ' champion-empty droppable';
        }

        return td;
    }
}
