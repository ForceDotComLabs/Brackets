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
public with sharing class BracketsTestUtilities {
    //-------------------------------------------------------------------------
    // Private variables & constants
    //-------------------------------------------------------------------------
    private static Datetime lastMatchDate = null;

    //-------------------------------------------------------------------------
    // Public Methods
    //-------------------------------------------------------------------------

    public static String xmlTournamentValid = '<?xml version="1.0"?><export><meta><exportPackage>Tournament+Template</exportPackage><exportAuthor>mat+men</exportAuthor><exportOrganization>Force.com+Labs</exportOrganization><exportCreateDate>2010-09-08+13%3A17%3A42</exportCreateDate></meta><Teams><Team><id>a025000000DPa9sAAD</id><name>Suns</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9tAAD</id><name>Bulls</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9uAAD</id><name>Lakers</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9vAAD</id><name>Hawks</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhKvAAL</id><name>sandiego</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL0AAL</id><name>hornets</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL5AAL</id><name>shperes</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhLFAA1</id><name>bakers</name><description>null</description><rank>null</rank></Team></Teams><Tournament><id>a035000000BguqpAAB</id><name>Sample+NBa</name><description>null</description><teamCount>8</teamCount><externalId>m23oSFl3gG</externalId></Tournament><Rounds><Round><id>a015000000WyG4iAAF</id><name>round+1</name><deadline>null</deadline><roundNumber>1</roundNumber><scorePoints>3</scorePoints><status>Active</status><tournament>a035000000BguqpAAB</tournament><ExternalId>EA5iHGBGXm</ExternalId><Matches><Match><id>a005000000H2crPAAR</id><number>MA-00034</number><description>null</description><homeScore>0</homeScore><homeTeam>bakers</homeTeam><vistitorTeam>shperes</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-14+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>fnBddNQncK</externalId></Match><Match><id>a005000000H2creAAB</id><number>MA-00037</number><description>null</description><homeScore>0</homeScore><homeTeam>Lakers</homeTeam><vistitorTeam>Hawks</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-19+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>efYAkARQo6</externalId></Match><Match><id>a005000000H2crZAAR</id><number>MA-00036</number><description>null</description><homeScore>0</homeScore><homeTeam>Suns</homeTeam><vistitorTeam>Bulls</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-16+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>clIR0dUIQO</externalId></Match><Match><id>a005000000H2crUAAR</id><number>MA-00035</number><description>null</description><homeScore>0</homeScore><homeTeam>hornets</homeTeam><vistitorTeam>sandiego</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-15+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>nmrZOHQ6EZ</externalId></Match></Matches></Round></Rounds></export>';
    public static String xmlTournamentTeamInValid = '<?xml version="1.0"?><export><meta><exportPackage>Tournament+Template</exportPackage><exportAuthor>mat+men</exportAuthor><exportOrganization>Force.com+Labs</exportOrganization><exportCreateDate>2010-09-08+13%3A17%3A42</exportCreateDate></meta><Teams><Team><id>a025000000DPa9eam><iid><name>Bulls</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9uAAD</id><name>Lakers</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9vAAD</id><name>Hawks</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhKvAAL</id><name>sandiego</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL0AAL</id><name>hornets</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL5AAL</id><name>shperes</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhLFAA1</id><name>bakers</name><description>null</description><rank>null</rank></Team></Teams><Tournament><id>a035000000BguqpAAB</id><name>Sample+NBa</name><description>null</description><teamCount>8</teamCount><externalId>m23oSFl3gG</externalId></Tournament><Rounds><Round><id>a015000000WyG4iAAF</id><name>round+1</name><deadline>2010-09-17+05%3A51%3A00</deadline><roundNumber>1</roundNumber><scorePoints>3</scorePoints><status>Active</status><tournament>a035000000BguqpAAB</tournament><ExternalId>EA5iHGBGXm</ExternalId><Matches><Match><id>a005000000H2crPAAR</id><number>MA-00034</number><description>null</description><homeScore>0</homeScore><homeTeam>bakers</homeTeam><vistitorTeam>shperes</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-13+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>fnBddNQncK</externalId></Match><Match><id>a005000000H2creAAB</id><number>MA-00037</number><description>null</description><homeScore>0</homeScore><homeTeam>Lakers</homeTeam><vistitorTeam>Hawks</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-19+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>efYAkARQo6</externalId></Match><Match><id>a005000000H2crZAAR</id><number>MA-00036</number><description>null</description><homeScore>0</homeScore><homeTeam>Suns</homeTeam><vistitorTeam>Bulls</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-16+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>clIR0dUIQO</externalId></Match><Match><id>a005000000H2crUAAR</id><number>MA-00035</number><description>null</description><homeScore>0</homeScore><homeTeam>hornets</homeTeam><vistitorTeam>sandiego</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-15+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>nmrZOHQ6EZ</externalId></Match></Matches></Round></Rounds></export>';
    public static String xmlTournamentInValidMetaData = '<?xml version="1.0"?><export><meta><exportPacka>Tournament+Template</eortPackage><exportAuthor>mat+men</><exportOrganization>Force.com+Labs</exportOrganization><exportCreateDate>2010-09-08+13%3A17%3A42</exportCreateDate></meta><Teams><Team><id>a025000000DPa9sAAD</id><name>Suns</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9tAAD</id><name>Bulls</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9uAAD</id><name>Lakers</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9vAAD</id><name>Hawks</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhKvAAL</id><name>sandiego</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL0AAL</id><name>hornets</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL5AAL</id><name>shperes</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhLFAA1</id><name>bakers</name><description>null</description><rank>null</rank></Team></Teams><Tournament><id>a035000000BguqpAAB</id><name>Sample+NBa</name><description>null</description><teamCount>8</teamCount><externalId>m23oSFl3gG</externalId></Tournament><Rounds><Round><id>a015000000WyG4iAAF</id><name>round+1</name><deadline>2010-09-17+05%3A51%3A00</deadline><roundNumber>1</roundNumber><scorePoints>3</scorePoints><status>Active</status><tournament>a035000000BguqpAAB</tournament><ExternalId>EA5iHGBGXm</ExternalId><Matches><Match><id>a005000000H2crPAAR</id><number>MA-00034</number><description>null</description><homeScore>0</homeScore><homeTeam>bakers</homeTeam><vistitorTeam>shperes</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-13+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>fnBddNQncK</externalId></Match><Match><id>a005000000H2creAAB</id><number>MA-00037</number><description>null</description><homeScore>0</homeScore><homeTeam>Lakers</homeTeam><vistitorTeam>Hawks</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-19+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>efYAkARQo6</externalId></Match><Match><id>a005000000H2crZAAR</id><number>MA-00036</number><description>null</description><homeScore>0</homeScore><homeTeam>Suns</homeTeam><vistitorTeam>Bulls</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-16+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>clIR0dUIQO</externalId></Match><Match><id>a005000000H2crUAAR</id><number>MA-00035</number><description>null</description><homeScore>0</homeScore><homeTeam>hornets</homeTeam><vistitorTeam>sandiego</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-15+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>nmrZOHQ6EZ</externalId></Match></Matches></Round></Rounds></export>';
    public static String xmlTournamentRoundInValid = '<?xml version="1.0"?><export><meta><exportPackage>Tournament+Template</exportPackage><exportAuthor>mat+men</exportAuthor><exportOrganization>Force.com+Labs</exportOrganization><exportCreateDate>2010-09-08+13%3A17%3A42</exportCreateDate></meta><Teams><Team><id>a025000000DPa9sAAD</id><name>Suns</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9tAAD</id><name>Bulls</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9uAAD</id><name>Lakers</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9vAAD</id><name>Hawks</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhKvAAL</id><name>sandiego</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL0AAL</id><name>hornets</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL5AAL</id><name>shperes</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhLFAA1</id><name>bakers</name><description>null</description><rank>null</rank></Team></Teams><Tournament><id>a035000000BguqpAAB</id><name>Sample+NBa</name><description>null</description><teamCount>8</teamCount><externalId>m23oSFl3gG</externalId></Tournament><Rounds><Rouid>a015000000WyG4iAAF</id><nae><deadlin3A51%3A00</deadline><roundNumber>1</roundNumber><scorePoints>3</scorePoints><status>Active</status><tournament>a035000000BguqpAAB</tournament><ExternalId>EA5iHGBGXm</ExternalId><Matches><Match><id>a005000000H2crPAAR</id><number>MA-00034</number><description>null</description><homeScore>0</homeScore><homeTeam>bakers</homeTeam><vistitorTeam>shperes</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-13+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>fnBddNQncK</externalId></Match><Match><id>a005000000H2creAAB</id><number>MA-00037</number><description>null</description><homeScore>0</homeScore><homeTeam>Lakers</homeTeam><vistitorTeam>Hawks</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-19+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>efYAkARQo6</externalId></Match><Match><id>a005000000H2crZAAR</id><number>MA-00036</number><description>null</description><homeScore>0</homeScore><homeTeam>Suns</homeTeam><vistitorTeam>Bulls</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-16+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>clIR0dUIQO</externalId></Match><Match><id>a005000000H2crUAAR</id><number>MA-00035</number><description>null</description><homeScore>0</homeScore><homeTeam>hornets</homeTeam><vistitorTeam>sandiego</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-15+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>nmrZOHQ6EZ</externalId></Match></Matches></Round></Rounds></export>';
    public static String xmlTournamenMatchesInValid = '<?xml version="1.0"?><export><meta><exportPackage>Tournament+Template</exportPackage><exportAuthor>mat+men</exportAuthor><exportOrganization>Force.com+Labs</exportOrganization><exportCreateDate>2010-09-08+13%3A17%3A42</exportCreateDate></meta><Teams><Team><id>a025000000DPa9sAAD</id><name>Suns</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9tAAD</id><name>Bulls</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9uAAD</id><name>Lakers</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9vAAD</id><name>Hawks</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhKvAAL</id><name>sandiego</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL0AAL</id><name>hornets</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL5AAL</id><name>shperes</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhLFAA1</id><name>bakers</name><description>null</description><rank>null</rank></Team></Teams><Tournament><id>a035000000BguqpAAB</id><name>Sample+NBa</name><description>null</description><teamCount>8</teamCount><externalId>m23oSFl3gG</externalId></Tournament><Rounds><Round><id>a015000000WyG4iAAF</id><name>round+1</name><deadline>2010-09-17+05%3A51%3A00</deadline><roundNumber>1</roundNumber><scorePoints>3</scorePoints><status>Active</status><tournament>a035000000BguqpAAB</tournament><ExternalId>EA5iHGBGXm</ExternalId><Match0000H2crPAAR</id><number>MA-00034</number><description>null</descriptioore><homeTeam>bakers</eam>shperes</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-13+05%3A52%3A00</schedule><visitorSK</externalId></Mattch><id>a005000000H2cmber>MA-00037</numbeption>null</description><homeScore>0</homeScore><homeTeam>Lakers</homeTeam><vistitorTeam>Hawks</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-19+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>efYAkARQo6</externalId></Match><Match><id>a005000000H2crZAAR</id><number>MA-00036</number><description>null</description><homeScore>0</homeScore><homeTeam>Suns</homeTeam><vistitorTeam>Bulls</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-16+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>clIR0dUIQO</externalId></Match><Match><id>a005000000H2crUAAR</id><number>MA-00035</number><description>null</description><homeScore>0</homeScore><homeTeam>hornets</homeTeam><vistitorTeam>sandiego</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-15+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>nmrZOHQ6EZ</externalId></Match></Matches></Round></Rounds></export>';
    public static String xmlTournamentInValid = '<?xml version="1.0"?><export><meta><exportPackage>Tournament+Template</exportPackage><exportAuthor>mat+men</exportAuthor><exportOrganization>Force.com+Labs</exportOrganization><exportCreateDate>2010-09-08+13%3A17%3A42</exportCreateDate></meta><Teams><Team><id>a025000000DPa9sAAD</id><name>Suns</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9tAAD</id><name>Bulls</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9uAAD</id><name>Lakers</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPa9vAAD</id><name>Hawks</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhKvAAL</id><name>sandiego</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL0AAL</id><name>hornets</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhL5AAL</id><name>shperes</name><description>null</description><rank>null</rank></Team><Team><id>a025000000DPhLFAA1</id><name>bakers</name><description>null</description><rank>null</rank></Team></Teams><Tournamen000BguqpAAB</id><name>Sample+Ndescription>null</description><teamCount>8</teamCount><externalId>m23oSFl3gG</externalId></Tournament><Rounds><Round><id>a015000000WyG4iAAF</id><name>round+1</name><deadline>2010-09-17+05%3A51%3A00</deadline><roundNumber>1</roundNumber><scorePoints>3</scorePoints><status>Active</status><tournament>a035000000BguqpAAB</tournament><ExternalId>EA5iHGBGXm</ExternalId><Matches><Match><id>a005000000H2crPAAR</id><number>MA-00034</number><description>null</description><homeScore>0</homeScore><homeTeam>bakers</homeTeam><vistitorTeam>shperes</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-13+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>fnBddNQncK</externalId></Match><Match><id>a005000000H2creAAB</id><number>MA-00037</number><description>null</description><homeScore>0</homeScore><homeTeam>Lakers</homeTeam><vistitorTeam>Hawks</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-19+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>efYAkARQo6</externalId></Match><Match><id>a005000000H2crZAAR</id><number>MA-00036</number><description>null</description><homeScore>0</homeScore><homeTeam>Suns</homeTeam><vistitorTeam>Bulls</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-16+05%3A53%3A00</schedule><visitorScore>0</visitorScore><externalId>clIR0dUIQO</externalId></Match><Match><id>a005000000H2crUAAR</id><number>MA-00035</number><description>null</description><homeScore>0</homeScore><homeTeam>hornets</homeTeam><vistitorTeam>sandiego</vistitorTeam><winnerTeam>null</winnerTeam><followingMatch>null</followingMatch><round>EA5iHGBGXm</round><schedule>2010-09-15+05%3A52%3A00</schedule><visitorScore>0</visitorScore><externalId>nmrZOHQ6EZ</externalId></Match></Matches></Round></Rounds></export>';

    public static Brackets_Tournament__c createFullTournament() {
        return BracketsTestUtilities.createFullTournament(
            12,
            BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE
        );
    }

    /**
     * Create a tournament with the first round and predictions for users
     */

    public static Brackets_Tournament__c createFullTournament(
        Integer teamCount,
        String tournamentType
    ) {
        List<User> users = new List<User>();
        users.add(BracketsTestUtilities.createUser());
        return createFullTournamentUsers(
            users,
            teamCount,
            tournamentType,
            new Brackets_Group__c()
        );
    }

    /**
     * Create a tournament with the first round and predictions for users
     * @users List of users with predictions
     */

    public static Brackets_Tournament__c createFullTournamentUsers(
        List<User> users,
        Integer teamCount,
        String tournamentType,
        Brackets_Group__c gr
    ) {
        // Create tournament, rounds and matches
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        Brackets_Tournament__c tournament = null;

        if (
            BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE.equalsIgnoreCase(
                tournamentType
            )
        ) {
            tournament = BracketsTestUtilities.createTournament(
                'Small Season 2010',
                12,
                BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE
            );
            BracketsTournamentUtilities.createNFLPlayoffTournamentTreeMethod(
                tournament.Id
            );
        } else if (
            BracketsTournamentUtilities.STANDARD_TOURNAMENT_TYPE.equalsIgnoreCase(
                tournamentType
            )
        ) {
            tournament = BracketsTestUtilities.createTournament(
                'Small Season 2010',
                teamCount
            );
            BracketsTournamentUtilities.createTournamentTreeMethod(
                tournament.Id,
                teamCount,
                BracketsTournamentUtilities.roundCount(teamCount)
            );
        }

        // Associate group
        gr.Brackets_Tournament__c = tournament.Id;
        upsert gr;

        //Add Users and UserTournaments
        List<Brackets_UserTournament__c> userTs = new List<Brackets_UserTournament__c>();
        userTs.add(
            BracketsTestUtilities.createUserTournament(
                users[0].Id,
                tournament.Id,
                gr.Id
            )
        );

        // Create teams
        List<Brackets_Team__c> teams = BracketsTestUtilities.createTeamList(
            teamCount
        );
        upsert teams;

        // Set random teams to the first round
        Brackets_Round__c firstRound = [
            SELECT Id, Name, RoundNumber__c, Deadline__c
            FROM Brackets_Round__c
            WHERE Brackets_Tournament__c = :tournament.Id
            ORDER BY RoundNumber__c ASC
            LIMIT 1
        ];

        List<Brackets_Match__c> matches = new List<Brackets_Match__c>();
        matches = [
            SELECT Id, HomeBrackets_Team__c, VisitorBrackets_Team__c
            FROM Brackets_Match__c
            WHERE
                Brackets_Round__r.Brackets_Tournament__c = :tournament.Id
                AND Brackets_Round__c = :firstRound.Id
        ];

        for (Brackets_Match__c m : matches) {
            BracketsTestUtilities.setMatch(
                m,
                BracketsTestUtilities.getRandomTeam(teams),
                BracketsTestUtilities.getRandomTeam(teams)
            );
        }

        upsert matches;

        return tournament;
    }

    /**
     * Create a new Match
     */
    public static Brackets_Match__c createMatch(
        Brackets_Team__c home,
        Brackets_Team__c visitor,
        Brackets_Round__c round,
        String conference
    ) {
        Brackets_Match__c match = new Brackets_Match__c();

        //RSC Changed to work with round deadline instead.
        /*        
        BracketsTestUtilities.lastMatchDate = BracketsTestUtilities.lastMatchDate == null 
            ?  DateTime.now().addMonths(2 + BracketsTestUtilities.rand(10))
            : BracketsTestUtilities.lastMatchDate + 1;
          */

        Datetime schedule = Datetime.now();

        Integer i = Integer.valueOf('' + round.RoundNumber__c);

        schedule = schedule.addMinutes(10 * i);

        System.debug(
            '\n\n\nattempting insert round deadline ' +
            round.Deadline__c +
            ' match ' +
            schedule +
            ' round number ' +
            round.RoundNumber__c
        );

        match.HomeBrackets_Team__c = home != null ? home.Id : null;
        match.VisitorBrackets_Team__c = visitor != null ? visitor.Id : null;
        match.Brackets_Round__c = Round.Id;
        match.WinnerBrackets_Team__c = null;
        match.Schedule__c = schedule;
        match.Conference__c = conference;

        insert match;

        return match;
    }

    /**
     * Set an existing Match
     */
    private static void setMatch(
        Brackets_Match__c match,
        Brackets_Team__c home,
        Brackets_Team__c visitor
    ) {
        BracketsTestUtilities.lastMatchDate = BracketsTestUtilities.lastMatchDate ==
            null
            ? DateTime.now().addMonths(2 + BracketsTestUtilities.rand(10))
            : BracketsTestUtilities.lastMatchDate + 1;

        match.HomeBrackets_Team__c = home != null ? home.Id : null;
        match.VisitorBrackets_Team__c = visitor != null ? visitor.Id : null;
        match.WinnerBrackets_Team__c = null;
        match.Schedule__c = BracketsTestUtilities.lastMatchDate;
    }

    /**
     * Create new NFL Tournament w/o automatic creation
     * Set flag on true in order to avoid automatic creation of Rounds and Matches
     */
    public static Brackets_Tournament__c getNewNFLTournament() {
        return BracketsTestUtilities.getNewTournament(
            BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE
        );
    }

    /**
     * Create new Standard Tournament w/o automatic creation
     * Set flag on true in order to avoid automatic creation of Rounds and Matches
     */
    public static Brackets_Tournament__c getNewStandardTournament() {
        return BracketsTestUtilities.getNewTournament(
            BracketsTournamentUtilities.DEFAULT_TOURNAMENT_TYPE
        );
    }

    private static Brackets_Tournament__c getNewTournament(String tType) {
        //Set the flag to avoid autocreation
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        Brackets_Tournament__c myTour = new Brackets_Tournament__c();
        myTour = BracketsTestUtilities.createTournament('Name', 4);

        if (
            BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE.equalsIgnoreCase(
                tType
            )
        ) {
            BracketsTournamentUtilities.createNFLPlayoffTournamentTreeMethod(
                myTour.Id
            );
        } else if (
            BracketsTournamentUtilities.DEFAULT_TOURNAMENT_TYPE.equalsIgnoreCase(
                tType
            )
        ) {
            BracketsTournamentUtilities.createTournamentTreeMethod(
                myTour.Id,
                4,
                2
            );
        }

        return myTour;
    }

    /**
     * Create a new Round with default values
     * @param tournament Tournament the round will be played
     */
    public static Brackets_Round__c createSimpleRound(
        Brackets_Tournament__c tournament
    ) {
        return BracketsTestUtilities.createRound(
            tournament,
            BracketsTestUtilities.rand(10) + 1,
            DateTime.now(),
            3,
            BracketsTestUtilities.createRandomWord('Round-')
        );
    }

    /**
     * Create a new Round
     * @param tournament Tournament the round will be played
     * @param number     Round number
     * @param deadline   Last date to make predictions in the round
     * @param points     Score points for the round
     * @param name       Name of the round
     */
    public static Brackets_Round__c createRound(
        Brackets_Tournament__c tournament,
        Integer rnumber,
        DateTime deadline,
        Integer points,
        String name
    ) {
        Brackets_Round__c round = new Brackets_Round__c();

        round.RoundNumber__c = rnumber;
        round.Brackets_Tournament__c = tournament.Id;
        round.Deadline__c = deadline;
        round.ScorePoints__c = points;
        round.Name = name;

        insert round;

        return round;
    }

    /**
     * Create a UserMatchPrediction for a Tournament
     * @param tId ( Affected Brackets_Tournament__c Id )
     * @return ump
     */
    public static List<Brackets_UserMatchPred__c> createUserMatchPrediction(
        Id tId,
        Id gId,
        Id uId
    ) {
        if (uId == null) {
            Brackets_UserTournament__c ut = new Brackets_UserTournament__c(
                User__c = UserInfo.getUserId(),
                Brackets_Tournament__c = tId,
                Brackets_Group__c = gId
            );
            insert ut;
            uId = ut.Id;
        }

        List<Brackets_UserMatchPred__c> uMatchPred = new List<Brackets_UserMatchPred__c>();
        Integer i = 0;
        for (Brackets_Round__c round : [
            SELECT
                Id,
                ScorePoints__c,
                Brackets_Tournament__c,
                (
                    SELECT
                        Id,
                        HomeBrackets_Team__c,
                        VisitorBrackets_Team__c,
                        WinnerBrackets_Team__c
                    FROM Matches__r
                )
            FROM Brackets_Round__c
            WHERE Brackets_Tournament__c = :tId
        ]) {
            if (i < 1) {
                for (Brackets_Match__c match : round.Matches__r) {
                    Brackets_UserMatchPred__c ump = new Brackets_UserMatchPred__c();
                    ump.PredictedWinnerBrackets_Team__c = match.VisitorBrackets_Team__c;
                    ump.Brackets_UserTournament__c = uId;
                    ump.Brackets_Match__c = match.Id;
                    uMatchPred.add(ump);
                }
            }
            i++;
        }
        insert uMatchPred;

        return uMatchPred;
    }

    public static Brackets_UserMatchPred__c createPrediction(
        Brackets_UserTournament__c ut,
        Brackets_Match__c match,
        Brackets_Team__c winner
    ) {
        Brackets_UserMatchPred__c ret = new Brackets_UserMatchPred__c();
        ret.Brackets_UserTournament__c = ut.id;
        ret.Brackets_Match__c = match.id;
        ret.PredictedWinnerBrackets_Team__c = winner.id;
        insert ret;
        return ret;
    }
    /**
     * Create a UserMatchPrediction list for a Tournament
     *
     * @param userId     an id of a user
     * @return a list of prediction
     */
    //2011-03-07 Not in use?
    /*
    public static List<Brackets_UserMatchPred__c> createUserMatchPredictionList(Id userId){
        
        List<Brackets_UserMatchPred__c> uMatchPred = new List<Brackets_UserMatchPred__c>();
        
        Brackets_Tournament__c tournament = BracketsTestUtilities.getNewStandardTournament();
        Brackets_Group__c groupp = BracketsTestUtilities.getGroup(tournament.Id);
        Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');
        Brackets_Team__c teamB = BracketsTestUtilities.createTeam('B-Team');
        
        List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
        auxList.add( teamA );
        auxList.add( teamB );
        upsert auxList;
        
        Brackets_Round__c round = BracketsTestUtilities.createSimpleRound(tournament);
        Brackets_Match__c match = BracketsTestUtilities.createMatch(teamA,teamB,round, null);
        Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(userId, tournament.Id, groupp.Id);
        
        uMatchPred = BracketsTestUtilities.createUserMatchPrediction(tournament.Id,groupp.Id,userTournament.Id);
        
        return uMatchPred;
    }
    */

    /**
     * Create a new UserTournament
     * @return userTournament
     */
    public static Brackets_UserTournament__c createUserTournament(
        Id userId,
        Id tournamentId,
        Id groupId
    ) {
        Brackets_UserTournament__c userTournament = new Brackets_UserTournament__c();

        userTournament.User__c = userId;
        userTournament.Brackets_Tournament__c = tournamentId;
        userTournament.Brackets_Group__c = groupId;

        insert userTournament;

        return userTournament;
    }

    /**
     * Create a new Tournament
     * @return tournament
     */
    public static Brackets_Tournament__c createTournament(
        String name,
        Integer teamCount
    ) {
        return BracketsTestUtilities.createTournament(
            name,
            teamCount,
            'Standard'
        );
    }

    public static Brackets_Tournament__c createTournament(
        String name,
        Integer teamCount,
        String tournamentType
    ) {
        Brackets_Tournament__c tournament = new Brackets_Tournament__c();

        Datetime deadline = Datetime.now();
        deadline = deadline.addMinutes(2);

        tournament.Name = name;
        tournament.Description__c = 'Test tournament';
        tournament.Version__c = BracketsTestUtilities.rand(100);
        tournament.TeamCount__c = teamCount;
        tournament.Type__c = tournamentType;
        tournament.Deadline__c = deadline;

        insert tournament;

        return tournament;
    }

    /**
     * Returns a random team from the team list
     * @return team
     */
    public static Brackets_Team__c getRandomTeam(List<Brackets_Team__c> teams) {
        Integer index = BracketsTestUtilities.rand(teams.size());
        Brackets_Team__c res = teams[index];
        teams.remove(index);
        return res;
    }

    /**
     * Create a list of Teams
     * @return teamList
     */
    public static List<Brackets_Team__c> createTeamList(Integer count) {
        List<Brackets_Team__c> teamList = new List<Brackets_Team__c>();
        List<String> nbaTeams = new List<String>{
            'Atlanta Hawks',
            'Boston Celtics',
            'Charlotte Bobcats',
            'Chicago Bulls',
            'Cleveland Cavaliers',
            'Dallas Mavericks',
            'Denver Nuggets',
            'Detroit Pistons',
            'Golden State Warriors',
            'Houston Rockets',
            'Indiana Pacers',
            'Los Angeles Clippers',
            'Los Angeles Lakers',
            'Memphis Grizzlies',
            'Miami Heat',
            'Milwaukee Bucks',
            'Minnesota Timberwolves',
            'New Jersey Nets',
            'New Orleans Hornets',
            'New York Knicks',
            'Oklahoma City Thunder',
            'Orlando Magic',
            'Philadelphia 76ers',
            'Phoenix Suns',
            'Portland Trail Blazers',
            'Sacramento Kings',
            'San Antonio Spurs',
            'Toronto Raptors',
            'Utah Jazz',
            'Washington Wizards '
        };
        Integer teamCount = (count > nbaTeams.size() ||
            count == 0)
            ? nbaTeams.size()
            : count;

        for (Integer i = 0; i < teamCount; i++) {
            teamList.add(new Brackets_Team__c(Name = nbaTeams[i]));
        }

        return teamList;
    }

    /**
     * Create a new Team
     * @return team
     */
    public static Brackets_Team__c createTeam(String name) {
        return new Brackets_Team__c(Name = name);
    }

    /**
     * Create a new Brackets_Group__c
     * @params tId ( tournament Id )
     * @return cGroup
     */
    public static Brackets_Group__c getGroup(String tId) {
        return BracketsTestUtilities.getGroup(
            tId,
            BracketsGroupUtilities.BET_TYPE_FULL_TOURNAMENT
        );
    }

    public static Brackets_Group__c getGroup(String tId, String groupType) {
        Brackets_Group__c cGroup = new Brackets_Group__c();
        cGroup.Brackets_Tournament__c = (tId != null &&
            tId != '')
            ? tId
            : BracketsTestUtilities.getNewNFLTournament().Id;
        cGroup.Type__c = groupType;
        insert cGroup;
        return cGroup;
    }

    public static Brackets_Group__c getClosedGroup(String tId) {
        Brackets_Group__c groupp = getGroup(tId);
        update groupp;
        return groupp;
    }

    /*
     * Create a new User without profile
     * @return testUser
     */
    public static User createUser() {
        Sobject p;
        for (
            Sobject prof : Database.query(
                'Select Id, PermissionsModifyAllData, Name from Profile limit 100'
            )
        ) {
            if (Boolean.valueOf(prof.get('PermissionsModifyAllData'))) {
                p = prof;
                break;
            }
        }
        return BracketsTestUtilities.createUser(p);
    }

    /*
     * Create a new User
     * @param p New user profile
     * @return testUser
     */
    public static User createUser(Sobject p) {
        String namePrefix = BracketsTestUtilities.createRandomWord();
        User testUser = new User();

        testUser.Email = 'test@test.com';
        testUser.Username = namePrefix + '@testuser.com';
        testUser.LastName = 'test';
        testUser.Alias = 'test';
        testUser.ProfileId = p.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';

        insert testUser;

        return testUser;
    }

    /**
     * Create a random word
     */
    public static String createRandomWord() {
        return BracketsTestUtilities.createRandomWord('word');
    }

    /**
     * Create a random word
     * @param prefix Prefix for the generated word
     */
    public static String createRandomWord(String prefix) {
        String ret = prefix + math.rint(math.random() * 100000);

        return ret;
    }

    //RSC 2011-03-07 Not in use.
    /*
    public static Brackets_Group__c createRandomGroup(){
        Brackets_Group__c groupp = new Brackets_Group__c();
        groupp.Name = createRandomWord();
        groupp.Brackets_Tournament__c = createTournament(createRandomWord(),2).Id;
        insert groupp;
        return groupp;
    }
    */

    /**
     * Generate random integer between 0 and max-1
     */
    public static Integer rand(Integer max) {
        return Math.mod(Math.round(Math.random() * 10000), max);
    }

    /**
     *	Filter the possible teams what can play a match.
     *
     *	@param 	match				the selected match to check the teams
     *	@param 	matchesMap			all the matches
     *	@param	possibleTeamsResult	a list of candidates teams to play this match.
     */
    private static void possibleTeamsForMatch(
        Brackets_Match__c match,
        Map<String, Brackets_Match__c> matchesMap,
        List<String> possibleTeamsResult
    ) {
        Boolean matched = false;
        for (Brackets_Match__c currentMatch : matchesMap.values()) {
            if (currentMatch.FollowingBrackets_Match__c == match.Id) {
                matched = true;
                if (currentMatch.Brackets_Round__r.RoundNumber__c == 1.0) {
                    if (
                        currentMatch.FollowingIsHome__c &&
                        match.VisitorBrackets_Team__c != null
                    ) {
                        possibleTeamsResult.add(match.VisitorBrackets_Team__c);
                    } else if (match.HomeBrackets_Team__c != null) {
                        possibleTeamsResult.add(match.HomeBrackets_Team__c);
                    }
                }
                possibleTeamsForMatch(
                    currentMatch,
                    matchesMap,
                    possibleTeamsResult
                );
            }
        }
        if (!matched) {
            possibleTeamsResult.add(match.HomeBrackets_Team__c);
            possibleTeamsResult.add(match.VisitorBrackets_Team__c);
        }
    }
}
