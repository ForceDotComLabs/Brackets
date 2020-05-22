trigger BracketsMatch on Brackets_Match__c(
    after insert,
    after update,
    after delete,
    before update,
    before insert
) {
    if (
        !BracketsMatchUtilities.SKIP_TRIGGER &&
        !BracketsTournamentUtilities.CreatingTournamentTree
    ) {
        if (Trigger.isAfter || (Trigger.isUpdate && Trigger.isBefore)) {
            BracketsTriggerUtilities.triggerListObject = Trigger.newMap;
        }
        BracketsTriggerUtilities.newTriggerInstance(Trigger.new);

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
            }

            if (Trigger.isUpdate) {
                BracketsMatchUtilities.checkLocked(Trigger.old, Trigger.new);
                // Update UserMatchPrediction points
                BracketsMatchesPredictionUtil.updateUserMatchPredictionPoints(
                    Trigger.new
                );
                //Update the following matches
                BracketsMatchUtilities.updateFollowingMatches(Trigger.new);
            }

            if (Trigger.isDelete) {
                BracketsMatchUtilities.checkLocked(Trigger.old, Trigger.new);
            }
        }

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                BracketsMatchUtilities.checkExistMatchesInRound(Trigger.new);
                BracketsMatchUtilities.dateMatchesValidation(Trigger.new);
            }

            if (Trigger.isUpdate) {
                BracketsMatchUtilities.checkLocked(Trigger.old, Trigger.new);
                BracketsMatchUtilities.checkSetTeam(Trigger.new, Trigger.old);
                BracketsMatchUtilities.setWinnerTeam(Trigger.new, Trigger.old);
                BracketsMatchUtilities.checkRemovedTeam(
                    Trigger.new,
                    Trigger.old
                );
                BracketsMatchUtilities.publishOff(Trigger.new);
                BracketsMatchUtilities.checkExistMatchesInRound(Trigger.new);
                BracketsMatchUtilities.dateMatchesValidation(Trigger.new);
            }

            if (Trigger.isDelete) {
                BracketsMatchUtilities.checkLocked(Trigger.old, Trigger.new);
            }
        }
    }
}
