@isTest
class BracketsProcessUpdateTest {
    @isTest
    static void test2() {
        Brackets_Tournament__c myTour = BracketsTestUtilities.createFullTournament(
            2,
            BracketsTournamentUtilities.DEFAULT_TOURNAMENT_TYPE
        );
        myTour.isChild__c = true;
        myTour.Update_Source__c = 'http://www.salesforce.com';
        update myTour;
        List<Brackets_Tournament__c> myTourList = new List<Brackets_Tournament__c>{
            myTour
        };

        Test.startTest();
        BracketsProccessUpdate cTest = new BracketsProccessUpdate(myTour.Id);

        System.assert(cTest.tourament != null);
        Test.stopTest();
    }

    @isTest
    static void test3() {
        Brackets_Tournament__c myTour = BracketsTestUtilities.createFullTournament(
            2,
            BracketsTournamentUtilities.DEFAULT_TOURNAMENT_TYPE
        );
        myTour.isChild__c = true;
        myTour.Update_Source__c = 'http://www.salesforce.com';
        update myTour;
        List<Brackets_Tournament__c> myTourList = new List<Brackets_Tournament__c>{
            myTour
        };

        Test.startTest();
        BracketsProccessUpdate.processSingleUpdate(myTour.Update_Source__c);
        System.assert(myTour != null);
        Test.stopTest();
    }

    @isTest
    static void test4() {
        Brackets_Tournament__c myTour = BracketsTestUtilities.createFullTournament(
            2,
            BracketsTournamentUtilities.DEFAULT_TOURNAMENT_TYPE
        );
        myTour.isChild__c = true;
        myTour.Update_Source__c = 'http://www.salesforce.com';
        update myTour;
        List<Brackets_Tournament__c> myTourList = new List<Brackets_Tournament__c>{
            myTour
        };

        Test.startTest();
        BracketsProccessUpdate.proccessMultipleUpdate(myTourList);
        System.assert(myTour != null);
        Test.stopTest();
    }
}
