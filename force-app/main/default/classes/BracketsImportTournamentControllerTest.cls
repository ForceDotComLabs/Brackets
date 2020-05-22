@isTest
class BracketsImportTournamentControllerTest {
    @isTest
    static void testManualUpdate() {
        Brackets_Tournament__c t = BracketsTestUtilities.createFullTournament(
            4,
            BracketsTournamentUtilities.STANDARD_TOURNAMENT_TYPE
        );
        t.isChild__c = true;
        upsert t;
        Apexpages.currentPage().getParameters().put('tId', t.Id);
        BracketsImportTournamentController c = new BracketsImportTournamentController();

        //test tournament list
        List<Brackets_Tournament__c> ts = c.getTList();
        System.assert(ts.size() > 0);

        //test manu update
        c.doManualUpdate();
        System.assert(c.xmlMessage != null);

        //test garbage URL
        c.importTournament();
        System.assert(c.xmlMessage != null);

        //test http
        c.sourceUrl = 'http://garbage.c';
        c.importTournament();
        System.assert(c.xmlMessage != null);
    }
}
