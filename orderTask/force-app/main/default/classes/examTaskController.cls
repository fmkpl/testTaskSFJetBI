public with sharing class ExamTaskController {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllAccountNamesWithOrders() {
        Set<String> accountNamesSet = new Set<String>();

        DescribeSObjectResult d = Order__c.SObjectType.getDescribe();

        List<String> fields = new List<String>(d.fields.getMap().keySet());

        String soql = 'select ' + String.join(fields, ', ') + ' from Order__c where Account__c != null';

        List<SObject> sobs = Database.query(soql);
        for (SObject ord : sobs) {
            accountNamesSet.add((String)ord.get(Order__c.Account__c));
        }

        List<String> accountNames = new List<String>();
        for (Account acc : [select Id, Name from Account where Id in :accountNamesSet order by Name asc]) {
            accountNames.add(acc.Name);
        }

        return accountNames;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAllMonthsOfPaymentDueDate(String accountName) {
        try {
            if(accountName == '') {
                return null;
            } else {
                List<Date> orderMonthsSet = new List<Date>();

                DescribeSObjectResult d = Order__c.SObjectType.getDescribe();

                List<String> fields = new List<String>(d.fields.getMap().keySet());

                String soql = 'select ' + String.join(fields, ', ') + ' from Order__c where Account__r.Name = :accountName';

                List<SObject> sobs = Database.query(soql);
                for(SObject ord : sobs) {
                    orderMonthsSet.add((Date)ord.get(Order__c.Payment_Due_date__c));
                }
                System.debug(orderMonthsSet);

                Set<Integer> monthNums = new Set<Integer>();
                for(Date item : orderMonthsSet) {
                    monthNums.add(item.month());
                }
                System.debug(monthNums);

                List<String> monthNames = new List<String>();
                for(Integer i : monthNums) {
                    switch on i {
                        when 1 {
                            monthNames.add('January');
                        } 
                        when 2 {
                            monthNames.add('February');
                        }
                        when 3 {
                            monthNames.add('March');
                        } 
                        when 4 {
                            monthNames.add('April');
                        }
                        when 5 {
                            monthNames.add('May');
                        }
                        when 6 {
                            monthNames.add('June');
                        }
                        when 7 {
                            monthNames.add('July');
                        }
                        when 8 {
                            monthNames.add('August');
                        }
                        when 9 {
                            monthNames.add('September');
                        }
                        when 10 {
                            monthNames.add('October');
                        }
                        when 11 {
                            monthNames.add('November');
                        }
                        when 12 {
                            monthNames.add('December');
                        }
                    }
                }
                System.debug(monthNames);
                
                return monthNames;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrders(String accountName, String valueMonth) {
        try {
            if(accountName == '' || valueMonth == '') {
                return null;
            } else {
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

                Account acc = [select Id from Account where Name = :accountName];
                Id accId = acc.Id;

                DescribeSObjectResult d = Order__c.SObjectType.getDescribe();

                List<String> fields = new List<String>(d.fields.getMap().keySet());

                String soql = 'select ' + String.join(fields, ', ') + ' from Order__c where Account__c = :accId';
                System.debug(soql);

                List<Order__c> ordList = new List<Order__c>();

                for (Order__c order : Database.query(soql)) {
                    if(order.Payment_Due_date__c.month() == checkMonth) {
                        ordList.add(order);
                    }
                }

                System.debug(ordList.size());

                return ordList;
            }
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

        Order__c currentOrder = [select Id,
                                Name,
                                Account__r.Name,
                                Total_Amount__c,
                                Payment_Due_date__c from Order__c where Id = :recordId];

        plainText = plainText.replace('{{{Order__c.Name}}}', currentOrder.Name);
        plainText = plainText.replace('{{{Order__c.Account__c}}}', currentOrder.Account__r.Name);
        plainText = plainText.replace('{{{Order__c.Payment_Due_date__c}}}', currentOrder.Payment_Due_date__c.format());
        plainText = plainText.replace('{{{Order__c.Total_Amount__c}}}', String.valueOf(currentOrder.Total_Amount__c));

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
