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

public with sharing class BracketsPoolController {
    public List<GroupWrap> groups { get; set; }
    public static Boolean showInvite { get; set; }

    public BracketsPoolController() {
        this.groups = new List<GroupWrap>();
        for (
            Brackets_Group__c groupy : BracketsGroupUtilities.getGroups(
                Userinfo.getUserId()
            )
        ) {
            this.groups.add(new GroupWrap(groupy));
        }
    }

    public class GroupWrap {
        public Boolean hasUserTournaments { get; set; }
        public Brackets_Group__c groupp { get; set; }
        public URLLink link { get; set; }

        public GroupWrap(Brackets_Group__c groupp) {
            this.groupp = groupp;
            this.link = null;
            hasUserTournaments = BracketsGroupUtilities.hasUserTournament(
                this.groupp
            );

            if (this.groupp.Status__c != 'Closed') {
                if (hasUserTournaments) {
                    this.link = new URLLink(
                        'Manage',
                        'BracketsMatchesPrediction?show=' + groupp.Id
                    );
                } else {
                    //refactoring
                    this.link = new URLLink('Click Here to Join', '');
                }
            }
        }

        public String getStatus() {
            String resultStatus;
            if (hasUserTournaments) {
                resultStatus = 'Joined';
            } else {
                resultStatus = this.groupp.Status__c;
            }
            return resultStatus;
        }
    }

    public Boolean getCanCreate() {
        return BracketsPoolController.checkObjectCrud('Brackets_Group__c');
    }

    /**
     * Check over object if the loged User has rights
     * @parms sObject
     * @return Boolean
     */
    public static Boolean checkObjectCrud(String objName) {
        Schema.DescribeSObjectResult oResult = Schema.getGlobalDescribe()
            .get(objName)
            .getDescribe();
        return oResult.isCreateable();
    }

    public PageReference createNewPool() {
        return new PageReference(
            '/' +
            Schema.Brackets_Group__c.SObjectType.getDescribe().getKeyPrefix() +
            '/e'
        );
    }

    public class URLLink {
        public String name { get; set; }
        public String value { get; set; }
        public URLLink(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }
}
