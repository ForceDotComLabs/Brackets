/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/

public with sharing class BracketsJSONObjectHandler {
    private Map<String, Schema.Sobjectfield> fieldsSobjectMap;
    private Sobject customObject;
    private List<Sobject> customObjectList;
    @TestVisible
    private String jsonString;
    private List<String> fields;
    private BracketsJSONObject jsonObject;

    /**
     *	Constructors
     */
    private BracketsJSONObjectHandler() {
        this.fields = new List<String>();
        this.jsonObject = new BracketsJSONObject();
    }

    public BracketsJSONObjectHandler(String jsonString, Sobject obj) {
        this();
        this.customObject = obj;
        this.fieldsSobjectMap = obj.getSObjectType()
            .getDescribe()
            .fields.getMap();
        this.jsonString = jsonString;
    }

    public BracketsJSONObjectHandler(
        List<Sobject> sobjectList,
        List<String> fields
    ) {
        this();
        customObjectList = sobjectList;
        this.fields = fields;
    }

    public BracketsJSONObjectHandler(Sobject obj, List<String> fields) {
        this();
        customObject = obj;
        this.fields = fields;
    }

    /**
     *	Given a single object or a list of them ,return these in json objects.
     *
     *	@param 	a json string.
     */
    public String toJSON() {
        String jsonResult = '';
        if (this.customObjectList != null) {
            jsonResult += '[';
            if (!this.customObjectList.isEmpty()) {
                for (Sobject obj : customObjectList) {
                    jsonResult += toJSON(obj) + ',';
                }
                jsonResult = jsonResult.substring(0, jsonResult.length() - 1);
            }
            jsonResult += ']';
        } else if (this.customObject != null) {
            jsonResult = toJSON(this.customObject);
        }
        return jsonResult;
    }

    /**
     *	Build a sobject populating their fields with data from a json.
     *
     *	@return 	a instance of SObject
     */
    public Sobject toSObject() {
        jsonObject = new BracketsJSONObject(
            new BracketsJSONObject.JSONTokener(jsonString)
        );
        return toSObject(jsonObject);
    }

    /**
     *	Build a list of sobject populating their fields with data from a json.
     *
     *	@return 	a list of SObject
     */
    public List<Sobject> toSObjectArray() {
        List<Sobject> sobjectList = new List<SObject>();
        List<BracketsJSONObject.value> valueObjects = BracketsJSONObject.JSONArray(
            new BracketsJSONObject.JSONTokener(jsonString)
        );
        for (BracketsJSONObject.value value : valueObjects) {
            if (value.obj != null) {
                sobjectList.add(toSObject(value.obj));
            }
        }
        return sobjectList;
    }

    /**
     *	Generate a Sobject from a BracketsJSONObject object.
     *
     *	@param obj	a BracketsJSONObject object.
     *	@return 	a Sobject.
     */
    private Sobject toSObject(BracketsJSONObject obj) {
        Sobject sobjectClone = customObject.getSObjectType().newSObject();
        for (String key : obj.keys()) {
            assignValue(key, (String) obj.get(key), sobjectClone);
        }
        return sobjectClone;
    }

    private String toJSON(Sobject obj) {
        for (String attribute : fields) {
            jsonObject.putOpt(
                attribute,
                new BracketsJSONObject.value(String.valueOf(obj.get(attribute)))
            );
        }

        return jsonObject.ValuetoString();
    }

    private void assignValue(String key, String value, Sobject obj) {
        Object objValue;
        Schema.Sobjectfield sobjectField;
        Schema.DisplayType sobjectFieldType;
        if (value != null) {
            sobjectField = fieldsSobjectMap.get(key);
            sobjectFieldType = sobjectField.getDescribe().getType();
            if (sobjectFieldType == Schema.DisplayType.Boolean) {
                objValue = Boolean.valueOf(value);
            } else if (
                sobjectFieldType == Schema.DisplayType.Double ||
                sobjectFieldType == Schema.DisplayType.Integer ||
                sobjectFieldType == Schema.DisplayType.Percent ||
                sobjectFieldType == Schema.DisplayType.Currency
            ) {
                objValue = Decimal.valueOf(value);
            } else {
                objValue = String.valueOf(value);
            }
            obj.put(key, objValue);
        }
    }
}
