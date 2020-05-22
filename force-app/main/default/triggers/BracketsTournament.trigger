trigger BracketsTournament on Brackets_Tournament__c(
    before insert,
    before update,
    after insert,
    before delete
) {
    if (!BracketsTournamentUtilities.CreatingTournamentTree) {
        if (Trigger.isBefore && Trigger.isInsert) {
            BracketsTournamentUtilities.checkTeamCount(Trigger.new);
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            BracketsTournamentUtilities.publishOff(Trigger.new, Trigger.old);
            BracketsTournamentUtilities.checkTeamCountNotUpdateable(
                Trigger.new,
                Trigger.old
            );
        }
        // Create tourament tree skeleton
        if (Trigger.isAfter && Trigger.isInsert) {
            BracketsTournamentUtilities.createTournamentTree(Trigger.new);
        }
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        BracketsGroupUtilities.deleteGroups(Trigger.old);
    }
}
