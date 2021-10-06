@isTest
public with sharing class examTaskControllerTest {
    @TestSetup
    static void makeData() {
        List<Account> testAccts = new List<Account>();

        for(Integer i = 0; i < 2; i++) {
            testAccts.add(new Account(Name = 'TestAcct' + i));
        }

        insert testAccts;

        List<Order__c> testOrds = new List<Order__c>();
        for(Integer i = 0; i < 12; i++) {
                testOrds.add(new Order__c(Account__c = testAccts[0].Id,
                                        Total_Amount__c = 46500, 
                                        Payment_Due_date__c = Date.newInstance(2016, i+1, 9)));

                testOrds.add(new Order__c(Account__c = testAccts[1].Id,
                                        Total_Amount__c = 46500, 
                                        Payment_Due_date__c = Date.newInstance(2013, i+1, 5)));
        }

        insert testOrds;
    }

    @isTest
    public static void getAllAccountNamesWithOrdersTestPositive() {
        Set<String> accountNamesSet = new Set<String>();

        for(Order__c ord : [select Name, Account__r.Name, Total_Amount__c from Order__c where Account__c != null 
                                                                                            and Total_Amount__c = 46500]) {
            accountNamesSet.add(ord.Account__r.Name);
        }

        List<String> accountNames = new List<String>(accountNamesSet);

        Test.startTest();
        List<String> testList = examTaskController.getAllAccountNamesWithOrders();
        Test.stopTest();

        System.assert(accountNames.size() == testList.size(), 'They are not equals');
    }

    @isTest
    public static void getAllMonthsOfPaymentDueDateTestPositive() {
        Set<Integer> orderMonthsSet = new Set<Integer>();

        for(Order__c ord : [select Payment_Due_date__c from Order__c where Account__r.Name like '%TestAcct0%']) {
            orderMonthsSet.add(ord.Payment_Due_date__c.month());
        }

        List<String> orderMonths = new List<String>();

        for(Integer i : orderMonthsSet) {
            switch on i {
                when 1 {
                    orderMonths.add('January');
                } 
                when 2 {
                    orderMonths.add('February');
                }
                when 3 {
                    orderMonths.add('March');
                } 
                when 4 {
                    orderMonths.add('April');
                }
                when 5 {
                    orderMonths.add('May');
                }
                when 6 {
                    orderMonths.add('June');
                }
                when 7 {
                    orderMonths.add('July');
                }
                when 8 {
                    orderMonths.add('August');
                }
                when 9 {
                    orderMonths.add('September');
                }
                when 10 {
                    orderMonths.add('October');
                }
                when 11 {
                    orderMonths.add('November');
                }
                when 12 {
                    orderMonths.add('December');
                }
            }
        }
        Test.startTest();
        List<String> testList = examTaskController.getAllMonthsOfPaymentDueDate('TestAcct0');
        Test.stopTest();

        System.assert(testList.size() == orderMonths.size(), 'They are not equals');
    }

    @IsTest
    public static void getOrdersTestPositive() {
        List<String> months = new List<String>();
        months.add('January');
        months.add('February');
        months.add('March');
        months.add('April');
        months.add('May');
        months.add('June');
        months.add('July');
        months.add('August');
        months.add('September');
        months.add('October');
        months.add('November');
        months.add('December');
        List<Order__c> ordList = new List<Order__c>();

        for (Order__c ord : [select Id, Name, Payment_Due_date__c from Order__c where Account__r.Name = 'TestAcct0']) {
            if(ord.Payment_Due_date__c.month() == 1 ||
                ord.Payment_Due_date__c.month() == 2 ||
                ord.Payment_Due_date__c.month() == 3 ||
                ord.Payment_Due_date__c.month() == 4 ||
                ord.Payment_Due_date__c.month() == 5 ||
                ord.Payment_Due_date__c.month() == 6 ||
                ord.Payment_Due_date__c.month() == 7 ||
                ord.Payment_Due_date__c.month() == 8 ||
                ord.Payment_Due_date__c.month() == 9 ||
                ord.Payment_Due_date__c.month() == 10 ||
                ord.Payment_Due_date__c.month() == 11 ||
                ord.Payment_Due_date__c.month() == 12) {
                ordList.add(ord);
            }
        }

        Map<Integer, List<Order__c>> testMap = new Map<Integer, List<Order__c>>();
        Test.startTest();
        for(Integer i = 0; i < ordList.size(); i++) {
            testMap.put(i + 1, examTaskController.getOrders('TestAcct0', months[i]));
        }
        Test.stopTest();

        System.assert(testMap.size() == ordList.size(), 'They are not equals');
    }

    @IsTest
    public static void getEmailOfCurrentUserTestPositive() {
        String userEmail = UserInfo.getUserEmail();

        Test.startTest();
        String testEmail = examTaskController.getEmailOfCurrentUser();
        Test.stopTest();
        
        System.assert(userEmail == testEmail, 'They are not equals');
    }
}
