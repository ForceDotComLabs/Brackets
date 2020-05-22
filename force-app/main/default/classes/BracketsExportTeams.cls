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
public with sharing class BracketsExportTeams {
    private String tournamentId { get; set; }
    public Xmlstreamwriter out { get; set; }

    /**
     * Constructor
     * @param tourId
     * @param writer
     */
    public BracketsExportTeams(String tourId, Xmlstreamwriter writer) {
        this.tournamentId = tourId;
        this.out = writer;
    }

    /**
     * Method in charge of handling the export task related
     * @return Xmlstreamwriter
     */
    public Xmlstreamwriter BracketsexportTeams() {
        List<Brackets_Match__c> matches = [
            SELECT
                m.VisitorBrackets_Team__c,
                m.Brackets_Round__r.Brackets_Tournament__c,
                m.Brackets_Round__c,
                m.Name,
                m.Id,
                m.HomeBrackets_Team__c
            FROM Brackets_Match__c m
            WHERE
                m.Brackets_Round__r.Brackets_Tournament__c = :this.tournamentId
        ];

        Set<ID> teamIds = new Set<ID>();
        for (Brackets_Match__c match : matches) {
            teamIds.add(match.HomeBrackets_Team__c);
            teamIds.add(match.VisitorBrackets_Team__c);
        }

        List<Brackets_Team__c> teams = [
            SELECT Id, Name, ShortName__c, Description__c, Rank__c
            FROM Brackets_Team__c
            WHERE Id IN :teamIds
        ];

        this.buildXmlString(teams);

        return this.out;
    }

    /**
     * Method in charge of compiling XML document with Team Information
     * @param teamList
     */
    public void buildXmlString(List<Brackets_Team__c> teamList) {
        this.out.writeStartElement(null, 'Teams', null);

        for (Brackets_Team__c team : teamList) {
            this.out.writeStartElement(null, 'Team', null);

            BracketsImportExportUtilities.writeElement(
                this.out,
                'id',
                '' + team.Id
            );
            BracketsImportExportUtilities.writeElement(
                this.out,
                'name',
                '' + team.Name
            );
            BracketsImportExportUtilities.writeElement(
                this.out,
                'description',
                '' + team.Description__c
            );
            BracketsImportExportUtilities.writeElement(
                this.out,
                'rank',
                '' + team.Rank__c
            );
            BracketsImportExportUtilities.writeElement(
                this.out,
                'shortname',
                '' + team.ShortName__c
            );

            this.out.writeEndElement();
        }

        this.out.writeEndElement();
    }
}
