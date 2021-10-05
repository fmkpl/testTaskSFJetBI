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
            if(i <= 11) {
                testOrds.add(new Order__c(Account__c = testAccts[0].Id,
                                        Total_Amount__c = 46500, 
                                        Payment_Due_date__c = Date.newInstance(2016, i+1, 9)));

                testOrds.add(new Order__c(Account__c = testAccts[1].Id,
                                        Total_Amount__c = 52400, 
                                        Payment_Due_date__c = Date.newInstance(2013, i+1, 5)));
            }
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

        for(Order__c ord : [select Payment_Due_date__c from Order__c where Account__r.Name like '%TestAcct%']) {
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

        System.debug(testList.size());
        System.debug(orderMonths.size());
        System.debug(testList.size() == orderMonths.size());
        //System.assert(testList.size() == orderMonths.size(), 'They are not equals');
        System.assertEquals(12, testList.size());
    }
}
