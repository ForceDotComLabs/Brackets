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
@isTest
private class BracketsTreeViewTest {
    @isTest
    static void testStandardTree() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 General Prediction Controller',
                4
            );

            Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
                tournament.Id
            );

            Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');
            Brackets_Team__c teamB = BracketsTestUtilities.createTeam('B-Team');
            Brackets_Team__c teamC = BracketsTestUtilities.createTeam('C-Team');
            Brackets_Team__c teamD = BracketsTestUtilities.createTeam('D-Team');

            List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
            auxList.add(teamA);
            auxList.add(teamB);
            auxList.add(teamC);
            auxList.add(teamD);
            upsert auxList;

            Brackets_Round__c round = BracketsTestUtilities.createRound(
                tournament,
                1,
                null,
                4,
                'Round1-Test'
            );

            Brackets_Round__c round2 = BracketsTestUtilities.createRound(
                tournament,
                2,
                null,
                8,
                'Round2-Test'
            );

            Brackets_Match__c match = BracketsTestUtilities.createMatch(
                teamA,
                teamB,
                round,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );

            Brackets_Match__c match2 = BracketsTestUtilities.createMatch(
                teamC,
                teamD,
                round,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );

            round.Deadline__c = match.schedule__c.addMinutes(-5);
            update round;

            Brackets_Match__c match3 = BracketsTestUtilities.createMatch(
                null,
                null,
                round2,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );
            round2.Deadline__c = match3.schedule__c.addMinutes(-5);
            update round2;

            match.FollowingBrackets_Match__c = match3.id;
            match.FollowingIsHome__c = true;
            update match;

            match2.FollowingBrackets_Match__c = match3.id;
            update match2;

            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp.Id
            );

            //build the base controller
            BracketsTreeView tree = new BracketsTreeView(
                tournament.id,
                groupp,
                false,
                null
            );

            //test basics
            System.assert(tree.tournament != null);
            System.assert(tree.teamMap.size() == auxList.size());
            System.assert(tree.roundsByNumber.size() == 2);
            System.assert(tree.matchesByPosition.size() == 3);

            //now we should test the tree view standard
            BracketsTreeViewStandard standard = new BracketsTreeViewStandard(
                tree
            );

            //so some additional tests
            System.assert(standard.orderedRounds != null);
            System.assert(standard.orderedRounds.size() == 2);
            System.assert(standard.getTournamentId() == '' + tournament.id);
            System.assert(standard.getGroupId() == '' + groupp.id);

            //lets do some work on the orderedRounds
            for (BracketsTreeView.RoundData current : standard.orderedRounds) {
                System.assert(current.matches != null);
                System.assert(current.round != null);
            }
            BracketsTreeView.RoundData postRound1 = standard.orderedRounds.get(
                0
            );
            System.assert(postRound1.matches.size() == 2);
            BracketsTreeView.MatchData postMatch1 = postRound1.matches.get(0);
            System.assert(postMatch1.match != null);
            System.assert(postMatch1.home != null);
            System.assert(postMatch1.home.team.Name == teamA.name);
            System.assert(postMatch1.visitor.team.Name == teamB.name);

            BracketsTreeView.MatchData postMatch2 = postRound1.matches.get(1);
            System.assert(postMatch2.match != null);
            System.assert(postMatch2.home != null);
            System.assert(postMatch2.home.team.Name == teamC.name);
            System.assert(postMatch2.visitor.team.Name == teamD.name);

            BracketsTreeView.RoundData postRound2 = standard.orderedRounds.get(
                1
            );
            System.debug('postRound2: ' + postRound2);
            System.assert(postRound2.matches.size() == 1);
            BracketsTreeView.MatchData postMatch3 = postRound2.matches.get(0);
            System.assert(postMatch3.match != null);
            System.assert(postMatch3.home != null);
            System.assert(postMatch3.home.team == null);
            System.assert(postMatch3.visitor != null);
            System.assert(postMatch3.visitor.team == null);

            //lets turn off
            BracketsTournamentUtilities.CreatingTournamentTree = true;

            //now let's create a prediction or two
            Brackets_UserMatchPred__c p1 = BracketsTestUtilities.createPrediction(
                userTournament,
                match,
                teamA
            );
            Brackets_UserMatchPred__c p2 = BracketsTestUtilities.createPrediction(
                userTournament,
                match2,
                teamD
            );
            Brackets_UserMatchPred__c p3 = BracketsTestUtilities.createPrediction(
                userTournament,
                match3,
                teamA
            );

            //now let's mark one team a winner
            match.WinnerBrackets_Team__c = teamA.Id;
            match.HomeScore__c = 10;
            update match;

            //now let's rebuild some objects and see how it looks
            tree = new BracketsTreeView(tournament.id, groupp, false, null);
            standard = new BracketsTreeViewStandard(tree);

            //double check a few things
            postRound1 = standard.orderedRounds.get(0);
            System.assert(postRound1.matches.size() == 2);
            postMatch1 = postRound1.matches.get(0);
            System.assert(postMatch1.match != null);
            System.assert(postMatch1.home != null);
            System.assert(postMatch1.home.team.Name == teamA.name);
            System.assert(postMatch1.home.predicted == null);
            System.assert(postMatch1.visitor.team.Name == teamB.name);
            System.assert(postMatch1.visitor.predicted == null);
            System.assert(postMatch1.winner.team != null);
            System.assert(postMatch1.winner.team.Name == teamA.name);

            postMatch2 = postRound1.matches.get(1);
            System.assert(postMatch2.match != null);
            System.assert(postMatch2.home != null);
            System.assert(postMatch2.home.team.Name == teamC.name);
            System.assert(postMatch2.visitor.team.Name == teamD.name);
            System.assert(postMatch2.winner.team == null);
            System.assert(postMatch2.prediction.team.Name == teamD.name);

            postRound2 = standard.orderedRounds.get(1);
            System.assert(postRound2.matches.size() == 1);
            postMatch3 = postRound2.matches.get(0);
            System.assert(postMatch3.match != null);
            System.assert(postMatch3.home.team == null);
            System.assert(postMatch3.home.predicted != null);
            System.assert(postMatch3.champion != null);

            System.assert(postMatch3.visitor != null);
            System.assert(postMatch3.visitor.team == null);
        }

    }

    @isTest
    static void testFootballTree() {
        BracketsTournamentUtilities.CreatingTournamentTree = false;

        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Small Season 2010',
                12,
                BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE
            );

            Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
                tournament.Id
            );

            Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');
            Brackets_Team__c teamB = BracketsTestUtilities.createTeam('B-Team');
            Brackets_Team__c teamC = BracketsTestUtilities.createTeam('C-Team');
            Brackets_Team__c teamD = BracketsTestUtilities.createTeam('D-Team');
            Brackets_Team__c teamE = BracketsTestUtilities.createTeam('E-Team');
            Brackets_Team__c teamF = BracketsTestUtilities.createTeam('F-Team');
            Brackets_Team__c teamG = BracketsTestUtilities.createTeam('G-Team');
            Brackets_Team__c teamH = BracketsTestUtilities.createTeam('H-Team');
            Brackets_Team__c teamI = BracketsTestUtilities.createTeam('I-Team');
            Brackets_Team__c teamJ = BracketsTestUtilities.createTeam('J-Team');
            Brackets_Team__c teamK = BracketsTestUtilities.createTeam('K-Team');
            Brackets_Team__c teamL = BracketsTestUtilities.createTeam('L-Team');

            List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
            auxList.add(teamA);
            auxList.add(teamB);
            auxList.add(teamC);
            auxList.add(teamD);
            auxList.add(teamE);
            auxList.add(teamF);
            auxList.add(teamG);
            auxList.add(teamH);
            auxList.add(teamI);
            auxList.add(teamJ);
            auxList.add(teamK);
            auxList.add(teamL);
            upsert auxList;

            //let's make sure we have four rounds
            List<Brackets_Round__c> rounds = [
                SELECT Id, Name, Deadline__c
                FROM Brackets_Round__c
                WHERE Brackets_Tournament__c = :tournament.id
                ORDER BY RoundNumber__c
            ];
            System.assert(rounds.size() == 4);

            //make sure that round 0 has 4 matches
            Brackets_Round__c r = rounds.get(0);
            List<Brackets_Match__c> matches = [
                SELECT
                    Id,
                    Name,
                    Conference__c,
                    Position__c,
                    FollowingBrackets_Match__c
                FROM Brackets_Match__c
                WHERE Brackets_Round__c = :r.id
                ORDER BY Position__c
            ];
            System.assert(matches.size() == 4);

            Brackets_Match__c m1 = matches.get(0);
            m1.HomeBrackets_Team__c = teamA.id;
            m1.VisitorBrackets_Team__c = teamB.id;

            Brackets_Match__c m2 = matches.get(1);
            m2.HomeBrackets_Team__c = teamC.id;
            m2.VisitorBrackets_Team__c = teamD.id;

            Brackets_Match__c m3 = matches.get(2);
            m3.HomeBrackets_Team__c = teamE.id;
            m3.VisitorBrackets_Team__c = teamF.id;

            Brackets_Match__c m4 = matches.get(3);
            m4.HomeBrackets_Team__c = teamG.id;
            m4.VisitorBrackets_Team__c = teamH.id;

            update matches;

            Brackets_Round__c r2 = rounds.get(1);
            List<Brackets_Match__c> matches2 = [
                SELECT
                    Id,
                    Name,
                    Conference__c,
                    Position__c,
                    FollowingBrackets_Match__c
                FROM Brackets_Match__c
                WHERE Brackets_Round__c = :r2.id
                ORDER BY Position__c
            ];

            Brackets_Match__c m5 = matches2.get(0);
            //m5.HomeBrackets_Team__c = teamA.id;
            m5.VisitorBrackets_Team__c = teamI.id;
            System.assert(m1.FollowingBrackets_Match__c == m5.Id);

            Brackets_Match__c m6 = matches2.get(1);
            m6.HomeBrackets_Team__c = teamJ.id;
            //m5.VisitorBrackets_Team__c = teamI.id;
            System.assert(m2.FollowingBrackets_Match__c == m6.Id);

            Brackets_Match__c m7 = matches2.get(2);
            //m7.HomeBrackets_Team__c = teamK.id;
            m7.VisitorBrackets_Team__c = teamK.id;
            System.assert(m3.FollowingBrackets_Match__c == m7.Id);

            Brackets_Match__c m8 = matches2.get(3);
            m8.HomeBrackets_Team__c = teamL.id;
            //m8.VisitorBrackets_Team__c = teamL.id;
            System.assert(m4.FollowingBrackets_Match__c == m8.Id);

            update matches2;

            //now start to get a bunch of the football tree
            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp.Id
            );

            //build the base controller
            BracketsTreeView tree = new BracketsTreeView(
                tournament.id,
                groupp,
                false,
                null
            );

            //test basics
            System.assert(tree.tournament != null);
            System.assert(tree.teamMap.size() == auxList.size());
            System.assert(tree.roundsByNumber.size() == 4);
            System.assert(tree.matchesByPosition.size() == 11);

            //now we should test the tree view football
            BracketsTreeViewFootball football = new BracketsTreeViewFootball(
                tree
            );

            //make sure some of the basics work
            System.assert(football.orderedAFCRounds.size() == 3);
            System.assert(football.orderedNFCRounds.size() == 3);
        }
    }
}
