public with sharing class EventGrosRevenueHelper {

    public static void handleTrigger(List<CAMPX__Sponsor__c> newSponsors, Map<Id,CAMPX__Sponsor__c> oldSponsorMap) {
        SponsorContributionTierHelper.addTierBasedOnContribution(newSponsors);

        EventGrosRevenueHelper.updateRevenueGross(newSponsors, oldSponsorMap);
    }

    public static void updateRevenueGross(List<CAMPX__Sponsor__c> sponsors, Map<Id, CAMPX__Sponsor__c> oldSponsorMap) {
        // Gather event revenue updates
        Map<Id, Decimal> eventRevenueMap = getEventRevenueMap(sponsors, oldSponsorMap);
        updateEventRevenueGross(eventRevenueMap);
    }

    private static Map<Id, Decimal> getEventRevenueMap(List<CAMPX__Sponsor__c> sponsors, Map<Id, CAMPX__Sponsor__c> oldSponsorMap) {
        Map<Id, Decimal> eventRevenueMap = new Map<Id, Decimal>();

        for (CAMPX__Sponsor__c sponsor : sponsors) {
            Decimal contribution = sponsor.CAMPX__ContributionAmount__c != null ? sponsor.CAMPX__ContributionAmount__c : 0;

            // Handle when sponsor is linked to an event            
            if (sponsor.CAMPX__Status__c == 'Accepted') {
                updateRevenueMap(eventRevenueMap, sponsor.CAMPX__Event__c, contribution);
            } else if (sponsor.CAMPX__Status__c == 'Rejected' || sponsor.CAMPX__Status__c == 'Pending') {
                updateRevenueMap(eventRevenueMap, sponsor.CAMPX__Event__c, -contribution);
            }            

            // Handle when the event is removed (old sponsor had an event, new one does not)
            if (oldSponsorMap != null && oldSponsorMap.containsKey(sponsor.Id)) {
                CAMPX__Sponsor__c oldSponsor = oldSponsorMap.get(sponsor.Id);
                if (oldSponsor.CAMPX__Event__c != null && sponsor.CAMPX__Event__c == null) {
                    // Subtract old contribution from the previous event's gross revenue
                    updateRevenueMap(eventRevenueMap, oldSponsor.CAMPX__Event__c, -contribution);
                }
            }
        }
        return eventRevenueMap;
    }

    private static void updateRevenueMap(Map<Id, Decimal> eventRevenueMap, Id eventId, Decimal contribution) {
        if (eventRevenueMap.containsKey(eventId)) {
            eventRevenueMap.put(eventId, eventRevenueMap.get(eventId) + contribution);
        } else {
            eventRevenueMap.put(eventId, contribution);
        }
    }

    private static void updateEventRevenueGross(Map<Id, Decimal> eventRevenueMap) {
        if (eventRevenueMap.isEmpty()) {
            return;
        }

        List<CAMPX__Event__c> events = [
            SELECT Id, CAMPX__GrossRevenue__c
            FROM CAMPX__Event__c
            WHERE Id IN :eventRevenueMap.keySet()
            WITH USER_MODE
        ];

        for (CAMPX__Event__c event : events) {
            if (eventRevenueMap.containsKey(event.Id)) {
                Decimal currentRevenue = event.CAMPX__GrossRevenue__c != null ? event.CAMPX__GrossRevenue__c : 0;
                event.CAMPX__GrossRevenue__c = currentRevenue + eventRevenueMap.get(event.Id);
            }
        }

        if (Schema.sObjectType.CAMPX__Event__c.fields.CAMPX__GrossRevenue__c.isUpdateable()) {
            update events;
        }
    }
}
