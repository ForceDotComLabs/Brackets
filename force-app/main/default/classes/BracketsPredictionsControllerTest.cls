@isTest
class BracketsPredictionsControllerTest {
    @isTest
    static void testPredictionController() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            //test that we get a !showTree when there are no user predictions
            BracketsPredictionsController controller = new BracketsPredictionsController();
            System.assert(!controller.showTree);

            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 General Prediction Controller',
                4
            );

            Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
                tournament.Id
            );
            Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');
            Brackets_Team__c teamB = BracketsTestUtilities.createTeam('B-Team');

            List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
            auxList.add(teamA);
            auxList.add(teamB);
            upsert auxList;

            Brackets_Round__c round = BracketsTestUtilities.createRound(
                tournament,
                1,
                null,
                4,
                'Round1-Test'
            );

            Brackets_Match__c match = BracketsTestUtilities.createMatch(
                teamA,
                teamB,
                round,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );
            round.Deadline__c = match.schedule__c.addMinutes(-5);
            update round;

            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp.Id
            );

            //single user tournament so it should automatically show tree
            controller = new BracketsPredictionsController();
            System.assert(controller.showTree);

            //multi user tournament so it should problem for which tournament to show
            Brackets_Group__c groupp2 = BracketsTestUtilities.getGroup(
                tournament.Id
            );
            Brackets_UserTournament__c userTournament2 = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp2.Id
            );
            controller = new BracketsPredictionsController();
            System.assert(!controller.showTree);

            //multi user tournament with show parameter
            ApexPages.currentPage().getParameters().put('show', groupp.Id);
            controller = new BracketsPredictionsController();
            System.assert(controller.showTree);

            //multi user tournament with a deadline that is before now and should be locked
            tournament.Deadline__c = Datetime.now().addMinutes(-1);
            update tournament;
            ApexPages.currentPage().getParameters().put('show', groupp.Id);
            controller = new BracketsPredictionsController();
            System.assert(controller.showTree);
            System.assert(controller.isLocked);

            //a couple of Booleans
            System.assert(controller.activeRound == null);
            System.assert(controller.isFullTournament);
        }

    }

    @isTest
    static void testSaveAllPred() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
            'Test1 RoundByRound',
            4
        );

        Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
            tournament.Id
        );
        Brackets_Team__c teamA = BracketsTestUtilities.createTeam('A-Team');
        Brackets_Team__c teamB = BracketsTestUtilities.createTeam('B-Team');

        List<Brackets_Team__c> auxList = new List<Brackets_Team__c>();
        auxList.add(teamA);
        auxList.add(teamB);
        upsert auxList;

        Brackets_Round__c round = BracketsTestUtilities.createRound(
            tournament,
            1,
            null,
            4,
            'Round1-Test'
        );

        Brackets_Match__c match = BracketsTestUtilities.createMatch(
            teamA,
            teamB,
            round,
            BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
        );
        round.Deadline__c = match.schedule__c.addMinutes(-5);
        update round;

        Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
            Userinfo.getUserId(),
            tournament.Id,
            groupp.Id
        );

        String jsonString =
            '{ "0" : { "matchId" : "' +
            match.Id +
            '" ,"userTour" : "' +
            userTournament.Id +
            '", "teamId" : "' +
            teamA.Id +
            '" , "userPred" : "" }}';

        ApexPages.currentPage().getParameters().put('show', groupp.Id);

        BracketsPredictionsController controller = new BracketsPredictionsController();

        controller.json = jsonString;
        controller.saveAllPred();

        System.assert(
            controller.messageType == 'success',
            'The result of save the prediction should be sucessful. message is : ' +
            controller.messageType
        );
    }

    //makes sure all the first round stuff works
    @isTest
    static void testRoundByRoundOne() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;
        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 RoundByRound',
                4
            );

            Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
                tournament.Id,
                BracketsGroupUtilities.BET_TYPE_BY_ROUND
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

            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp.Id
            );

            ApexPages.currentPage().getParameters().put('show', groupp.Id);
            BracketsPredictionsController controller = new BracketsPredictionsController();
            System.assert(controller.showTree);
            System.assert(!controller.isLocked);

            System.debug(
                '\n\nNextDeadline: ' +
                controller.nextDeadline +
                ' but the round deadline is ' +
                round.Deadline__c
            );
            System.assert(
                round.Deadline__c.format() == controller.nextDeadline.format()
            );

            System.assert(!controller.isFullTournament);
            System.assert(
                controller.activeRound ==
                Integer.valueOf('' + round.RoundNumber__c)
            );
        }
    }

    //makes sure all the second round stuff workds
    @isTest
    static void testRoundByRoundTwo() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;
        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 RoundByRound',
                4
            );
            tournament.deadline__c = tournament.deadline__c.addMinutes(-60);
            update tournament;

            Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
                tournament.Id,
                BracketsGroupUtilities.BET_TYPE_BY_ROUND
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
            match.Schedule__c = Datetime.now().addMinutes(-30);
            update match;

            Brackets_Match__c match2 = BracketsTestUtilities.createMatch(
                teamC,
                teamD,
                round,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );
            match2.Schedule__c = Datetime.now().addMinutes(-30);
            update match2;

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

            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp.Id
            );

            ApexPages.currentPage().getParameters().put('show', groupp.Id);
            BracketsPredictionsController controller = new BracketsPredictionsController();
            System.assert(controller.showTree);
            System.assert(!controller.isLocked);

            System.debug(
                '\n\nNextDeadline: ' +
                controller.nextDeadline +
                ' but the round deadline is ' +
                round.Deadline__c
            );
            System.assert(
                round2.Deadline__c.format() == controller.nextDeadline.format()
            );

            System.assert(!controller.isFullTournament);
            System.assert(
                controller.activeRound ==
                Integer.valueOf('' + round2.RoundNumber__c)
            );
        }

    }

    //makes sure everything shows as locked.
    @isTest
    static void testRoundByRoundThree() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;
        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 RoundByRound',
                4
            );
            tournament.deadline__c = tournament.deadline__c.addMinutes(-60);
            update tournament;

            Brackets_Group__c groupp = BracketsTestUtilities.getGroup(
                tournament.Id,
                BracketsGroupUtilities.BET_TYPE_BY_ROUND
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
            match.Schedule__c = Datetime.now().addMinutes(-45);
            update match;

            Brackets_Match__c match2 = BracketsTestUtilities.createMatch(
                teamC,
                teamD,
                round,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );
            match2.Schedule__c = Datetime.now().addMinutes(-45);
            update match2;

            round.Deadline__c = match.schedule__c.addMinutes(-5);
            update round;

            Brackets_Match__c match3 = BracketsTestUtilities.createMatch(
                null,
                null,
                round2,
                BracketsTournamentUtilities.NFL_CONFERENCE_AMERICAN
            );
            match3.Schedule__c = Datetime.now().addMinutes(-30);
            update match3;

            round2.Deadline__c = match3.schedule__c.addMinutes(-5);
            update round2;

            Brackets_UserTournament__c userTournament = BracketsTestUtilities.createUserTournament(
                Userinfo.getUserId(),
                tournament.Id,
                groupp.Id
            );

            ApexPages.currentPage().getParameters().put('show', groupp.Id);
            BracketsPredictionsController controller = new BracketsPredictionsController();
            System.assert(controller.showTree);

            System.debug(
                '\n\nNextDeadline: ' +
                controller.nextDeadline +
                ' but the round deadline is ' +
                round.Deadline__c
            );
            System.assert(controller.nextDeadline == null);
            System.assert(controller.isLocked);

            System.assert(!controller.isFullTournament);
            System.assert(controller.activeRound == null);
        }

    }

    @isTest
    static void testSimplePageRefs() {
        BracketsPredictionsController c = new BracketsPredictionsController();

        Pagereference p1 = c.gotoPoolDetail();

        System.assert(p1 != null);

        Pagereference p2 = c.goToPoolList();

        System.assert(p2 != null);
    }
}
