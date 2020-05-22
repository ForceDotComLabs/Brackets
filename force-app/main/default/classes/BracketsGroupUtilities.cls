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
public with sharing class BracketsGroupUtilities {
    public static final String BET_TYPE_BY_ROUND = 'Round By Round';
    public static final String BET_TYPE_FULL_TOURNAMENT = 'Full Tournament';

    /**
     * Return a list of groups for each tournament
     *
     * @param tournaments List of tournamntes
     * @param userd       User (if not null, then filter by user too)
     */
    public static Map<Id, List<Brackets_Group__c>> getGroups(
        List<Id> tournaments,
        Id userid
    ) {
        Map<Id, List<Brackets_Group__c>> mapOfListGroup = new Map<Id, List<Brackets_Group__c>>();
        List<Brackets_Group__c> listOfGroup;
        List<Brackets_Group__c> groupsByTournament;

        // Select groups
        if (userid != null) {
            groupsByTournament = [
                SELECT Id, Name, Brackets_Tournament__c
                FROM Brackets_Group__c
                WHERE
                    Id IN (
                        SELECT ut.Brackets_Group__c
                        FROM Brackets_UserTournament__c ut
                        WHERE
                            ut.User__c = :userid
                            AND ut.Brackets_Tournament__c IN :tournaments
                    )
            ];
        } else {
            groupsByTournament = [
                SELECT Id, Name, Brackets_Tournament__c
                FROM Brackets_Group__c
                WHERE Brackets_Tournament__c IN :tournaments
            ];
        }

        // Process data in a list of tournaments by group
        for (Brackets_Group__c groupy : groupsByTournament) {
            for (Id tournamentId : tournaments) {
                if (groupy.Brackets_Tournament__c == tournamentId) {
                    listOfGroup = mapOfListGroup.get(tournamentId);
                    if (listOfGroup == null) {
                        listOfGroup = new List<Brackets_Group__c>();
                        mapOfListGroup.put(tournamentId, listOfGroup);
                    }
                    listOfGroup.add(groupy);
                }
            }
        }

        return mapOfListGroup;
    }

    public static List<Brackets_Group__c> getGroups(Id tournament, Id userid) {
        List<Id> groups = new List<Id>();
        groups.add(tournament);
        return getGroups(groups, userid).get(tournament);
    }

    public static List<Brackets_Group__c> getGroups(Id userId) {
        return [
            SELECT
                Id,
                Name,
                Brackets_Tournament__c,
                NumOfMembers__c,
                Status__c,
                Type__c,
                (SELECT Id FROM g.UserTornaments__r WHERE User__c = :userId)
            FROM Brackets_Group__c g
            LIMIT :Limits.getLimitQueryRows()
        ];
    }

    public static Boolean hasUserTournament(Brackets_Group__c groupp) {
        return groupp.UserTornaments__r.size() > 0;
    }

    public static void deleteGroups(List<Brackets_Tournament__c> tournaments) {
        List<Id> tournamentsId = new List<Id>();
        for (Brackets_Tournament__c tournament : tournaments) {
            tournamentsId.add(tournament.Id);
        }
        delete [
            SELECT Id
            FROM Brackets_Group__c
            WHERE Brackets_Tournament__c IN :tournamentsId
        ];
    }
}
