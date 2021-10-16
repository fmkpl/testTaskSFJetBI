public with sharing class WorkingWithSObj {
    public static List<SObject> createRecords(SObjectType sObjectType, Integer count)
    {
        List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < count; i++)
            records.add(sObjectType.newSObject());
        System.debug(records.size());
        return records;
    }

    public static List<Account> createAccounts(Integer count)
    {
        List<Account> records = new List<Account>();
        for (Integer i = 0; i < count; i++)
            records.add(new Account());
        String name = records[0].getSObjectType().getDescribe().getName();
        System.debug(name);
        return records;
    }
}
