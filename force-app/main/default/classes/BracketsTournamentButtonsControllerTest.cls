@isTest
class BracketsTournamentButtonsControllerTest {
    @isTest
    static void test() {
        Brackets_Tournament__c t = BracketsTestUtilities.createTournament(
            'test',
            2
        );
        BracketsTournamentButtonsController cont = new BracketsTournamentButtonsController(
            new Apexpages.Standardcontroller(t)
        );

        List<SelectOption> test = cont.getUrlPathPrefix();
        cont.getUrlPathPrefix();
        cont.saveUrl();
        cont.getSitePath();
        cont.publish2();
        System.assert(!cont.getCanPublish());
        cont.getShowUrlSelection();
        cont.getShowCreateSiteMsg();
        cont.doManualUpdate();
        System.assert(cont.xmlMessage != null);
    }
}
