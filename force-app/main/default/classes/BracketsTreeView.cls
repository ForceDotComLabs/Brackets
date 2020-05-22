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
public with sharing class BracketsTreeView {
    //-------------------------------------------------------------------------
    // DataTypes
    //-------------------------------------------------------------------------

    /**
     * Round data type, keeps information to draw the round
     */
    public class RoundData {
        public Brackets_Round__c round { get; set; }
        public List<MatchData> matches { get; set; }
        public String className { get; set; }

        public RoundData() {
            this.round = new Brackets_Round__c();
            this.matches = new List<MatchData>();
            this.className = '';
        }
    }

    /**
     * Match data type, keeps information to draw each match
     */
    public class MatchData {
        public Brackets_Match__c match { get; set; }
        public TeamData home { get; set; }
        public TeamData visitor { get; set; }
        public TeamData winner { get; set; }
        public TeamData prediction { get; set; }
        public TeamData champion { get; set; }
        public String className { get; set; }
        public Boolean spacer { get; set; }
        public Boolean isFinal { get; set; }
        public String predId { get; set; }
        public String extraInfo { get; set; }
        public Integer spacerHeight { get; set; }
        public Integer blockHeight { get; set; }
        public Boolean isLocked { get; set; }
        public Boolean isPlayed {
            get {
                if (winner.team != null) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        public MatchData() {
            this.match = new Brackets_Match__c();
            this.home = new TeamData();
            this.visitor = new TeamData();
            this.winner = new TeamData();
            this.prediction = new TeamData();
            this.champion = null;
            this.className = '';
            this.spacer = true;
            this.isFinal = false;
            this.predId = '';
            this.extraInfo = '';
            this.spacerHeight = 0;
            this.blockHeight = 0;
            this.isLocked = false;
        }
    }

    /**
     * Team data type, keeps information for each team
     */
    public class TeamData {
        public Brackets_Team__c team { get; set; }
        public Brackets_Team__c predicted { get; set; }
        public String className { get; set; }
        public String predId { get; set; }
        public Integer score { get; set; }

        public TeamData() {
            this.team = null;
            this.predicted = null;
            this.className = '';
            this.predId = '';
            this.score = 0;
        }
    }

    //-------------------------------------------------------------------------
    // Constants & Variables
    //-------------------------------------------------------------------------

    public Boolean isLocked = false;

    public Brackets_Group__c betGroup = null;

    public List<Brackets_Round__c> roundsByNumber = null;
    public List<Brackets_Match__c> matchesByPosition = null;
    public Map<Id, Brackets_Match__c> matchMap = null;
    public Map<Id, Brackets_Team__c> teamMap = null;
    public List<MatchData> matchData = new List<MatchData>();

    public Map<Id, Brackets_UserMatchPred__c> predictionMapByMatch = new Map<Id, Brackets_UserMatchPred__c>();
    public Map<Id, Id> homePredictionMap = new Map<Id, Id>();
    public Map<Id, Id> visitorPredictionMap = new Map<Id, Id>();

    //-------------------------------------------------------------------------
    // Getters and Setters
    //-------------------------------------------------------------------------

    public String tournamentId { get; set; }
    public String groupId { get; set; }
    public String userTournamentId { get; set; }
    public Brackets_Tournament__c tournament { get; set; }
    public String tournamentClass { get; set; }
    public Brackets_UserTournament__c userTournament { get; set; }

    //-------------------------------------------------------------------------
    // Constructors
    //-------------------------------------------------------------------------

    /**
     * Create a new controller instance // with a known group
     */
    public BracketsTreeView(
        String tId,
        Brackets_Group__c targetGroup,
        Boolean isLocked,
        String userTournamentId
    ) {
        this.tournamentId = tId;
        this.groupId = targetGroup.Id;
        this.betGroup = targetGroup;
        this.isLocked = isLocked;
        this.userTournamentId = userTournamentId;
        handleInit();
    }

    public void handleInit() {
        if (
            this.tournamentId == null ||
            this.groupId == null ||
            this.isLocked == null
        ) {
            throw new BracketsException(
                'initialization failed - tournament, group and locked indicator are required.'
            );
        }
        this.tournamentClass = '';
        this.initTournament();
        this.initRounds();
        this.initMatches();
        this.initTeams();
        this.initGroup();
        this.initUserTournament();
        this.initPredictions();
    }

    /**
     * List of matches filtered by conference
     *
     * @param conference NFL conference (or division)
     * @return           List of matches for the given conference
     */
    public List<Brackets_Match__c> filterMatchesByConference(
        String conference
    ) {
        List<Brackets_Match__c> result = new List<Brackets_Match__c>();

        for (Brackets_Match__c m : this.matchesByPosition) {
            if (m.Conference__c == conference) {
                result.add(this.matchMap.get(m.Id));
            }
        }

        return result;
    }

    /**
     * List of matches filtered by round
     *
     * @param roundId Round to filter the matches
     * @param source  List of matches to filter
     * @return        Filtered list of matches for the round
     */
    public List<Brackets_Match__c> filterMatchesByRound(
        Id roundId,
        List<Brackets_Match__c> source
    ) {
        List<Brackets_Match__c> mlst = new List<Brackets_Match__c>();

        // Filter matches
        for (Brackets_Match__c m : source) {
            if (m.Brackets_Round__c == (String) roundId) {
                mlst.add(this.matchMap.get(m.Id));
            }
        }

        return mlst;
    }

    /**
     * Get following matches from a list of matches
     *
     * @param currentMatches List of current matches
     * @return List of following matches
     */
    public List<Brackets_Match__c> getNextMatches(
        List<Brackets_Match__c> currentMatches
    ) {
        List<Brackets_Match__c> result = new List<Brackets_Match__c>();
        Set<Id> duplicates = new Set<Id>();

        for (Brackets_Match__c cm : currentMatches) {
            if (
                cm.FollowingBrackets_Match__c != null &&
                !duplicates.contains(cm.FollowingBrackets_Match__c)
            ) {
                duplicates.add(cm.FollowingBrackets_Match__c);
                result.add(this.matchMap.get(cm.FollowingBrackets_Match__c));
            }
        }

        return result;
    }

    /**
     * Return TRUE if the match should be locked
     *
     * @param match Match to check
     * @param round Round where the match belongs
     * @return      TRUE if the match must be locked
     */
    public Boolean lockMatch(Brackets_Match__c match, Brackets_Round__c round) {
        if (this.isLocked) {
            return true;
        }

        if (match == null || match.WinnerBrackets_Team__c != null) {
            return true;
        }

        return false;
    }

    /**
     * Return TRUE if the betting type is by round
     */
    public Boolean isGroupByRound() {
        if (
            this.betGroup != null &&
            this.betGroup.Type__c == BracketsGroupUtilities.BET_TYPE_BY_ROUND
        ) {
            return true;
        }

        return false;
    }

    //-------------------------------------------------------------------------
    // Private methods
    //-------------------------------------------------------------------------

    /**
     * Initialize tournament
     */
    private void initTournament() {
        this.tournament = [
            SELECT Id, Type__c, Deadline__c
            FROM Brackets_Tournament__c
            WHERE Id = :tournamentId
            LIMIT 1
        ];

        this.tournamentClass += 'tournament';
    }

    /**
     * Initialize rounds
     */
    private void initRounds() {
        this.roundsByNumber = [
            SELECT Id, Name, RoundNumber__c, Deadline__c
            FROM Brackets_Round__c
            WHERE Brackets_Tournament__c = :tournamentId
            ORDER BY RoundNumber__c ASC
        ];
    }

    /**
     * Initialize matches
     */
    private void initMatches() {
        // Select all tournament matches
        this.matchMap = new Map<Id, Brackets_Match__c>(
            [
                SELECT
                    Id,
                    WinnerBrackets_Team__r.Name,
                    Brackets_Round__c,
                    Conference__c,
                    HomeBrackets_Team__c,
                    VisitorBrackets_Team__c,
                    Schedule__c,
                    VisitorScore__c,
                    HomeScore__c,
                    Brackets_Round__r.RoundNumber__c,
                    Brackets_Round__r.Name,
                    Position__c,
                    FollowingBrackets_Match__c,
                    FollowingIsHome__c
                FROM Brackets_Match__c
                WHERE Brackets_Round__r.Brackets_Tournament__c = :tournamentId
            ]
        );

        for (Brackets_Match__c match : this.matchMap.values()) {
            if (match.Schedule__c != null)
                match.Schedule__c = Datetime.valueOfGmt(
                    String.valueOf(match.Schedule__c)
                );
        }

        this.matchesByPosition = [
            SELECT
                Id,
                Conference__c,
                Brackets_Round__c,
                Position__c,
                Schedule__c,
                FollowingBrackets_Match__c,
                FollowingIsHome__c
            FROM Brackets_Match__c
            WHERE Brackets_Round__r.Brackets_Tournament__c = :tournamentId
            ORDER BY Position__c
        ];
        for (Brackets_Match__c match : this.matchesByPosition) {
            if (match.Schedule__c != null)
                match.Schedule__c = Datetime.valueOfGmt(
                    String.valueOf(match.Schedule__c)
                );
        }
    }

    /**
     * Initialize teams
     */
    private void initTeams() {
        // Collect tournament teams
        Set<Id> teamIds = new Set<Id>();

        for (Id mid : this.matchMap.keySet()) {
            if (this.matchMap.get(mid).HomeBrackets_Team__c != null) {
                teamIds.add(this.matchMap.get(mid).HomeBrackets_Team__c);
            }
            if (this.matchMap.get(mid).VisitorBrackets_Team__c != null) {
                teamIds.add(this.matchMap.get(mid).VisitorBrackets_Team__c);
            }
        }

        // Select teams
        this.teamMap = new Map<Id, Brackets_Team__c>(
            [
                SELECT Id, Name, ShortName__c, Description__c
                FROM Brackets_Team__c
                WHERE Id IN :teamIds
            ]
        );
    }

    /**
     * Initialize group
     */
    private void initGroup() {
        if (this.betGroup == null) {
            this.betGroup = [
                SELECT Id, Type__c
                FROM Brackets_Group__c
                WHERE Id = :groupId
                LIMIT 1
            ];
        }

        // Check tournament deadline
        if (
            this.betGroup.Type__c ==
            BracketsGroupUtilities.BET_TYPE_FULL_TOURNAMENT &&
            this.tournament.Deadline__c <= Datetime.now()
        ) {
            tournamentClass += ' tournament-disabled';
        }
    }

    /**
     * Initialize user tournament
     */
    private void initUserTournament() {
        if (this.userTournamentId == null) {
            this.userTournament = [
                SELECT Id
                FROM Brackets_UserTournament__c
                WHERE
                    Brackets_Group__c = :this.groupId
                    AND User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
        } else {
            this.userTournament = [
                SELECT Id
                FROM Brackets_UserTournament__c
                WHERE Id = :this.userTournamentId
            ];
        }
    }

    /**
     * Init user predictions
     */
    private void initPredictions() {
        if (this.userTournament == null) {
            throw new BracketsException(
                'cannot init predicitons without a user tournament being set.'
            );
        }
        List<Brackets_UserMatchPred__c> ump = [
            SELECT Id, Brackets_Match__c, PredictedWinnerBrackets_Team__c
            FROM Brackets_UserMatchPred__c
            WHERE Brackets_UserTournament__c = :userTournament.Id
        ];

        for (Brackets_UserMatchPred__c u : ump) {
            this.predictionMapByMatch.put(u.Brackets_Match__c, u);
        }

        for (Brackets_Match__c m : this.matchMap.values()) {
            if (
                this.predictionMapByMatch.get(m.Id) != null &&
                m.FollowingBrackets_Match__c != null
            ) {
                if (m.FollowingIsHome__c) {
                    this.homePredictionMap.put(
                        m.FollowingBrackets_Match__c,
                        m.Id
                    );
                } else {
                    this.visitorPredictionMap.put(
                        m.FollowingBrackets_Match__c,
                        m.Id
                    );
                }
            }
        }
    }
}
