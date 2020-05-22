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

public with sharing class BracketsPredictionsController {
    public Boolean showTree { get; set; }
    public String singleRound { get; set; }
    public String targetPool { get; set; }
    public Brackets_UserTournament__c target { get; set; }

    public String json { get; set; }
    public String message { get; set; }
    public String messageType { get; set; }

    public Boolean hideDialog { get; set; }

    //pool type --
    public Boolean isFullTournament { get; set; }

    //might be locked for any number of reasons
    public Boolean isLocked { get; set; }

    //useful for both full tournament and round by round pools
    public Datetime nextDeadline { get; set; }
    public String formattedNextDeadline { get; set; }

    //for round by round pools, it indicates the active round
    public Integer activeRound { get; set; }

    //for viewing another person's predictions
    public Id targetUserTournament { get; set; }
    public String userTournamentUser { get; set; }

    /**
     *   Constructor
     */
    public BracketsPredictionsController() {
        targetPool = Apexpages.currentPage().getParameters().get('show');
        if (targetPool == null) {
            targetUserTournament = Apexpages.currentPage()
                .getParameters()
                .get('view');
        }
        showTree = false;
        List<Brackets_UserTournament__c> userTournaments = this.userJoinedPools();
        this.singleRound = null;
        if (userTournaments.size() == 1) {
            target = userTournaments.get(0);
            targetPool = target.Brackets_Group__c;
            this.singleRound = target.Brackets_Group__c;
            initNextDeadline();
            if (targetUserTournament == null) {
                BracketsSettings2__c settings = BracketsSettings2__c.getInstance(
                    UserInfo.getUserId()
                );
                if (settings != null) {
                    hideDialog = settings.Hide_Help_Dialog__c;
                }
                showTree = true;
            } else {
                if (this.isLocked) {
                    showTree = true;
                } else {
                    this.message = 'Cannot view a prediction tree before the deadline.';
                    showTree = false;
                }
                this.userTournamentUser = target.User__r.Name;
                hideDialog = true;
            }
        }
    }

    public PageReference goToPoolList() {
        return Page.BracketsPools;
    }

    public PageReference gotoPoolDetail() {
        return new ApexPages.Pagereference('/' + targetPool);
    }

    /**
     * Get the User joined Pools
     * @return UserTournament List
     */
    public List<Brackets_UserTournament__c> userJoinedPools() {
        List<Brackets_UserTournament__c> userTournaments = null;

        if (targetPool == null && targetUserTournament == null) {
            userTournaments = [
                SELECT
                    Id,
                    Brackets_Group__c,
                    Brackets_Group__r.TournamentType__c,
                    Brackets_Group__r.Name,
                    Brackets_Group__r.Type__c,
                    Brackets_Tournament__r.Name,
                    Brackets_Tournament__r.Deadline__c,
                    Championship_Point_Prediction__c
                FROM Brackets_UserTournament__c
                WHERE User__c = :Userinfo.getUserId()
            ];
        } else if (targetUserTournament != null && targetPool == null) {
            userTournaments = [
                SELECT
                    Id,
                    Brackets_Group__c,
                    Brackets_Group__r.TournamentType__c,
                    Brackets_Group__r.Name,
                    Brackets_Group__r.Type__c,
                    Brackets_Tournament__r.Name,
                    Brackets_Tournament__r.Deadline__c,
                    User__r.Name,
                    Championship_Point_Prediction__c
                FROM Brackets_UserTournament__c
                WHERE Id = :targetUserTournament
            ];
        } else {
            userTournaments = [
                SELECT
                    Id,
                    Brackets_Group__c,
                    Brackets_Group__r.TournamentType__c,
                    Brackets_Group__r.Name,
                    Brackets_Group__r.Type__c,
                    Brackets_Tournament__r.Name,
                    Brackets_Tournament__r.Deadline__c,
                    Championship_Point_Prediction__c
                FROM Brackets_UserTournament__c
                WHERE
                    Brackets_Group__c = :targetPool
                    AND User__c = :Userinfo.getUserId()
            ];
        }

        return userTournaments;
    }

    /**
     * Parse string and save predictions
     */

    public PageReference saveAllPred() {
        PageReference page = null;

        if (!isLocked) {
            try {
                if (this.json.length() > 0) {
                    BracketsMatchesPredictionUtil.saveFromJSON(
                        this.json,
                        Userinfo.getUserId()
                    );
                }
                System.debug('12345' + target);
                update target;
                //init();
                this.message = 'All your predictions has been saved successfully!!';
                this.messageType = 'success';
                page = new PageReference(
                    '/apex/BracketsMatchesPrediction?show=' + this.targetPool
                );
                page.setRedirect(true);
            } catch (Exception e) {
                System.debug('exception1:' + e);
                this.message = e.getMessage();
                this.messageType = 'error';
            }
        } else {
            this.messageType = 'locked';
            this.message = 'Predictions are currently locked.';
        }

        updateHideDialog();

        return null;
        //return page;
    }

    public void initNextDeadline() {
        isLocked = false;

        if (
            target.Brackets_Group__r.Type__c ==
            BracketsGroupUtilities.BET_TYPE_FULL_TOURNAMENT
        ) {
            isFullTournament = true;
            nextDeadline = target.Brackets_Tournament__r.Deadline__c;
            if (nextDeadline < Datetime.now()) {
                isLocked = true;
            }
        } else {
            //figure out the next deadline based on
            isFullTournament = false;
            List<Brackets_Round__c> rounds = [
                SELECT Id, Name, Deadline__c, RoundNumber__c
                FROM Brackets_Round__c
                WHERE
                    Brackets_Tournament__c = :target.Brackets_Tournament__c
                    AND Deadline__c > :Datetime.now()
                LIMIT 1
            ];
            if (rounds.size() == 0) {
                isLocked = true;
            } else {
                Brackets_Round__c r = rounds.get(0);
                nextDeadline = r.Deadline__c;
                activeRound = Integer.valueOf('' + r.RoundNumber__c);
            }
        }

        //we should have a deadline and if we don't that's problematic
        if (!isLocked && nextDeadline == null) {
            throw new BracketsException(
                'Unable to initialize the next deadline.  For Full Tournament pools, this is on the Tournament Object.  For Round By Round pools, this is on the individual Round.'
            );
        }

        if (isLocked) {
            formattedNextDeadline = 'Locked';
        } else {
            //get the current users' timezone setting
            User current = [
                SELECT Id, TimeZoneSidKey
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            //now make sure the deadline is in the current users' Z
            formattedNextDeadline = nextDeadline.format(
                'EEE, d MMM yyyy HH:mm a',
                current.TimeZoneSidKey
            );
        }
    }

    public void updateHideDialog() {
        System.debug('Update Hide Dialog' + this.hideDialog);

        if (this.hideDialog == null) {
            this.hideDialog = false;
        }

        BracketsSettings2__c settings = BracketsSettings2__c.getInstance(
            UserInfo.getUserId()
        );
        if (settings == null) {
            settings = new BracketsSettings2__c();
            settings.Name = UserInfo.getUserId();
        }
        settings.Hide_Help_Dialog__c = this.hideDialog;
        upsert settings;
    }

    public String getLastChatterUpdate() {
        String ret = new BracketsFeedItemUtility()
            .getLastTournamentGroupChatter(target.Brackets_Group__c, 75);

        if (ret == '') {
            ret = 'No updates yet - be the first!';
        }
        return ret;
    }
}
