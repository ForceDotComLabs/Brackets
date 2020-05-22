@isTest
class BracketsExportTeamsTest {
    @isTest
    static void testExportTeams() {
        Brackets_Tournament__c tournament = BracketsTestUtilities.createFullTournament(
            4,
            BracketsTournamentUtilities.STANDARD_TOURNAMENT_TYPE
        );
        BracketsExportTeams bracketsExportTeams = new BracketsExportTeams(
            tournament.Id,
            new Xmlstreamwriter()
        );
        Xmlstreamwriter writer = bracketsExportTeams.BracketsexportTeams();
        System.assert(writer.getXmlString() != null);
    }

    @isTest
    static void testExportTeamsWithImport() {
        Brackets_Team__c teamA = BracketsTestUtilities.createTeam(
            'A-Team' + Datetime.now()
        );
        Brackets_Team__c teamB = BracketsTestUtilities.createTeam(
            'B-Team' + Datetime.now()
        );
        Brackets_Team__c teamC = BracketsTestUtilities.createTeam(
            'C-Team' + Datetime.now()
        );
        Brackets_Team__c teamD = BracketsTestUtilities.createTeam(
            'D-Team' + Datetime.now()
        );

        List<Brackets_Team__c> teams = new List<Brackets_Team__c>();
        teams.add(teamA);
        teams.add(teamB);
        teams.add(teamC);
        teams.add(teamD);

        insert teams;

        List<Brackets_Team__c> allTeams = [
            SELECT Id, Name, ExternalID__c
            FROM Brackets_Team__c
        ];

        delete teams;

        BracketsExportTeams exportTeams = new BracketsExportTeams(
            null,
            new Xmlstreamwriter()
        );

        exportTeams.buildXmlString(teams);

        String s = exportTeams.out.getXmlString();

        System.debug(LoggingLevel.Info, '1234' + s);

        BracketsImportTeams importTeams = new BracketsImportTeams();

        importTeams.processImportedDocument(s);

        List<Brackets_Team__c> allTeams2 = [
            SELECT Id, Name, ExternalID__c
            FROM Brackets_Team__c
        ];

        System.assert(allTeams.size() == allTeams2.size());

        importTeams.processImportedDocument(s);

        List<Brackets_Team__c> allTeams3 = [
            SELECT Id, Name, ExternalID__c
            FROM Brackets_Team__c
        ];

        System.assert(allTeams.size() == allTeams3.size());
    }
}
