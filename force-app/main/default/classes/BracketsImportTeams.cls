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
public with sharing class BracketsImportTeams {
    private List<Brackets_Team__c> teamList { get; set; }

    /**
     * Constructor
     */
    public BracketsImportTeams() {
    }

    /**
     * Method in charge of retrieving and compiling the data from imported file,
     * for then inserting into the system.
     * @param xml
     */
    public void processImportedDocument(String xml) {
        this.teamList = new List<Brackets_Team__c>();

        try {
            this.readingTeamData(xml);
            System.debug(LoggingLevel.Info, '12345:' + this.teamList);
            upsert this.teamList ExternalId__c;
        } catch (Exception ex) {
            throw new BracketsException(
                'Error Importing your Tournament Template [BracketsImportTeams] ' +
                ex.getMessage(),
                ex
            );
        }
    }

    /**
     * Method in charge of retrieving and compiling the Team data from imported file,
     * for then inserting into the system.
     * @param xml
     */
    private void readingTeamData(String xml) {
        Xmlstreamreader reader = new Xmlstreamreader(xml);

        while (reader.hasNext()) {
            if (
                reader.getEventType() == XmlTag.START_ELEMENT &&
                reader.getLocalName() == 'Team'
            ) {
                this.parseTeamData(reader);
            }
            if (
                reader.getEventType() == XmlTag.END_ELEMENT &&
                reader.getLocalName() == 'Teams'
            ) {
                break;
            }
            reader.next();
        }
    }

    /**
     * Method in charge of parsing Team data from XMl document
     * @param reader
     * @return correctMetaData
     */
    private void parseTeamData(Xmlstreamreader reader) {
        Brackets_Team__c team = new Brackets_Team__c();

        while (reader.hasNext()) {
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'name'
            ) {
                reader.next();
                team.Name = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                //RSC - replaced using "ID" below.
                //team.ExternalId__c 	= team.Name;
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'shortname'
            ) {
                reader.next();
                team.ShortName__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                team.ShortName__c = (team.ShortName__c.equalsIgnoreCase('null'))
                    ? null
                    : team.ShortName__c;
            }

            //RSC added
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'id'
            ) {
                reader.next();
                team.ExternalId__c = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
            }

            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'description'
            ) {
                reader.next();
                String descValue = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (descValue == 'null') {
                    team.Description__c = '';
                } else {
                    team.Description__c = descValue;
                }
            }
            if (
                reader.getEventType() == XMLTag.START_ELEMENT &&
                reader.getLocalName() == 'rank'
            ) {
                reader.next();
                String value = BracketsImportExportUtilities.getDecodedString(
                    reader
                );
                if (value == 'null') {
                    team.Rank__c = null;
                } else {
                    team.Rank__c = team.Rank__c = Decimal.valueOf(value);
                }
            }
            //Validate end of tag
            if (
                reader.getEventType() == XMLTag.END_ELEMENT &&
                reader.getLocalName() == 'Team'
            ) {
                break;
            }

            reader.next();
        }

        this.teamList.add(team);
    }
}
