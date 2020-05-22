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

public with sharing class BracketsTriggerUtilities {
    //Brackets_Match__c
    public static List<Brackets_Match__c> triggerMatchList = new List<Brackets_Match__c>();
    public static Map<Id, Brackets_Match__c> triggerMatchMap = new Map<Id, Brackets_Match__c>();
    public static List<Id> triggerMatchIds = new List<Id>();
    public static Map<Id, Brackets_Match__c> triggerListObject = new Map<Id, Brackets_Match__c>();

    //Brackets_Round__c
    public static List<Brackets_Round__c> triggerRoundList = new List<Brackets_Round__c>();
    public static Map<Id, Brackets_Round__c> triggerRoundMap = new Map<Id, Brackets_Round__c>();
    public static List<Id> triggerRoundIds = new List<Id>();
    public static Map<Id, Brackets_Round__c> triggerRoundObject = new Map<Id, Brackets_Round__c>();

    //Brackets_Tournament__c
    public static List<Brackets_Tournament__c> triggerTournamentList = new List<Brackets_Tournament__c>();
    public static Map<Id, Brackets_Tournament__c> triggerTournamentMap = new Map<Id, Brackets_Tournament__c>();
    public static List<Id> triggerTournamentIds = new List<Id>();
    public static Map<Id, Brackets_Tournament__c> triggerTournamentObject = new Map<Id, Brackets_Tournament__c>();

    /**
     * Populate all list if are not yet.
     * @params matchList : Get the list of current Matchs
     */
    public static void newTriggerInstance(List<Brackets_Match__c> matchList) {
        if (
            BracketsTriggerUtilities.triggerTournamentList.isEmpty() &&
            !matchList.isEmpty()
        ) {
            List<Id> auxMatch = new List<Id>();
            String auxTourId;
            for (Brackets_Match__c mi : matchList) {
                auxMatch.add(mi.Id);
            }
            for (Brackets_Match__c t : [
                SELECT Brackets_Round__r.Brackets_Tournament__c
                FROM Brackets_Match__c
                WHERE Id IN :auxMatch
            ]) {
                auxTourId = t.Brackets_Round__r.Brackets_Tournament__c;
                break;
            }

            for (Brackets_Tournament__c t : [
                SELECT
                    t.isChild__c,
                    t.Version__c,
                    t.Update_Source__c,
                    t.Type__c,
                    t.TeamCount__c,
                    t.Start__c,
                    t.Allow_Update__c,
                    t.Name,
                    t.MaxRoundNumber__c,
                    t.Id,
                    t.ExternalId__c,
                    t.End__c,
                    t.Description__c,
                    t.CronTrigger__c,
                    (
                        SELECT
                            Id,
                            Name,
                            Deadline__c,
                            ExternalId__c,
                            RoundNumber__c,
                            ScorePoints__c,
                            End__c,
                            MinScheduleBrackets_Match__c,
                            Start__c,
                            Brackets_Tournament__c
                        FROM Rounds__r
                    )
                FROM Brackets_Tournament__c t
                WHERE t.Id = :auxTourId
            ]) {
                //-------- Populate the Different List and Maps  -----------------//

                //Tournament
                BracketsTriggerUtilities.triggerTournamentList.add(t);
                BracketsTriggerUtilities.triggerTournamentMap.put(t.Id, t);
                BracketsTriggerUtilities.triggerTournamentIds.add(t.Id);

                //Rounds
                for (Brackets_Round__c r : t.Rounds__r) {
                    BracketsTriggerUtilities.triggerRoundList.add(r);
                    BracketsTriggerUtilities.triggerRoundIds.add(r.Id);
                    BracketsTriggerUtilities.triggerRoundMap.put(r.Id, r);
                }
            } //EndFor

            //Populate Brackets_Match__c with all matches for this tournament
            for (Brackets_Match__c m : [
                SELECT
                    m.WinnerBrackets_Team__c,
                    m.VisitorBrackets_Team__c,
                    m.VisitorScore__c,
                    m.Schedule__c,
                    m.Brackets_Round__c,
                    m.Position__c,
                    m.Name,
                    m.Id,
                    m.HomeBrackets_Team__c,
                    m.HomeScore__c,
                    m.FollowingBrackets_Match__c,
                    m.FollowingIsHome__c,
                    m.ExternalId__c,
                    m.Description__c,
                    m.Conference__c
                FROM Brackets_Match__c m
                WHERE
                    m.Brackets_Round__c IN :BracketsTriggerUtilities.triggerRoundIds
            ]) {
                //-------- Populate Match List and Maps  -----------------//
                BracketsTriggerUtilities.triggerMatchList.add(m);
                BracketsTriggerUtilities.triggerMatchIds.add(m.Id);
                BracketsTriggerUtilities.triggerMatchMap.put(m.Id, m);
            }
        } //EndIf
    }
}
