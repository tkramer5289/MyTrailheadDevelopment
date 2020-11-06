import { LightningElement, api } from 'lwc';
import UserId from '@salesforce/user/Id';
import getBadges from "@salesforce/apex/myTrailheadController.getBadges";

export default class RecommendedBadges extends LightningElement {
    @api recordId;
    @api tagsLabel;
    @api productsLabel;
    @api lightningCardTitle;
    @api lightningCardIcon;
    @api lightningCardIconSize;
    @api recommendByQuantity = false;
    @api recommendByMostRecent = false;
    @api relevanceButtonLabel;
    @api mostRecentButtonLabel;
    @api refreshButtonLabel;
    uId = UserId;
    badgeArray = {};
    connectedCallback(){
        console.log('in connected callback');
        this.getBadgesMethod(this.uId, this.recordId, this.recommendByQuantity, this.recommendByMostRecent);

    }

    relevanceHandleClick(){
        this.getBadgesMethod(this.uId, this.recordId, true, false);
    }

    mostRecentHandleClick(){
        this.getBadgesMethod(this.uId, this.recordId, false, true);
    }

    getBadgesMethod(inputUserId, inputRecordId, inputUseRelevance, inputUseDateToSort){
        var currentUserId = inputUserId;
        console.log('currentUserId '+ currentUserId );
        var currentRecordId = inputRecordId;
        var useRelevance = inputUseRelevance;
        var useDateToSort = inputUseDateToSort;
        getBadges({
            currentUserId,
            currentRecordId,
            useRelevance,
            useDateToSort
        }).then((result)=>{
            this.badgeArray = {};
            this.badgeArray = result;
            
            
            console.log("Success-in timeSheetEntry then");
            
        }).catch((error)=>{
            this.error = error;
            console.log("Error-in timeSheetEntry error:"+this.error.body.message);
            
        });
    }
    

    get hasBadges() {
        if (this.badgeArray.length > 0) {
          return true;
        }
        return false;
      }

}