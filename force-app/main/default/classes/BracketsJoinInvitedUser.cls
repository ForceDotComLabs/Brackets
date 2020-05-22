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

public with sharing class BracketsJoinInvitedUser {
    private final String UID = Userinfo.getUserId();
    private final String GID = Apexpages.currentPage()
        .getParameters()
        .get('gId');
    private Brackets_Tournament__c tour = new Brackets_Tournament__c();
    private Brackets_Group__c cGroup = new Brackets_Group__c();
    private Brackets_UserTournament__c uTour = new Brackets_UserTournament__c();
    public Boolean showButtons;

    /**
     * Constructor
     */
    public BracketsJoinInvitedUser() {
    }

    /**
     * Index
     * @return null
     */
    public Pagereference index() {
        if (GID != null && GID != '') {
            List<Brackets_UserTournament__c> cUserTournament = [
                SELECT Id
                FROM Brackets_UserTournament__c
                WHERE Brackets_Group__c = :GID AND User__c = :UID
            ];
            if (cUserTournament.isEmpty()) {
                cGroup = [
                    SELECT Brackets_Tournament__c, Brackets_Tournament__r.Id, Id
                    FROM Brackets_Group__c
                    WHERE Id = :GID
                    LIMIT 1
                ];
                this.tour = cGroup.Brackets_Tournament__r;
                this.showButtons = true;
                return null;
            }
        }
        return this.cancel();
    }

    public Boolean getShowButtons() {
        return this.showButtons;
    }

    /**
     * Join User action
     * @return pageref PageReference
     */
    public Pagereference joinUser() {
        this.uTour.Brackets_Group__c = GID;
        this.uTour.Brackets_Tournament__c = this.tour.Id;
        this.uTour.User__c = UID;
        insert this.uTour;

        //join Chatter.
        /*
		Integer alreadySubscribed = [Select Count() From EntitySubscription Where SubscriberId = :UID and ParentId = :GID];
		
		if (alreadySubscribed == 0) {
			EntitySubscription es = new EntitySubscription();
			System.debug('UID ' + UID);
			System.debug('GID ' + GID);
			es.SubscriberId = UID;
			es.ParentId = GID;
			insert es;
		}
		*/

        return new Pagereference('/apex/BracketsPredictions?show=' + GID);
    }

    /**
     * Return to HomePage
     * @return pageref PageReference
     */
    public Pagereference cancel() {
        return Page.BracketsPools;
    }
}
