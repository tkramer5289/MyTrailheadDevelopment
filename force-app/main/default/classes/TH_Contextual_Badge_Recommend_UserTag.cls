/**
 * Class to get trailhead recommendations based for the current user
 */
global class TH_Contextual_Badge_Recommend_UserTag {

    /**
     * Determines the recommended entries for a given record
     * @param recordId (Id) - id of the record we want to find recommendations for.
     * @returns TH_Assignments.TrailheadEntry[] - list of trialhead entries
     */
    @AuraEnabled(cacheable=false)
    public static TH_Assignments.TrailheadEntry[] getRecommendedEntries(Id recordId) {
        system.debug('** recordId **');
        system.debug(recordId);

        /** Final list of all the trialhead entries we will return */
        TH_Assignments.TrailheadEntry[] results = new TH_Assignments.TrailheadEntry[]{};

        /** current user id */
        Id userId = UserInfo.getUserId();

        /** collection of ids for all the badges to recommend */
        Set<Id> Badges = new Set<Id>();
        /** collection of ids for all the trailmixes to recommend */
        Set<Id> Trailmixes = new Set<Id>();

        /** collection of recommendations */
        TH_Recommendation__c [] recommendations;

                /*-- determine all the recommendations
                if(recordId <> null){
                    String sObjName = recordId.getSObjectType().getDescribe().getName();
                    recommendations = [Select Id, Badge__c, Trailmix__c, OwnerId From TH_Recommendation__c Where OwnerId=:userId And 
                            ((Object_API_Name__c =:sObjName And Record_Id__c ='') Or (Record_Id__c =:recordId))];
                } else {
                    recommendations = [Select Id, Badge__c, Trailmix__c, OwnerId From TH_Recommendation__c Where OwnerId=:userId];
                }
                // system.debug('** TH_Recommendation__c **');
                // system.debug(recommendations);
        
                //-- determine the ids of all the badges and trailmixes to be recommended
                for(TH_Recommendation__c thr : recommendations){
                    if(thr.Badge__c <> null) Badges.add(thr.Badge__c);
                    if(thr.Trailmix__c <> null) Trailmixes.add(thr.Trailmix__c);
                }*/

        //NEW by TK-- determine the ids of all the badges and trailmixes to be recommended
        for(trailheadapp__Badge__c tb : getBadges()){
            if(tb.Id <> null) Badges.add(tb.Id);
        }
        
        // system.debug('** Badges & Trailmixes **');
        // system.debug(Badges);
        // system.debug(Trailmixes);

        /** Final list of all the trialhead entries we will return */
        results = TH_Assignments.determineEntriesByTrailheadId(badges, trailmixes, userId);

        return results;
    }
    
    public static List<trailheadapp__Badge__c> getBadges() {
        
        Integer i = 1;
        String query = 'SELECT Id, trailheadapp__Badge_Icon__c, Badge_Hyperlink__c, trailheadapp__Icon__c, Name, trailheadapp__URL__c FROM trailheadapp__Badge__c ';
        System.debug('THIS IS THE USER: '+UserInfo.getUserId());
        for (User_Tag__c ut : [select Id, Name, Tag__r.Name from User_Tag__c where User__c = :UserInfo.getUserId()]){
        	
            String tag = ut.Tag__r.Name;
            if (i==1){
                
               query += 'WHERE ( ';
            }
            else{
                
                query += 'OR ';
            }
            query += 'trailheadapp__Tags__c like \''+tag+'\' ';
            i++;
        }
        
        query += ' ) ';
        
        // Remove the badges the user already has
        /*
        String idsToRemove = '';
        Integer j = 1;
        for (trailheadapp__User_Badge__c ub : [select trailheadapp__Badge__c from trailheadapp__User_Badge__c WHERE trailheadapp__Status__c = 'Completed' AND trailheadapp__User__c = :UserInfo.getUserId()]){
            
            if (j>1) idsToRemove += ', ';
            idsToRemove += ' \''+ub.trailheadapp__Badge__c+'\' ';
            j++;
        }
        */
        
        System.debug('THIS IS THE QUERY: '+query);
		
        
        return Database.query(query);
        
        //return [SELECT Id, trailheadapp__Badge_Icon__c, Badge_Hyperlink__c, trailheadapp__Icon__c, Name, trailheadapp__URL__c
                  //FROM trailheadapp__Badge__c
                 /*WHERE trailheadapp__Tags__c like 'Dental' 
                    OR trailheadapp__Tags__c like 'Adhesives'
                    OR trailheadapp__Tags__c like 'Abrasives'
                    OR trailheadapp__Tags__c like 'Personal Safety'
                    OR trailheadapp__Tags__c like 'Sales'
                    OR trailheadapp__Tags__c like 'Service'
                    OR trailheadapp__Tags__c like 'Marketing'*/
                // LIMIT :numberOfRecords];
    }
}