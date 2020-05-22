trigger BracketsTeam on Brackets_Team__c(
    before insert,
    before update,
    before delete
) {
    if (Trigger.isBefore && Trigger.isDelete) {
        if (!BracketsTeamUtilities.canDeleteTeams(Trigger.old)) {
            Trigger.old
                .get(0)
                .addError(
                    'Teams cannot be deleted, already in use within a Tournament!'
                );
        }
    }
}
