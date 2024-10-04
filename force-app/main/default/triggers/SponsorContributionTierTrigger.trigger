trigger SponsorContributionTierTrigger on CAMPX__Sponsor__c (before insert, before update) {
  // Handle tier changes based on contributions
  // SponsorContributionTierHelper.addTierBasedOnContribution(Trigger.new);

  EventGrosRevenueHelper.handleTrigger(Trigger.new, Trigger.isUpdate ? Trigger.oldMap : null);

  // if (Trigger.isUpdate) {
  //     EventGrosRevenueHelper.updateRevenueGross(Trigger.new, Trigger.oldMap);
  // } else {
  //     EventGrosRevenueHelper.updateRevenueGross(Trigger.new, null);  
  // }
}
