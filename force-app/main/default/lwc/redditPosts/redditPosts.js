import { LightningElement, wire } from 'lwc';
import getRedditPosts from '@salesforce/apex/RedditPostService.getRedditPosts';

const COLUMNS = [
  { label: 'Title', fieldName: 'Title__c' },
  { label: 'Author', fieldName: 'Author__c' },
  {
      label: 'Thumbnail',
      fieldName: 'Thumbnail__c',
      type: 'url',
      target: "_blank",
      typeAttributes: {
        target: '_blank'
    }

  },
  { label: 'Text', fieldName: 'Selftext__c' },
  { label: 'Created Date', fieldName: 'CreatedDate'}
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