@isTest
class BracketsSitesTournamentPublisherTest {
    //-------------------------------------------------------------------------
    // Test methods
    //-------------------------------------------------------------------------

    @isTest
    static void testGetOutputXml() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;

        Brackets_Tournament__c tournament = new Brackets_Tournament__c();
        tournament.Name = 'Test';
        tournament.TeamCount__c = 4;
        tournament.Type__c = 'Standard';
        tournament.Deadline__c = Datetime.now();
        tournament.Allow_Update__c = true;
        tournament.Version__c = 2;

        insert tournament;

        Apexpages.currentPage().getParameters().put('id', tournament.Id);
        Apexpages.currentPage().getParameters().put('tVersion', '1');
        BracketsSitesTournamentPublisher ut = new BracketsSitesTournamentPublisher();
        system.assert(ut.getOutputXml() != '');

        system.debug(LoggingLevel.Info, ut.getOutputXml());

        BracketsImportTournament importTour = new BracketsImportTournament(
            null
        );

        importTour.readingTournamentData(ut.getOutputXml());
        Brackets_Tournament__c t = importTour.tournament;
        system.debug(LoggingLevel.Info, t);
        System.assert(t.deadline__c != null);
    }
}
