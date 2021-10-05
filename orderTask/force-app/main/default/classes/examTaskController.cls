public with sharing class examTaskController {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllAccountNamesWithOrders() {
        Set<String> accountNamesSet = new Set<String>();

        for(Order__c ord : [select Name, Account__r.Name from Order__c where Account__c != null]) {
            accountNamesSet.add(ord.Account__r.Name);
        }

        List<String> accountNames = new List<String>(accountNamesSet);
        return accountNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAllMonthsOfPaymentDueDate(String accountName) {
        Set<Integer> orderMonthsSet = new Set<Integer>();

        for(Order__c ord : [select Payment_Due_date__c from Order__c where Account__r.Name = :accountName]) {
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
        
        return orderMonths;
    }

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrders(String accountName, String valueMonth) {
        Integer checkMonth = 0;
        
        switch on valueMonth {
            when 'January' {
                checkMonth = 1;
            }
            when 'February' {
                checkMonth = 2;
            }
            when 'March' {
                checkMonth = 3;
            }
            when 'April' {
                checkMonth = 4;
            }
            when 'May' {
                checkMonth = 5;
            }
            when 'June' {
                checkMonth = 6;
            }
            when 'July' {
                checkMonth = 7;
            }
            when 'August' {
                checkMonth = 8;
            }
            when 'September' {
                checkMonth = 9;
            }
            when 'October' {
                checkMonth = 10;
            }
            when 'November' {
                checkMonth = 11;
            }
            when 'December' {
                checkMonth = 12;
            }
        }

        List<Order__c> ordersList = new List<Order__c>();

        for(Order__c ord : [select Id, Name, Payment_Due_date__c from Order__c where Account__r.Name = :accountName]) {
            if(ord.Payment_Due_date__c.month() == checkMonth) {
                ordersList.add(ord);
            }
        }

        return ordersList;
    }
}
