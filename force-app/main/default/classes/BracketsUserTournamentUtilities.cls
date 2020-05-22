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

public with sharing class BracketsUserTournamentUtilities {
    public static String userTournamentAlreadyRegisteredError = 'You were already registered to this tournament.';

    /**
     * 	Given a user id returns all the matche predictions of him.
     *
     *	@param user		user to obtain the info.
     *	@return 		a list of user tournaments.
     */
    public static List<Brackets_UserTournament__c> getUserTournamentsFromUser(
        Id user
    ) {
        List<Brackets_UserTournament__c> userTournamentList = new List<Brackets_UserTournament__c>();
        Map<Id, Brackets_UserTournament__c> userTournamentMap = new Map<Id, Brackets_UserTournament__c>();
        for (Brackets_UserTournament__c userTournament : [
            SELECT
                Id,
                Brackets_Tournament__r.Id,
                Brackets_Tournament__r.Name,
                Brackets_Group__c,
                Brackets_Tournament__c,
                User__c
            FROM Brackets_UserTournament__c
            WHERE user__c = :user
        ]) {
            userTournamentMap.put(
                userTournament.Brackets_Tournament__r.Id,
                userTournament
            );
        }
        for (String id : userTournamentMap.keySet()) {
            userTournamentList.add(userTournamentMap.get(id));
        }
        return userTournamentList;
    }

    /**
     * 	Given a user id returns all the matche predictions of him.
     *
     *	@param tournamentId tournament id
     *	@param groupId		group id
     *	@param userId		user to obtain the info.
     *	@return 			a list of user tournaments.
     */
    public static List<Brackets_UserTournament__c> getUserTournaments(
        Id tournamentId,
        Id groupId,
        Id userId
    ) {
        return [
            SELECT Id, Name, Brackets_Group__c, Brackets_Tournament__c, User__c
            FROM Brackets_UserTournament__c
            WHERE
                Brackets_Group__c = :groupId
                AND Brackets_Tournament__c = :tournamentId
                AND User__c = :userId
        ];
    }

    /**
     * 	Save a list of user tournaments
     *
     *	@param userTournamentList	 a list of user tournament
     */
    public static void save(
        List<Brackets_UserTournament__c> userTournamentList
    ) {
        List<Brackets_UserTournament__c> userTournamentListToSave = new List<Brackets_UserTournament__c>();
        try {
            for (
                Brackets_UserTournament__c userTournament : userTournamentList
            ) {
                if (userTournament.Brackets_Group__c != null) {
                    userTournamentListToSave.add(userTournament);
                }
            }
            Database.upsert(userTournamentListToSave, false);

            suscribe(userTournamentListToSave);
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     *	Check existing joined to tournaments
     *
     * 	@param userTournamentList	a list of usertournament sobject to join tournamento to groups
     */
    public static void checkJoinedTournaments(
        List<Brackets_UserTournament__c> userTournamentNewList
    ) {
        Boolean isAlreadyJoined = false;
        List<Id> groupIds = new List<Id>();
        List<Id> tournamentIds = new List<Id>();
        for (
            Brackets_UserTournament__c userTournamentNew : userTournamentNewList
        ) {
            groupIds.add(userTournamentNew.Brackets_Group__c);
            tournamentIds.add(userTournamentNew.Brackets_Tournament__c);
        }

        for (Brackets_UserTournament__c userTournament : [
            SELECT
                Id,
                Brackets_Group__c,
                Brackets_Group__r.Name,
                Brackets_Tournament__c,
                User__c
            FROM Brackets_UserTournament__c
            WHERE
                Brackets_Tournament__c IN :tournamentIds
                AND Brackets_Group__c IN :groupIds
        ]) {
            for (
                Brackets_UserTournament__c userTournamentNew : userTournamentNewList
            ) {
                isAlreadyJoined =
                    userTournament.Id != userTournamentNew.Id &&
                    userTournament.Brackets_Tournament__c ==
                    userTournamentNew.Brackets_Tournament__c &&
                    userTournament.Brackets_Group__c ==
                    userTournamentNew.Brackets_Group__c &&
                    userTournament.User__c == userTournamentNew.User__c;
                if (isAlreadyJoined) {
                    userTournamentNew.Brackets_Group__c.addError(
                        'You can\'t join again.'
                    );
                    break;
                }
            }
        }
    }

    /**
     * Enter a EntitySubcription
     */
    public static void userSuscribe(
        List<Brackets_UserTournament__c> utNewList
    ) {
        try {
            List<EntitySubscription> entSusc = new List<EntitySubscription>();
            for (Brackets_UserTournament__c ut : utNewList) {
                EntitySubscription ents = new EntitySubscription();
                ents.ParentId = ut.Brackets_Group__c;
                ents.SubscriberId = Userinfo.getUserId();
                entSusc.add(ents);
            }
            upsert entSusc;
        } catch (Exception e) {
        }
    }

    /**
     *	Given a list of usertournament, create the necessary suscription to follow to its corresponding
     *	group.
     *
     *	@param userTournamentList	 a list of usertournament sobject.
     */
    private static void suscribe(
        List<Brackets_UserTournament__c> userTournamentList
    ) {
        List<EntitySubscription> entitySuscriptionsList = new List<EntitySubscription>();
        EntitySubscription entitySubscription;
        for (Brackets_UserTournament__c userTournament : userTournamentList) {
            if (userTournament.Id != null) {
                entitySubscription = new EntitySubscription();
                entitySubscription.ParentId = userTournament.Brackets_Group__c;
                entitySubscription.SubscriberId = userTournament.User__c;
                entitySuscriptionsList.add(entitySubscription);
            }
        }
        if (!entitySuscriptionsList.isEmpty()) {
            try {
                Database.insert(entitySuscriptionsList, false);
            } catch (Exception e) {
                //if this part of the code some subscriptions were already done.
            }
        }
    }
}
