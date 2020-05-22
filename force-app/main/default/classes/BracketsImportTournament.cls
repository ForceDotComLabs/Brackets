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

public with sharing class BracketsImportTournament {
    private String source;
    public Brackets_Tournament__c tournament { get; set; }
    private List<Brackets_Round__c> roundList { get; set; }
    private List<Brackets_Match__c> matchList { get; set; }
    //ExternalId - ID
    private Map<String, String> teamList { get; set; }
    //ExternalId - ID
    private Map<String, String> roundSync { get; set; }
    private Map<String, String> matchSync { get; set; }
    private Map<String, String> matchFollowingMatchId { get; set; }
    private Map<String, Brackets_Match__c> matchFollowingMatchSObject {
        get;
        set;
    }

    /**
     * Constructor
     */
    public BracketsImportTournament(String source) {
        this.source = source;
        this.roundList = new List<Brackets_Round__c>();
        this.matchList = new List<Brackets_Match__c>();
        this.teamList = new Map<String, String>();
        this.roundSync = new Map<String, String>();
        this.matchSync = new Map<String, String>();
        this.matchFollowingMatchId = new Map<String, String>();
        this.matchFollowingMatchSObject = new Map<String, Brackets_Match__c>();
    }

    /**
     * Method in charge of retrieving and compiling the data from imported file,
     * for then inserting into the system.
     * @param document
     */
    public void processImportedDocument(String xml) {
        Brackets_Match__c followingMatch;
        String followingMatchExternalId;
        BracketsTournamentUtilities.CreatingTournamentTree = true;
        Savepoint sp = Database.setSavepoint();

        //Initialize the schedule job
        //TODO FUTURE - Do we need this?
        //BracketsScheduleJob.createSingleInstance();

        this.validate(xml);
        try {
            try {
                BracketsImportTeams impTeams = new BracketsImportTeams();
                impTeams.processImportedDocument(xml);
                //creates internal map for use when importing Matches and refered teams
                List<Brackets_Team__c> teams = [
                    SELECT t.Name, t.Id, t.ShortName__c, t.ExternalId__c
                    FROM Brackets_Team__c t
                    LIMIT 1000
                ];
                for (Brackets_Team__c team : teams) {
                    this.teamList.put(team.ExternalId__c, team.Id);
                }
            } catch (Exception ex) {
                throw new BracketsException(
                    'Error Importing: Please check your Team Data',
                    ex
                );
            }
            try {
                this.readingTournamentData(xml);
                upsert this.tournament ExternalId__c;

                //Map the Tournament Object again
                this.tournament = [
                    SELECT
                        t.isChild__c,
                        t.Version__c,
                        t.Update_Source__c,
                        t.Type__c,
                        t.TeamCount__c,
                        t.Start__c,
                        t.Name,
                        t.MaxRoundNumber__c,
                        t.Id,
                        t.ExternalId__c,
                        t.End__c,
                        t.Description__c,
                        t.CronTrigger__c,
                        t.Allow_Update__c,
                        t.Deadline__c
                    FROM Brackets_Tournament__c t
                    WHERE t.Id = :this.tournament.Id
                ];

                this.tournament.isChild__c = true;
                this.tournament.Allow_Update__c = false;
                upsert this.tournament ExternalId__c;
            } catch (Exception ex) {
                throw new BracketsException(
                    'Error Importing: Please check your Tournament Data [BracketsImportTournament] ',
                    ex
                );
            }
            try {
                this.readingRoundsData(xml);
                upsert this.roundList ExternalId__c;
                for (Brackets_Round__c r : this.roundList) {
                    this.roundSync.put(r.ExternalId__c, r.Id);
                }
            } catch (Exception ex) {
                throw new BracketsException(
                    'Error Importing: Please check your Round Data',
                    ex
                );
            }

            try {
                for (Brackets_Match__c m : this.matchList) {
                    String roundExtId = this.matchSync.get(m.ExternalId__c);
                    m.Brackets_Round__c = this.roundSync.get(roundExtId);
                }
                upsert this.matchList ExternalId__c;

                for (Brackets_Match__c m : this.matchList) {
                    followingMatchExternalId = this.matchFollowingMatchId.get(
                        m.ExternalId__c
                    );
                    if (followingMatchExternalId != null) {
                        followingMatch = this.matchFollowingMatchSObject.get(
                            followingMatchExternalId
                        );
                        if (followingMatch != null) {
                            m.FollowingBrackets_Match__c = followingMatch.Id;
                        }
                    }
                }
                upsert this.matchList;

                // Update predictdions points
                BracketsMatchesPredictionUtil.updateUserMatchPredictionPoints(
                    this.matchList
                );
            } catch (Exception ex) {
                throw new BracketsException(
                    'Error Importing: Please check you Mathes Data ' +
                    ex.getMessage(),
                    ex
                );
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new BracketsException(
                BracketsImportExportUtilities.FAIL_TOURNAMENT_IMPORT,
                e
            );
        }
    }

    /**
     * Method in charge of retrieving and compiling the Tournament data from imported file,
     * for then inserting into the system.
     * @param xml
     */
    public void readingTournamentData(String xml) {
        Xmlstreamreader reader = new Xmlstreamreader(xml);

        while (reader.hasNext()) {
            if (
                reader.getEventType() == XmlTag.START_ELEMENT &&
                reader.getLocalName() == 'Tournament'
            ) {
                this.parseTournamentData(reader);
            }
            if (
                reader.getEventType() == XmlTag.END_ELEMENT &&
                reader.getLocalName() == 'Tournament'
            ) {
                break;
            }
            reader.next();
        }
    }

    /**
     * Method in charge of retrieving and compiling the Rounds Data data from imported file,
     * for then inserting into the system.
     * @param xml
     */
    private void readingRoundsData(String xml) {
        Xmlstreamreader reader = new Xmlstreamreader(xml);

        while (reader.hasNext()) {
            if (
                reader.getEventType() == XmlTag.START_ELEMENT &&
                reader.getLocalName() == 'Round'
            ) {
                this.parseRoundData(reader);
            }
            if (
                reader.getEventType() == XmlTag.END_ELEMENT &&
                reader.getLocalName() == 'Rounds'
            ) {
                break;
            }
            reader.next();
        }
    }

    /**
     * Method in charge of retrieving and compiling the Matches Data data from imported file,
     * for then inserting into the system.
     * @param reader
     */
    private void readingMatchesData(Xmlstreamreader reader) {
        while (reader.hasNext()) {
            if (
                reader.getEventType() == XmlTag.START_ELEMENT &&
                reader.getLocalName() == 'Match'
            ) {
                this.parseMatchData(reader);
            }
            if (
                reader.getEventType() == XmlTag.END_ELEMENT &&
                reader.getLocalName() == 'Matches'
            ) {
                break;
            }
            reader.next();
        }
    }

    /**
     * Method in charge of parsing Tournament data from XMl document
     * @param reader
     */
    private void parseTournamentData(Xmlstreamreader reader) {
        this.tournament = new Brackets_Tournament__c();
        while (reader.hasNext()) {
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'name'
            ) {
                reader.next();
                this.tournament.Name = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'description'
            ) {
                reader.next();
                String descValue = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                this.tournament.Description__c = (descValue == 'null')
                    ? ''
                    : descValue;
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'version'
            ) {
                reader.next();
                this.tournament.Version__c = Integer.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'type'
            ) {
                reader.next();
                this.tournament.Type__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'source'
            ) {
                reader.next();
                this.tournament.Update_Source__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'deadline'
            ) {
                reader.next();
                String value = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (value == 'null') {
                    tournament.Deadline__c = null;
                } else {
                    tournament.Deadline__c = Datetime.valueOfGmt(
                        BracketsImportExportUtilities.getDecodedString(reader)
                    );
                }
            }

            //RSC this should be id?
            //if( reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'externalId' ){
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'id'
            ) {
                reader.next();
                this.tournament.ExternalId__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'teamCount'
            ) {
                reader.next();
                this.tournament.TeamCount__c = Decimal.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }

            //Validate end of tag
            if (
                reader.getEventType() == XMLTag.END_ELEMENT &&
                reader.getLocalName() == 'Tournament'
            ) {
                break;
            }

            reader.next();
        }
    }

    /**
     * Method in charge of parsing round data from XMl document
     * @param reader
     */
    private void parseRoundData(Xmlstreamreader reader) {
        Brackets_Round__c round = new Brackets_Round__c();
        round.Brackets_Tournament__c = this.tournament.Id;

        while (reader.hasNext()) {
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'name'
            ) {
                reader.next();
                round.Name = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'deadline'
            ) {
                reader.next();
                String value = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (value == 'null') {
                    round.Deadline__c = null;
                } else {
                    round.Deadline__c = Datetime.valueOfGmt(
                        BracketsImportExportUtilities.getDecodedString(reader)
                    );
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'roundNumber'
            ) {
                reader.next();
                round.RoundNumber__c = Decimal.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'scorePoints'
            ) {
                reader.next();
                round.ScorePoints__c = Decimal.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'id'
            ) {
                reader.next();
                round.ExternalId__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'Matches'
            ) {
                reader.next();
                this.readingMatchesData(reader);
            }

            //Validate end of tag
            if (
                reader.getEventType() == XMLTag.END_ELEMENT &&
                reader.getLocalName() == 'Round'
            ) {
                break;
            }

            reader.next();
        }

        this.roundList.add(round);
    }

    /**
     * Method in charge of parsing the Match data from XMl document
     * @param reader
     */
    private void parseMatchData(Xmlstreamreader reader) {
        Brackets_Match__c match = new Brackets_Match__c();
        String roundExternalId;

        while (reader.hasNext()) {
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'description'
            ) {
                reader.next();
                String descValue = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (descValue == 'null') {
                    match.Description__c = '';
                } else {
                    match.Description__c = descValue;
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'followingMatch'
            ) {
                reader.next();

                String followingMatch = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (followingMatch != 'null') {
                    this.matchFollowingMatchId.put(
                        match.ExternalId__c,
                        followingMatch
                    );
                }
                this.matchFollowingMatchSObject.put(match.ExternalId__c, match);
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'homeScore'
            ) {
                reader.next();
                match.HomeScore__c = Decimal.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'homeTeam'
            ) {
                reader.next();
                String homeValue = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (homeValue == 'null') {
                    match.HomeBrackets_Team__c = null;
                } else {
                    match.HomeBrackets_Team__c = this.teamList.get(homeValue);
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'round'
            ) {
                reader.next();
                roundExternalId = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'schedule'
            ) {
                reader.next();
                String schedule = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (schedule == 'null') {
                    match.Schedule__c = null;
                } else {
                    match.Schedule__c = Datetime.valueOfGmt(schedule);
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'visitorScore'
            ) {
                reader.next();
                match.VisitorScore__c = Decimal.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'vistitorTeam'
            ) {
                reader.next();
                String vistitorTeam = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (vistitorTeam == 'null') {
                    match.VisitorBrackets_Team__c = null;
                } else {
                    match.VisitorBrackets_Team__c = this.teamList.get(
                        vistitorTeam
                    );
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'winnerTeam'
            ) {
                reader.next();
                String winnerTeam = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (winnerTeam == 'null') {
                    match.WinnerBrackets_Team__c = null;
                } else {
                    match.WinnerBrackets_Team__c = this.teamList.get(
                        winnerTeam
                    );
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'id'
            ) {
                reader.next();
                match.ExternalId__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'conference'
            ) {
                reader.next();
                match.Conference__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                match.Conference__c = match.Conference__c.equalsIgnoreCase(
                        'null'
                    )
                    ? null
                    : match.Conference__c;
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'position'
            ) {
                reader.next();
                match.Position__c = Decimal.valueOf(
                    BracketsImportExportUtilities.getDecodedString(reader)
                );
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'followingIsHome'
            ) {
                reader.next();
                match.FollowingIsHome__c = BracketsImportExportUtilities.getDecodedString(
                        reader
                    ) == 'true'
                    ? true
                    : false;
            }

            //Validate end of tag
            if (
                reader.getEventType() == XMLTag.END_ELEMENT &&
                reader.getLocalName() == 'Match'
            ) {
                break;
            }

            reader.next();
        }

        this.matchSync.put(match.ExternalId__c, roundExternalId);
        this.matchList.add(match);
    }

    /**
     *	check if the xml is valid, other wise an exception is thrown.
     *
     *	@param xml	the source to be parsed.
     */
    private void validate(String xml) {
        Xmltag tag;
        Xmlstreamreader reader = new Xmlstreamreader(xml);
        //try{
        tag = reader.getEventType();
        if (tag == XmlTag.START_DOCUMENT) {
            if (reader.hasNext()) {
                reader.next();
                tag = reader.getEventType();
                if (
                    reader.getLocalName() ==
                    BracketsImportExportUtilities.ERROR_TAG
                ) {
                    reader.next();
                    throw new BracketsException(
                        BracketsImportExportUtilities.getDecodedString(reader)
                    );
                }
            }
        }
        // }catch(XmlException ex){
        //    throw new BracketsException(BracketsImportExportUtilities.PARENT_TOURNAMENT_SITE_ERRORS+this.source +ex.getMessage(), ex);
        //}
    }
}
