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

public with sharing class BracketsLeaderboardController {
    public Id groupId { get; set; }

    public List<Brackets_UserTournament__c> getLeaders() {
        List<Brackets_UserTournament__c> leaders = null;

        if (groupId != null) {
            leaders = [
                SELECT
                    Id,
                    User__c,
                    User__r.Name,
                    Tiebreaker_Points__c,
                    Brackets_Tournament__c,
                    Brackets_Tournament__r.Name,
                    Brackets_Group__c,
                    Brackets_Group__r.Name,
                    Points__c,
                    View__c
                FROM Brackets_UserTournament__c
                WHERE Brackets_Group__c = :groupId
                ORDER BY
                    Brackets_Tournament__r.Name ASC,
                    Brackets_Group__r.Name ASC,
                    Points__c DESC
                LIMIT 1000
            ];
        } else {
            leaders = [
                SELECT
                    Id,
                    User__c,
                    User__r.Name,
                    Tiebreaker_Points__c,
                    Brackets_Tournament__c,
                    Brackets_Tournament__r.Name,
                    Brackets_Group__c,
                    Brackets_Group__r.Name,
                    Points__c,
                    View__c
                FROM Brackets_UserTournament__c
                ORDER BY
                    Brackets_Tournament__r.Name ASC,
                    Brackets_Group__r.Name ASC,
                    Points__c DESC
                LIMIT 1000
            ];
        }

        return leaders;
    }
}
