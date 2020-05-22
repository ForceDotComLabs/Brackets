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
public with sharing class BracketsTreeViewController {
    //-------------------------------------------------------------------------
    // Constants & Variables
    //-------------------------------------------------------------------------

    private BracketsTreeView baseTree = null;

    //-------------------------------------------------------------------------
    // Getters and Setters
    //-------------------------------------------------------------------------

    public String tournamentId { get; set; }
    public Brackets_Group__c targetGroup { get; set; }
    public Boolean showSaveAll { get; set; }
    public String json { get; set; }
    public String message { get; set; }
    public String messageType { get; set; }
    public Boolean isRoundByRound { get; set; }

    //component arguments
    public String groupId { get; set; }
    public String userTournamentId { get; set; }
    public Datetime nextDeadline { get; set; }
    public Integer activeRound { get; set; }
    public Boolean isLocked { get; set; }

    public BracketsTreeViewFootball nflTree { get; set; }
    public BracketsTreeViewStandard stdTree { get; set; }

    public Boolean getIsRenderable() {
        init();
        return true;
    }

    /**
     * Initialize controller
     */
    public void init() {
        if (this.groupId == null) {
            throw new BracketsException(
                'Cannot initialize without a group id. [BracketsTreeViewController]'
            );
        }
        if (this.isLocked == null) {
            throw new BracketsException(
                'Cannot initialize without an indicator for isLocked (currently null) [BracketsTreeViewController]'
            );
        }

        if (this.tournamentId == null) {
            Brackets_Group__c target = [
                SELECT Id, Name, Type__c, Brackets_Tournament__c
                FROM Brackets_Group__c
                WHERE Id = :this.groupId
            ];
            if (target == null) {
                throw new BracketsException('Could not locate tournament.');
            }
            this.tournamentId = target.Brackets_Tournament__c;
            this.targetGroup = target;
            this.isRoundByRound =
                target.Type__c == BracketsGroupUtilities.BET_TYPE_BY_ROUND;
        }
        createTree();

        Boolean hasStdDisabled =
            this.stdTree != null &&
            stdTree.getTournamentClass().contains('tournament-disabled');
        Boolean hasNflDisabled =
            this.nflTree != null &&
            this.nflTree.getTournamentClass().contains('tournament-disabled');

        if (hasStdDisabled || hasNflDisabled) {
            this.showSaveAll = false;
        } else {
            this.showSaveAll = true;
        }
    }

    //-------------------------------------------------------------------------
    // Private Methods
    //-------------------------------------------------------------------------

    /**
     * Creates trees depending on the type
     */
    public void createTree() {
        this.baseTree = new BracketsTreeView(
            this.tournamentId,
            this.targetGroup,
            this.isLocked,
            this.userTournamentId
        );

        if (this.baseTree != null) {
            if (
                this.baseTree.tournament.Type__c ==
                BracketsTournamentUtilities.NFL_PLAYOFF_TOURNAMENT_TYPE
            ) {
                this.nflTree = new BracketsTreeViewFootball(this.baseTree);
            } else if (
                this.baseTree.tournament.Type__c ==
                BracketsTournamentUtilities.STANDARD_TOURNAMENT_TYPE
            ) {
                this.stdTree = new BracketsTreeViewStandard(this.baseTree);
            }
        }
    }
}
