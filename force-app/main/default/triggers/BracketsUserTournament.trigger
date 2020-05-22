trigger BracketsUserTournament on Brackets_UserTournament__c(
    after insert,
    after update,
    after delete,
    before update,
    before insert
) {
    // Check Existing join to tournaments
    if (Trigger.isBefore && Trigger.isInsert) {
        BracketsUserTournamentUtilities.checkJoinedTournaments(Trigger.new);
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            BracketsUserTournamentUtilities.userSuscribe(Trigger.new);
        }
    }

}
