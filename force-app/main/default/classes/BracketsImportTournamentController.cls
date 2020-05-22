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

public with sharing class BracketsImportTournamentController {
    public String statusText { get; set; }
    public String sourceUrl { get; set; }
    public String xmlMessage { get; set; }

    /**
     * Process URL and Import all Tournament
     * @return page
     */
    public PageReference importTournament() {
        if (
            this.sourceUrl == null ||
            this.sourceUrl == '' ||
            !this.sourceUrl.toLowerCase().startsWith('http')
        ) {
            xmlMessage = 'You must enter a valid URL.';
            return null;
        }

        try {
            new BracketsProccessUpdate(this.sourceUrl);
            xmlMessage = BracketsImportExportUtilities.SUCCESSFUL_TOURNAMENT_IMPORT;
        } catch (Exception ex) {
            this.xmlMessage = ex.getMessage();
        }
        return null;
    }

    /**
     * Get a list of tournaments
     * @return tList
     */
    public List<Brackets_Tournament__c> getTList() {
        return [
            SELECT
                Id,
                Name,
                Version__c,
                CreatedDate,
                LastModifiedDate,
                LastModifiedBy.Name,
                CreatedBy.Name
            FROM Brackets_Tournament__c
            WHERE isChild__c = true
            LIMIT 100
        ];
    }

    /**
     * Execute Manual Update
     */

    public void doManualUpdate() {
        Id tId = Apexpages.currentPage().getParameters().get('tId');

        try {
            new BracketsProccessUpdate(tId);
            this.xmlMessage = 'Tournament has been updated!';
        } catch (Exception ex) {
            this.xmlMessage = ex.getMessage();
        }
    }
}
