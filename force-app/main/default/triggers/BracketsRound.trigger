trigger BracketsRound on Brackets_Round__c(before insert, before update) {
    if (!BracketsTournamentUtilities.CreatingTournamentTree) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                BracketsRoundUtilities.checkRoundsIntegrity(Trigger.new);
            }
            if (Trigger.isUpdate) {
                BracketsRoundUtilities.publishOff(Trigger.new);
            }
            if (Trigger.isInsert) {
                BracketsRoundUtilities.roundNumberOnInsert(Trigger.new);
            }
        }
    }
}
