import { LightningElement } from 'lwc';

import failureWithLog from '@salesforce/apex/LogDemo.failureWithLog';
import multipleFailuresWithLog from '@salesforce/apex/LogDemo.multipleFailuresWithLog';

export default class LogDemo extends LightningElement {

    loadFailureWithLog() {
        console.log("In Function");
        return failureWithLog();
    }

    loadMultipleFailuresWithLog(){
        return multipleFailuresWithLog();
    }
}

