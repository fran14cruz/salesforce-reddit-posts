import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Define the field you want to retrieve
const THUMBNAIL_FIELD = 'Reddit_Post__c.Thumbnail__c';

export default class DisplayRedditImage extends LightningElement {
    @api recordId; // This gets the current record ID when used in a record page
    thumbnailUrl;
    error;

    // Use the wire service to get the record and its fields
    @wire(getRecord, { recordId: '$recordId', fields: [THUMBNAIL_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            // Access the Thumbnail__c field
            this.thumbnailUrl = data.fields.Thumbnail__c.value;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.thumbnailUrl = undefined;
        }
    }
}