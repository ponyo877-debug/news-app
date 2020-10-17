## Mongo Commands

# operation
use newsdb
db.createCollection('article_col');
db.article_col.insert({title: 'Yahoo', URL: 'https://www.yahoo.co.jp/', image: 'tbd', updateDate: new Date(), click: 0, siteID: 1});
db.article_col.insert({title: 'Google', URL: 'https://www.google.com/', image: 'tbd', updateDate: new Date(), click: 0, siteID: 2});
