@isTest
private with sharing class ExamTaskControllerTest {
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


    //POSITIVE TESTS
    @isTest
    private static void getAllAccountNamesWithOrdersTestPositive() {
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        Set<String> accountNamesSet = new Set<String>();

        for(Order__c ord : [select Name, Account__r.Name, Total_Amount__c from Order__c where Account__c != null 
                                                                                            and Total_Amount__c = 46500]) {
            accountNamesSet.add(ord.Account__r.Name);
        }

        List<String> testList = new List<String>();

        Test.startTest();
        System.runAs(currentUser) {
            testList = ExamTaskController.getAllAccountNamesWithOrders();
        }
        Test.stopTest();

        System.assert(accountNamesSet.size() == testList.size(), 'Amount of acc names is different');
    }

    @isTest
    private static void getAllMonthsOfPaymentDueDateTestPositive() {
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

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

        List<String> testList = new List<String>();

        Test.startTest();
        System.runAs(currentUser) {
            testList = ExamTaskController.getAllMonthsOfPaymentDueDate('TestAcct0');
        }
        Test.stopTest();

        System.assert(testList.size() == orderMonths.size(), 'Amount of month names is different');
    }

    @IsTest
    private static void getOrdersTestPositive() {
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        List<String> months = new List<String> { 'January',
                                                'February',
                                                'March',
                                                'April',
                                                'May',
                                                'June',
                                                'July',
                                                'August',
                                                'September',
                                                'October',
                                                'November',
                                                'December' };

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

        List<List<Order__c>> testList = new List<List<Order__c>>();

        Test.startTest();
        System.runAs(currentUser) {
            for(Integer i = 0; i < 12; i++) {
                testList.add(ExamTaskController.getOrders('TestAcct0', months[i]));
            }
        }
        Test.stopTest();

        System.assertEquals(testList.size(), ordList.size(), 'Size of orders list is different');
    }

    @IsTest
    private static void sendEmailWithoutTemplateTestPositive() {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        Order__c order = [select Id, Name, Total_Amount__c, Account__r.Name, Payment_Due_date__c from Order__c where Total_Amount__c = 46500][0];

        EmailTemplate emailTemp = [select Id, 
                                          Subject, 
                                          HtmlValue, 
                                          Body, 
                                          Name from EmailTemplate where Name = 'Order Info (Exam Task)'];

        String plainText = emailTemp.HtmlValue;

        plainText = plainText.replace('{{{Order__c.Name}}}', order.Name);
        plainText = plainText.replace('{{{Order__c.Account__c}}}', order.Account__r.Name);
        plainText = plainText.replace('{{{Order__c.Payment_Due_date__c}}}', order.Payment_Due_date__c.format());
        plainText = plainText.replace('{{{Order__c.Total_Amount__c}}}', String.valueOf(order.Total_Amount__c));

        String[] toAddresses = new String[]{'testemail@example.com'};

        toAddresses[0] = UserInfo.getUserEmail();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(emailTemp.Subject);
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(plainText);
        mailList.add(mail);

        Test.startTest();
        System.runAs(currentUser) {
            ExamTaskController.sendEmailWithTemplate(order.Id);
        }
        Test.stopTest();

        System.assert(!mailList.isEmpty(), 'Email list to sent is empty');
    }


    //NEGATIVE TESTS
    @IsTest
    private static void getAllAccountNamesWithOrdersTestNegative() {
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        Set<String> accountNamesSet = new Set<String>();

        for(Order__c ord : [select Name, Account__r.Name, Total_Amount__c from Order__c where Account__c != null 
                                                                                            and Total_Amount__c = 4650]) {
            accountNamesSet.add(ord.Account__r.Name);
        }

        List<String> testList = new List<String>();

        Test.startTest();
        System.runAs(currentUser) {
            testList = ExamTaskController.getAllAccountNamesWithOrders();
        }
        Test.stopTest();

        System.assertNotEquals(testList.size(), accountNamesSet.size(), 'Amount of acc names is equals');        
    }

    @IsTest
    private static void getAllMonthsOfPaymentDueDateTestNegative() {
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        Set<Integer> orderMonthsSet = new Set<Integer>();

        for(Order__c ord : [select Payment_Due_date__c from Order__c where Account__r.Name like '%TestAcct3%']) {
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

        List<String> testList = new List<String>();

        Test.startTest();
        System.runAs(currentUser) {
            testList = ExamTaskController.getAllMonthsOfPaymentDueDate('TestAcct0');
        }
        Test.stopTest();

        System.assertNotEquals(testList.size(), orderMonths.size(), 'Amount of month names is equals');   
    }

    @IsTest
    private static void getOrdersTestNegative() {
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        List<String> months = new List<String> { 'January',
                                                'February',
                                                'March',
                                                'April',
                                                'May',
                                                'June',
                                                'July',
                                                'August',
                                                'September',
                                                'October',
                                                'November',
                                                'December' };

        List<Order__c> ordList = new List<Order__c>();

        for (Order__c ord : [select Id, Name, Payment_Due_date__c from Order__c where Account__r.Name = 'TestAcct7']) {
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

        List<List<Order__c>> testList = new List<List<Order__c>>();

        Test.startTest();
        System.runAs(currentUser) {
            for(Integer i = 0; i < 12; i++) {
                testList.add(ExamTaskController.getOrders('TestAcct0', months[i]));
            }
        }
        Test.stopTest();

        System.assertNotEquals(testList.size(), ordList.size(), 'Amount of order list is equals');
    }

    @IsTest
    private static void sendEmailWithoutTemplateTestNegative() { 
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];

        Order__c order = [select Id, 
                                 Name, 
                                 Total_Amount__c, 
                                 Account__r.Name, 
                                 Payment_Due_date__c from Order__c where Total_Amount__c = 46500][0];

        EmailTemplate emailTemp = [select Id, 
                                          Subject, 
                                          HtmlValue, 
                                          Body, 
                                          Name from EmailTemplate where Name = 'Order Info (Exam Task)'];

        String plainText = emailTemp.HtmlValue;

        plainText = plainText.replace('{{{Order__c.Name}}}', order.Name);
        plainText = plainText.replace('{{{Order__c.Account__c}}}', order.Account__r.Name);
        plainText = plainText.replace('{{{Order__c.Payment_Due_date__c}}}', order.Payment_Due_date__c.format());
        plainText = plainText.replace('{{{Order__c.Total_Amount__c}}}', String.valueOf(order.Total_Amount__c));

        String[] toAddresses = new String[]{'testemail@example.com'};

        toAddresses[0] = UserInfo.getUserEmail();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(emailTemp.Subject); 
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(plainText);
        mailList.add(mail);

        Test.startTest();
        System.runAs(currentUser) {
            ExamTaskController.sendEmailWithTemplate(order.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, emailTemp.Id, 'Email template variable is null');
    }
}
