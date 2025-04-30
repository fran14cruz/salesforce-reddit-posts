import { LightningElement, wire } from 'lwc';
import getRedditPosts from '@salesforce/apex/RedditPostService.getRedditPosts';

const COLUMNS = [
  { label: 'Title', fieldName: 'Title__c' },
  { label: 'Author', fieldName: 'Author__c' },
  { label: 'Score', fieldName: 'Score__c' },
  {
    label: 'Thumbnail',
    fieldName: 'Thumbnail__c',
    type: 'customImage',
    typeAttributes: {
      url: { fieldName: 'Thumbnail__c' },
      title: { fieldName: 'Title__c' },
    }
  },
  {
    label: 'Created Date',
    fieldName: 'CreatedDate',
    type: 'date',
    typeAttributes: {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'}
  }
];

export default class RedditPosts extends LightningElement {
  posts;
  columns = COLUMNS;

  @wire(getRedditPosts)
  wiredPosts({ error, data }) {
      if (data) {
          this.posts = data;
      } else if (error) {
          console.error(error);
      }
  }
}