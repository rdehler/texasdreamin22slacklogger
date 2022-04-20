import { LightningElement,track, api } from 'lwc';

import divide from '@salesforce/apex/LogDemo.divide';
import createAccount from '@salesforce/apex/LogDemo.createAccount';

export default class LogDemo extends LightningElement {

    @track resultDivide;
    @track resultAccount;
    @api numerator = 0;
    @api denominator = 0;
    @api accountName;

    loadFailureWithLog() {
        console.log("In Function");
        return failureWithLog();
    }

    loadDivide(){
        console.log("In function");
        console.log("Current values: " + this.numerator + " " + this.denominator);
        return divide({numerator : this.numerator, denominator : this.denominator})
            .then(response => {
                if(response){
                    this.resultDivide = "SUCCESS! Result = " + response;
                } else {
                    this.resultDivide = "ERROR!";
                }
                this.numerator = 0;
                this.denominator = 0;
            });
    }

    loadCreateAccount(){
        return createAccount({accountName : this.accountName})
            .then(response => {
                if(response){
                    this.resultAccount = "SUCCESS! Account Created. ID = " + response.Id;
                } else {
                    this.resultAccount = "ERROR!";
                }
                this.searchText = "";
            })
    }

    loadMultipleFailuresWithLog(){
        return multipleFailuresWithLog();
    }

    handleNumeratorChange(event){
        this.numerator = event.target.value;
    }
    handleDenominatorChange(event){
        this.denominator = event.target.value;
    }
    handleAccountSearchChange(event){
        this.accountName = event.target.value;
    }
}

