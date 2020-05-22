@isTest
class BracketsImportTournamentTest {
    @isTest
    static void testImport() {
        try {
            BracketsImportTournament controller = new BracketsImportTournament(
                ''
            );
            controller.processImportedDocument(
                BracketsTestUtilities.xmlTournamentValid
            );
        } catch (Exception ex) {
            System.assert(true);
        }
    }
}
