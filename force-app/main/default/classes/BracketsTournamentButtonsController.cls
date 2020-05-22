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

public with sharing class BracketsTournamentButtonsController {
    private List<Sobject> siteList { get; set; }
    public Brackets_Tournament__c myTournament { get; set; }
    public String tId { get; set; }
    public String ShareUrl { get; set; }
    public Boolean showUpdateButton { get; set; }
    public Boolean showPublishButton { get; set; }
    public Boolean publishHasErrors { get; set; }
    public String subDomain { get; set; }
    public String domain { get; set; }
    public String urlParam { get; set; }
    public String finalUrl { get; set; }
    public String xmlMessage { get; set; }
    Map<Id, Brackets_Match__c> matches;

    public BracketsTournamentButtonsController(
        Apexpages.StandardController stdController
    ) {
        this.tId = (Id) stdController.getId();
        this.index();
    }

    /**
     * Dummy Method
     */
    public void index() {
        this.myTournament = this.getTournament();
        this.showPublishButton = (!this.myTournament.Allow_Update__c &&
        !this.myTournament.isChild__c);
        this.showUpdateButton = (this.myTournament.isChild__c &&
        this.myTournament.Update_Source__c != '');
        this.siteList = this.getMySite();
        this.domain = (this.siteList.size() > 0)
            ? String.valueOf(this.siteList.get(0).get('Subdomain'))
            : '';
        this.finalUrl = this.myTournament.Update_Source__c;
        this.matches = new Map<Id, Brackets_Match__c>(
            [
                SELECT
                    Id,
                    HomeBrackets_Team__c,
                    VisitorBrackets_Team__c,
                    FollowingBrackets_Match__c
                FROM Brackets_Match__c
                WHERE
                    Brackets_Round__r.Brackets_Tournament__c = :this.myTournament.Id
            ]
        );
    }

    /**
     * Check if the current Tournament can be Published checking First Leven Complete
     * Cannot publish. All starting matches much be complete before publishing.
     * @return canPublish
     */
    public Boolean getCanPublish() {
        // Cannot publish. All starting matches much be complete before publishing. Check your matches and start again.
        try {
            BracketsMatchUtilities.checkFirstLevelCompleted(
                this.myTournament,
                this.matches
            );
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Getter of ShowUrlSelection, establish if the Url section need be showed
     * @return siteList size
     */
    public Boolean getShowUrlSelection() {
        return (!this.siteList.isEmpty() &&
        this.myTournament.Update_Source__c == null);
    }

    /**
     * Getter of ShowCreateSiteMsg
     * @return siteList is Empty
     */
    public Boolean getShowCreateSiteMsg() {
        return this.siteList.isEmpty();
    }

    /**
     * Return the selected Tournament
     * @return : tournament
     */
    private Brackets_Tournament__c getTournament() {
        return [
            SELECT
                t.isChild__c,
                t.Version__c,
                t.Update_Source__c,
                t.Allow_Update__c
            FROM Brackets_Tournament__c t
            WHERE t.Id = :this.tId
        ];
    }

    /**
     * Get Site parameters and return it
     * return Select;
     */
    public List<Sobject> getMySite() {
        List<Sobject> sites = new List<Sobject>();
        if (Schema.getGlobalDescribe().get('Site') != null) {
            sites = Database.query(
                'Select Id, Name, Subdomain, UrlPathPrefix from Site limit 20'
            );
        }
        return sites;
    }

    /**
     * Get all SIte Folders
     * return options;
     */
    public List<SelectOption> getUrlPathPrefix() {
        Object urlPathPrefixObject;
        String urlPathPrefixValue;
        List<SelectOption> options = new List<SelectOption>();
        for (Sobject s : this.siteList) {
            urlPathPrefixObject = s.get('UrlPathPrefix');
            if (urlPathPrefixObject != null) {
                urlPathPrefixValue = String.valueOf(urlPathPrefixObject);
                options.add(
                    new SelectOption(
                        urlPathPrefixValue + '/',
                        urlPathPrefixValue
                    )
                );
            }
        }
        return options;
    }

    public String getSitePath() {
        for (Sobject s : this.siteList) {
            return String.valueOf(s.get('UrlPathPrefix'));
        }
        return null;
    }

    /**
     * Get selected site and save it into related Tournament
     */
    public void saveUrl() {
        if (this.getUrlPathPrefix().size() == 1) {
            this.finalUrl =
                this.urlParam +
                this.getSitePath() +
                '?id=' +
                this.myTournament.Id;
        } else {
            this.subDomain = (this.subDomain != null) ? this.subDomain : '';
            this.finalUrl =
                this.urlParam +
                this.subDomain +
                '?id=' +
                this.myTournament.Id;
        }

        this.myTournament.Update_Source__c = this.finalUrl;
        update this.myTournament;
        this.index();
    }

    /**
     * Execute Manual Update
     */
    public void doManualUpdate() {
        try {
            new BracketsProccessUpdate(this.myTournament.Id);
            this.index();
            this.xmlMessage = 'Tournament has been updated!';
        } catch (Exception ex) {
            this.xmlMessage = ex.getMessage();
        }
    }

    /**
     * Publish tournament
     */
    public void publish2() {
        try {
            myTournament.Allow_Update__c = true;
            myTournament.Version__c++;

            update this.myTournament;
            this.showPublishButton = false;
            this.xmlMessage = 'Tournament has been published!!!';
        } catch (Exception e) {
            this.publishHasErrors = true;
            this.xmlMessage = 'Error : ' + e.getMessage();
        }
    }
}
