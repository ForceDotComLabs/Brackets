@isTest
class BracketsFeedItemUtilityTest {
    @isTest
    static void testLastChatter() {
        BracketsTournamentUtilities.CreatingTournamentTree = true;
        //Create a user
        User testUser = BracketsTestUtilities.createUser();

        System.runAs(testUser) {
            Brackets_Tournament__c tournament = BracketsTestUtilities.createTournament(
                'Test1 RoundByRound',
                4
            );

            List<Id> ts = new List<Id>();
            ts.add(tournament.Id);

            Brackets_Group__c groupA = BracketsTestUtilities.getGroup(
                tournament.Id,
                BracketsGroupUtilities.BET_TYPE_BY_ROUND
            );

            BracketsFeedItemUtility util = new BracketsFeedItemUtility();

            String s = util.getLastTournamentGroupChatter(groupA.id, 40);

            System.assertEquals(s, '');

            FeedItem item = new FeedItem();
            item.parentId = groupA.id;
            item.body = 'This is a test';
            insert item;

            s = util.getLastTournamentGroupChatter(groupA.id, 40);

            System.assert(s != null);
            System.assertEquals(s, 'This is a test');

            FeedItem item2 = new FeedItem();
            item2.parentId = groupA.id;
            item2.body = 'This is a test56789 123456789 123456789 123456789';
            insert item2;

            s = util.getLastTournamentGroupChatter(groupA.id, 40);

            System.assert(s != null);
            System.assertEquals(s, 'This is a test56789 123456789 1234567...');
        }

    }
}
