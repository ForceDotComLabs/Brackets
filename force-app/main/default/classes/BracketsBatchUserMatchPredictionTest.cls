@isTest
class BracketsBatchUserMatchPredictionTest {
    @isTest
    static void testAllMethod() {
        String query = '';
        BracketsBatchUserMatchPrediction batchUMP = new BracketsBatchUserMatchPrediction(
            query
        );

        try {
            batchUMP.start(null);
            System.assert(false, 'This line shouldn\'t be executed.');
        } catch (Exception e) {
            System.assert(true, 'This line should be executed.');
        }

        batchUMP.execute(null, new List<Sobject>());
        batchUMP.finish(null);
    }
}
