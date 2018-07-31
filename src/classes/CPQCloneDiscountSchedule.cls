public without sharing class CPQCloneDiscountSchedule {
    private ApexPages.StandardController standardController;
 
    public CPQCloneDiscountSchedule(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference doClone(){
    	SBQQ__DiscountSchedule__c originalSchedule = (SBQQ__DiscountSchedule__c) standardController.getRecord();
        String queryString = SobjectUtilities.getQueryAllString(SBQQ__DiscountSchedule__c.SObjectType);
        
        originalSchedule = Database.query(queryString + 'WHERE Id = \'' + originalSchedule.Id +  '\' LIMIT 1');
        SBQQ__DiscountSchedule__c newSchedule = originalSchedule.clone(false, false, false, false);
        newSchedule.Name = 'Clone_' + originalSchedule.Name;

        insert newSchedule;

        String tierQueryString = SobjectUtilities.getQueryAllString(SBQQ__DiscountTier__c.SObjectType);
        List<SBQQ__DiscountTier__c> tiersToClone = Database.query(tierQueryString + 'WHERE SBQQ__Schedule__c = \'' + originalSchedule.Id +  '\'');
        List<SBQQ__DiscountTier__c> clonedTiers = new List<SBQQ__DiscountTier__c>();
        for(SBQQ__DiscountTier__c tier : tiersToClone){
        	SBQQ__DiscountTier__c clonedTier = tier.clone(false, false, false, false);
        	clonedTier.SBQQ__Schedule__c = newSchedule.Id;
        	clonedTiers.add(clonedTier);
        }
        insert clonedTiers;
        
        return new PageReference('/'+newSchedule.Id);
    }
 
 	public static String getQueryAllString(Schema.SObjectType sObjType) {
        String queryAllString = 'SELECT ';
        for(String field : getFieldMap(sObjType).keySet()) {
            queryAllString += field + ', ';
        }
        queryAllString = queryAllString.removeEnd(', ');
        queryAllString += ' FROM ' + sObjType.getDescribe().getName() + ' ';
        System.debug('### queryAllString: ' + queryAllString);
        return queryAllString;
    }

    public static Map<String,Schema.SobjectField> getFieldMap(Schema.SObjectType sObjType) {
        return sObjType.getDescribe().fields.getMap();
    }
}