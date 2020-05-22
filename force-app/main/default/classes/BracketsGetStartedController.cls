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
public with sharing class BracketsGetStartedController {
    //public final String TOURNAMENT_SOURCE = 'http://free-12415f14c3a-124e539428a-12d5e7eb4ff.force.com/?id=a0MA00000034DNRMA2';
    //public final String TOURNAMENT_SOURCE = 'http://free-12415f14c3a-124e539428a-12d5e7eb4ff.force.com/?id=a0MA00000034OoeMAE';

    //For basketball release
    public final String SAMPLE_SOURCE = 'http://free-12415f14c3a-124e539428a-12d5e7eb4ff.force.com/?id=a06A000000AylgsIAB';
    public final String FULL_SOURCE = 'http://free-12415f14c3a-124e539428a-12d5e7eb4ff.force.com/?id=a06A000000AylunIAB';

    public Boolean isCompleteStep1 { get; set; }
    public Boolean isCompleteStep2 { get; set; }
    public Boolean isError { get; set; }
    public String errorMessage { get; set; }

    public BracketsGetStartedController() {
        isCompleteStep1 = false;
        isCompleteStep2 = false;
        isError = false;

        BracketsSettingsPersonal__c settings = BracketsSettingsPersonal__c.getOrgDefaults();
        if (settings != null && settings.Initial_Setup_Complete__c) {
            //this.isError = true;
            //this.errorMessage = 'Initial setup is already complete.';
            this.isCompleteStep1 = true;
        }

        if (settings != null && settings.Initial_Setup_Step_2_Complete__c) {
            this.isCompleteStep2 = true;
        }
    }

    public void getStarted() {
        BracketsSettingsPersonal__c settings = BracketsSettingsPersonal__c.getOrgDefaults();
        if (settings != null && settings.Initial_Setup_Complete__c) {
            this.isError = true;
            this.errorMessage = 'Initial setup is already complete.';
            this.isCompleteStep1 = true;
            return;
        }

        try {
            handleGetStarted(SAMPLE_SOURCE);

            //create settings
            settings = BracketsSettingsPersonal__c.getOrgDefaults();
            if (settings == null) {
                settings = new BracketsSettingsPersonal__c();
            }
            settings.Initial_Setup_Complete__c = true;
            upsert settings;

            this.isCompleteStep1 = true;
        } catch (Exception e) {
            this.isError = true;
            this.isCompleteStep1 = false;
            this.errorMessage =
                'Unable to complete installation [BracketsGetStartedController]: ' +
                e.getMessage();
        }
    }

    public void handleGetStarted(String targetURL) {
        //Baseline tournaments in case this is a re-rerun
        //List<Brackets_Tournament__c> baselineTournaments = [Select Id, Name From Brackets_Tournament__c Limit ];

        //import a tournament
        BracketsProccessUpdate processUpdate = new BracketsProccessUpdate(
            targetURL
        );

        //new tournament
        Brackets_Tournament__c importedTournament = [
            SELECT Id, Name
            FROM Brackets_Tournament__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        //based on the imported tournament, create a pool
        Brackets_Group__c newGroup = new Brackets_Group__c();
        newGroup.Brackets_Tournament__c = importedTournament.id;
        newGroup.Type__c = BracketsGroupUtilities.BET_TYPE_FULL_TOURNAMENT;
        newGroup.Name = importedTournament.Name + ' [Full]';
        insert newGroup;

        //join the current user to that pool
        Brackets_UserTournament__c userTour = new Brackets_UserTournament__c();
        userTour.Brackets_Tournament__c = importedTournament.id;
        userTour.Brackets_Group__c = newGroup.id;
        userTour.User__c = Userinfo.getUserId();
        insert userTour;

        //based on the imported tournament, create a pool
        Brackets_Group__c newGroup2 = new Brackets_Group__c();
        newGroup2.Brackets_Tournament__c = importedTournament.id;
        newGroup2.Type__c = BracketsGroupUtilities.BET_TYPE_BY_ROUND;
        newGroup2.Name = importedTournament.Name + ' [Round]';
        insert newGroup2;

        //join the current user to that pool
        Brackets_UserTournament__c userTour2 = new Brackets_UserTournament__c();
        userTour2.Brackets_Tournament__c = importedTournament.id;
        userTour2.Brackets_Group__c = newGroup2.id;
        userTour2.User__c = Userinfo.getUserId();
        insert userTour2;
    }
    public void getStartedStep2() {
        BracketsSettingsPersonal__c settings = BracketsSettingsPersonal__c.getOrgDefaults();
        if (settings != null && settings.Initial_Setup_Step_2_Complete__c) {
            this.isError = true;
            this.errorMessage = 'Initial setup 2 is already complete.';
            this.isCompleteStep2 = true;
            return;
        }

        try {
            handleGetStarted(FULL_SOURCE);

            //create settings
            settings = BracketsSettingsPersonal__c.getOrgDefaults();
            if (settings == null) {
                settings = new BracketsSettingsPersonal__c();
            }
            settings.Initial_Setup_Step_2_Complete__c = true;
            upsert settings;

            this.isCompleteStep2 = true;
        } catch (Exception e) {
            System.debug('Yes I found the error');
            this.isError = true;
            this.isCompleteStep1 = false;
            this.isCompleteStep2 = false;
            this.errorMessage =
                'Unable to complete installation [BracketsGetStartedController]: ' +
                e.getMessage();
        }
    }
}
