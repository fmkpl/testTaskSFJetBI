public with sharing class ExamTaskController {
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
        try {
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
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrders(String accountName, String valueMonth) {
        try {
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

            for(Order__c ord : [select Id,
                                       Name,
                                       Payment_Due_date__c, 
                                       Total_Amount__c, 
                                       Account__c from Order__c where Account__r.Name = :accountName order by Name asc nulls last]) {
                if(ord.Payment_Due_date__c.month() == checkMonth) {
                    ordersList.add(ord);
                }
            }

            return ordersList; 
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future
    @AuraEnabled
    public static void sendEmailWithTemplate(String recordId) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        EmailTemplate emailTemp = [select Id, 
                                          Subject, 
                                          HtmlValue, 
                                          Body, 
                                          Name from EmailTemplate where Name = 'Order Info (Exam Task)'];

        String plainText = emailTemp.HtmlValue;

        Order__c order = [select Id,
                                Name,
                                Account__r.Name,
                                Total_Amount__c,
                                Payment_Due_date__c from Order__c where Id = :recordId];

        plainText = plainText.replace('{{{Order__c.Name}}}', order.Name);
        plainText = plainText.replace('{{{Order__c.Account__c}}}', order.Account__r.Name);
        plainText = plainText.replace('{{{Order__c.Payment_Due_date__c}}}', order.Payment_Due_date__c.format());
        plainText = plainText.replace('{{{Order__c.Total_Amount__c}}}', String.valueOf(order.Total_Amount__c));

        String[] toAddresses = new String[]{'someemailadress@example.com'};
        toAddresses[0] = UserInfo.getUserEmail();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSubject(emailTemp.Subject);
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(plainText);
        mailList.add(mail);

        if(!mailList.isEmpty()) {
            Messaging.sendEmail(mailList);
        }
    }
}
