public with sharing class examTaskController {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllAccountNamesWithOrders() {
        Set<String> accountNamesSet = new Set<String>();
        for(Order__c ord : [select Name, Account__r.Name from Order__c]) {
            accountNamesSet.add(ord.Account__r.Name);
        }
        List<String> accountNames = new List<String>(accountNamesSet);
        return accountNames;
    }
}
