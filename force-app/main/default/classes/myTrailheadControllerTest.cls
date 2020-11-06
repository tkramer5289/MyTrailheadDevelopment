@isTest(SeeAllData=True)
private class myTrailheadControllerTest {
    
    
    static testMethod void validatemyTrailheadController1(){
        
       Id [] fixedSearchResults= new Id[4];
       fixedSearchResults[0] = 'a7V3c000000lvdMEAQ';
       fixedSearchResults[1] = 'a7V3c000000lvdKEAQ';
       fixedSearchResults[2] = 'a7V3c000000lvdLEAQ';
       fixedSearchResults[3] = 'a7V3c000000lvdFEAQ'; 
       Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        List<SObject> abc = myTrailheadController.getBadges('0053c00000AuCMRAA3', 
                                                            '0063c00001FOEGtAAP', 
                                                            true,
                                                            false
                                                           );
        
        List<SObject> def = myTrailheadController.getBadges('0053c00000AuCMRAA3', 
                                                            '0063c00001FOEGtAAP', 
                                                            false,
                                                            true
                                                           );
        
        List<SObject> ghi = myTrailheadController.getBadges('0053c00000AuCMRAA3', 
                                                            '0063c00001FOEGtAAP', 
                                                            false,
                                                            false
                                                           );
        
        Test.stopTest();
        
    }
}