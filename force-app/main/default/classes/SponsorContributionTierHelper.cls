public with sharing class SponsorContributionTierHelper {
    
    public static void addTierBasedOnContribution(List<CAMPX__Sponsor__c> sponsors) {
        
        for (CAMPX__Sponsor__c sp : sponsors) {            
            
            if (sp.CAMPX__ContributionAmount__c == null || sp.CAMPX__ContributionAmount__c <= 0 ) {
                sp.CAMPX__Tier__c = '';
            } else if (sp.CAMPX__ContributionAmount__c > 0 && sp.CAMPX__ContributionAmount__c < 1000) {
                sp.CAMPX__Tier__c = 'Bronze';
            } else if (sp.CAMPX__ContributionAmount__c >= 1000 && sp.CAMPX__ContributionAmount__c < 5000) {
                sp.CAMPX__Tier__c = 'Silver';
            } else if (sp.CAMPX__ContributionAmount__c >= 5000) {
                sp.CAMPX__Tier__c = 'Gold';
            }
        }
    }
}