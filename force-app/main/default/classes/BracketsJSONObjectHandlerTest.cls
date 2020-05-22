@isTest
class BracketsJSONObjectHandlerTest {
    @isTest
    static void testAllMethods() {
        List<Sobject> predictionsList;
        String jsonResult;
        Sobject obj;
        Integer value = 25;
        String fieldName = 'Points__c';
        List<String> fields = new List<String>{ fieldName };
        Brackets_UserMatchPred__c sobjecta = new Brackets_UserMatchPred__c();
        sobjecta.Points__c = value;

        // Serializing match prediction
        BracketsJSONObjectHandler handler = new BracketsJSONObjectHandler(
            sobjecta,
            fields
        );
        jsonResult = handler.toJSON();

        System.assert(
            jsonResult ==
            '{"' + fieldName + '": "' + String.valueOf(value) + '"}'
        );

        // Deserializing a single match prediction
        handler = new BracketsJSONObjectHandler(jsonResult, sobjecta);
        obj = handler.toSObject();

        System.assert(obj.get(fieldName) == value);

        handler.jsonString = '[' + jsonResult + ']';
        predictionsList = handler.toSObjectArray();

        System.assert(predictionsList.size() == 1);
        System.assert(predictionsList.get(0).get(fieldName) == value);

        predictionsList = new List<Sobject>();
        predictionsList.add(sobjecta);
        predictionsList.add(sobjecta);

        // Deserializing a list of match predictions

        handler = new BracketsJSONObjectHandler(predictionsList, fields);
        jsonResult = handler.toJSON();
        System.assert(predictionsList.get(0).get(fieldName) == value);
        System.assert(predictionsList.get(1).get(fieldName) == value);
    }
}
