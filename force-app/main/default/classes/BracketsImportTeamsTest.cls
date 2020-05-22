@isTest
class BracketsImportTeamsTest {
    @isTest
    static void testTeamImportValid() {
        delete [SELECT Id FROM Brackets_Tournament__c];

        BracketsImportTeams impTeams = new BracketsImportTeams();

        try {
            impTeams.processImportedDocument(
                BracketsTestUtilities.xmlTournamentValid
            );
            List<Brackets_Team__c> teamList = [SELECT id FROM Brackets_Team__c];
            System.assert(teamList.size() > 0);
        } catch (Exception ex) {
            System.assert(false);
        }
    }

    @isTest
    static void testTeamImportInvalid() {
        delete [SELECT Id FROM Brackets_Tournament__c];

        BracketsImportTeams impTeams = new BracketsImportTeams();

        try {
            impTeams.processImportedDocument(
                BracketsTestUtilities.xmlTournamentTeamInValid
            );
            System.assert(false);
        } catch (Exception ex) {
            System.assert(true);
        }
    }
}
