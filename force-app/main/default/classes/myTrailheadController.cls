public with sharing class myTrailheadController {
    @AuraEnabled
    public static List<SObject> getBadges(Id currentUserId, Id currentRecordId, Boolean useRelevance, Boolean useDateToSort ){
        //List<SObject>
        system.debug('in getBadges controller');
        system.debug('inputs in apex class');
        system.debug('**currentUserId** :'+currentUserId);
        system.debug('currentRecordId :'+currentRecordId);
        system.debug('useRelevance :'+useRelevance);
        system.debug('useDateToSort :'+useDateToSort);

        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();

        Set<String> productNames = new Set<String>();
        String searchString = '{}';
        Integer counter = 0;
        Set<Id> completedBadgeIds = new Set<Id>();
        String whereClause = '()';
        for(trailheadapp__User_Badge__c userBadgeRecord: [SELECT Id, trailheadapp__Badge__c 
                                    FROM trailheadapp__User_Badge__c 
                                    WHERE trailheadapp__User__c = :currentUserId 
                                          AND trailheadapp__Status__c = 'Completed']){
                                              //equal to complete is correct- the where clause in SOSL query is looking for NOT IN id's

                                            if(counter ==0){
                                                completedBadgeIds.add(userBadgeRecord.trailheadapp__Badge__c);
                                                whereClause = '(' + '\'' + userBadgeRecord.trailheadapp__Badge__c + '\',';
                                                counter++;
                                            }else{
                                                if(!completedBadgeIds.contains(userBadgeRecord.trailheadapp__Badge__c)){
                                                    completedBadgeIds.add(userBadgeRecord.trailheadapp__Badge__c);
                                                    whereClause = whereClause + '\'' + userBadgeRecord.trailheadapp__Badge__c + '\',';
                                                }
                                                
                                            }

                                            completedBadgeIds.add(userBadgeRecord.trailheadapp__Badge__c);
                                          }
        whereClause = whereClause.removeEnd(',');
        whereClause = whereClause + ')';
        System.debug('whereClause :'+whereClause);

        System.debug('completedBadgeIds: '+completedBadgeIds);
        counter = 0;
        for (OpportunityLineItem productItem : [SELECT Id, 
                                                        Name, 
                                                        Product2.Name, 
                                                        Quantity, 
                                                        UnitPrice
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId = :currentRecordId]) {
                if(counter ==0){
                    productNames.add(productItem.Product2.Name);
                    searchString = '{' + '\"' + productItem.Product2.Name + '\" OR';
                    counter++;
                }else{
                    if(!productNames.contains(productItem.Product2.Name)){
                        productNames.add(productItem.Product2.Name);
                        searchString = searchString + ' \"' + productItem.Product2.Name + '\" OR';
                    }
                    
                }
                
                productList.add(productItem);                                   
            
        }
        System.debug('searchString :'+searchString);
        searchString = searchString.removeEnd(' OR');
        searchString = searchString + '}';
        System.debug('searchString :'+searchString);
        
        String searchQuery = 'FIND ' + searchString + ' IN ALL FIELDS RETURNING  trailheadapp__Badge__c (Id,Name,trailheadapp__URL__c,trailheadapp__Icon__c,trailheadapp__Badge_Icon__c,trailheadapp__Products__c,trailheadapp__Tags__c,trailheadapp__Created_At__c  WHERE ID NOT IN'+ whereClause +')';
        System.debug('searchQuery :'+searchQuery);
        List<List <sObject>> searchList = search.query(searchQuery);
        trailheadapp__Badge__c [] searchedBadges = ((List<trailheadapp__Badge__c>)searchList[0]);
        System.debug('searchedBadges: '+searchedBadges);
        

        //custom object idea
        //create a custom object to store badge details and associated ranking
        //store badge details first using searchedBadges list
        //next query products for products in search badges product list- get product and quantity
        //loop over searchedBadges and add quantities from all products for that search badge
        //once the table is udpated, query the table - order by associated ranking and display the results

        if(useRelevance){
            //get operator from LWC to see if this relevance is required or not
            //clear the table
            List<Badge_Relevance__c> SobjLst = [select id from Badge_Relevance__c];
            delete SobjLst;
            
            Set<String> uniqueProducts = new Set<String>();
            List<String> productNameList1 = new List<String>();            
            counter = 0;
            
        for(trailheadapp__Badge__c badge: searchedBadges){
            System.debug('badge.trailheadapp__Products__c: '+badge.trailheadapp__Products__c);
            String[] associatedProducts = badge.trailheadapp__Products__c.split(',');
            
            
            for(String str :associatedProducts){

                if(counter ==0){
                    productNameList1.add(str.trim());
                    uniqueProducts.add(str.trim());
                    counter++;
                }else{
                    if(!uniqueProducts.contains(str.trim())){
                        productNameList1.add(str.trim());
                        uniqueProducts.add(str.trim());
                    }
                    
                }

                System.debug('str is:'+str);
                
                }

        }
        //System.debug('productNameList:'+productNameList);
        System.debug('productNameList1:'+productNameList1);
        
        List<Badge_Relevance__c> brList = new List<Badge_Relevance__c>();
        Badge_Relevance__c brRecord;

        List<OpportunityLineItem> newProductItems =[SELECT Id, Product2.Name, 
                                                        Quantity
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId = :currentRecordId
                                                AND Product2.Name IN :productNameList1
                                                ORDER BY Quantity DESC];
        System.debug('newProductItems :'+newProductItems);

        for(trailheadapp__Badge__c badge: searchedBadges){
            Decimal quant = 0;
            for(OpportunityLineItem product: newProductItems){
                
                if(badge.trailheadapp__Products__c.contains(product.Product2.Name)){
                    quant = quant + product.Quantity;

                }

            }
            brRecord = new Badge_Relevance__c(Badge__c = badge.Id,
                                              BadgeName__c = badge.Name,
                                              Ranking__c = quant,
                                              badgeURL__c = badge.trailheadapp__URL__c,
                                              badgeIcon__c = badge.trailheadapp__Icon__c,
                                              associatedProducts__c = badge.trailheadapp__Products__c,
                                              associatedTags__c = badge.trailheadapp__Tags__c,
                                              badgeDate__c = badge.trailheadapp__Created_At__c);
            brList.add(brRecord);
        }

        if(brList.size() > 0){
            insert brList;

        }


        List<Badge_Relevance__c> relevantBadges = new List<Badge_Relevance__c>();
        relevantBadges = [SELECT Id, 
                                 Badge__c, 
                                 BadgeName__c,
                                 Ranking__c,
                                 badgeURL__c,
                                 badgeIcon__c,
                                 associatedProducts__c,
                                 associatedTags__c
                         FROM  Badge_Relevance__c
                         ORDER BY Ranking__c DESC];
        return relevantBadges;

        }else if(useDateToSort){
            //get operator from LWC to see if this relevance is required or not
            //clear the table
            List<Badge_Relevance__c> SobjLst = [select id from Badge_Relevance__c];
            delete SobjLst;

        List<Badge_Relevance__c> brList = new List<Badge_Relevance__c>();
        Badge_Relevance__c brRecord;

        for(trailheadapp__Badge__c badge: searchedBadges){
            brRecord = new Badge_Relevance__c(Badge__c = badge.Id,
                                              BadgeName__c = badge.Name,
                                              badgeURL__c = badge.trailheadapp__URL__c,
                                              badgeIcon__c = badge.trailheadapp__Icon__c,
                                              associatedProducts__c = badge.trailheadapp__Products__c,
                                              associatedTags__c = badge.trailheadapp__Tags__c,
                                              badgeDate__c = badge.trailheadapp__Created_At__c);
            brList.add(brRecord);
        }

        if(brList.size() > 0){
            insert brList;

        }


        List<Badge_Relevance__c> relevantBadges = new List<Badge_Relevance__c>();
        relevantBadges = [SELECT Id, 
                                 Badge__c, 
                                 BadgeName__c,
                                 Ranking__c,
                                 badgeURL__c,
                                 badgeIcon__c,
                                 associatedProducts__c,
                                 associatedTags__c
                         FROM  Badge_Relevance__c
                         ORDER BY badgeDate__c DESC];
        return relevantBadges;

            

        }
        
        return searchedBadges;
        
        
    }
}