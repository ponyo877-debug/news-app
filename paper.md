# Commnads Paper

## Golang
go build -o GetHit GetHit.go

## Docker
docker run --name redis_container -d -p 6379:6379 gcr.io/${PROJECT_ID}/redis:v1 redis-server --appendonly no
docker run --name mongo_container -d -p 27017:27017 gcr.io/${PROJECT_ID}/mongo:v1

## kubectl Commands
docker build -t gcr.io/${PROJECT_ID}/getpost:v11 .
docker push gcr.io/${PROJECT_ID}/getpost:v11

export PROJECT_ID=gke-test-287910
docker build -t gcr.io/${PROJECT_ID}/get_latest_article_list:v3 .
docker push gcr.io/${PROJECT_ID}/get_latest_article_list:v3

docker build -t gcr.io/${PROJECT_ID}/insert_latest_article_list:v1 -f Dockerfile_cron .
docker push gcr.io/${PROJECT_ID}/insert_latest_article_list:v1

kubectl run curl-machine --image=radial/busyboxplus:curl -i --tty --rm


## PostgreSQL Commnads
kubectl exec -it postgres-0 sh
psql -h postgres -U test_user --password -p 5433 test_db
psql -h postgres.default -U test_user --password -p 5433 test_db

createuser -a -d -U postgres -P test_user
psql -h localhost -U test_user -d test_db
CREATE DATABASE test_db;
CREATE INDEX ON test_db.articletbl(updatedate);

## Redis Commnads

## ElasticSearch
service elasticsearch start
curl http://127.0.0.1:9200


## Git Commands
git add .
git commit -m "XXth commit"
git remote add origin https://github.com/ponyo877-debug/news-app.git
git push -u origin master

## DashBoard
### ArgoCD
https://34.84.219.149/

### Argo Workflows
http://34.84.145.108:2746/

### Tekton
http://35.221.67.62:9097/

## Jenkins
http://35.200.116.233:8080/
curl -X POST http://admin:11f6f30c61e90643e40f520729e87ca047@54.248.165.23:8080/job/jenkins-pipeline/build?token=ponyo

var tmp_json = [];
var tmp_json2 = [];
_jsonString = await _filePath.readAsString();
tmp_json2 = json.decode(_jsonString);
tmp_json.add(tmp_json2.last);
_jsonString = json.encode(tmp_json);
_filePath.writeAsString(_jsonString);

## /var/lib/docker/overlay2/配下の肥大化への対処
docker system prune

# perftest
## articletbl_updatedate_idxなし
for i in $(seq 1 100); do curl "https://gitouhon-juku-k8s2.ga/" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+=$1} END {print sum/cnt}'
0.443791

## articletbl_updatedate_idxあり
for i in $(seq 1 100); do curl "https://gitouhon-juku-k8s2.ga/" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+=$1} END {print sum/cnt}'
0.216004

## mongoDB
for i in $(seq 1 100); do curl "https://gitouhon-juku-k8s2.ga/mongo/get" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+=$1} EN
D {print sum/cnt}'
0.140283

for i in $(seq 1 100); do curl "https://gitouhon-juku-k8s2.ga/mongo/old?from=0" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+
=$1} END {print sum/cnt}'
0.140007

## local_PostgreSQL_idxなし
for i in $(seq 1 100); do curl "localhost:8770/" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+=$1} END {print sum/cnt}'
0.0119866

## local_PostgreSQL_idxあり
for i in $(seq 1 100); do curl "localhost:8770/" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+=$1} END {print sum/cnt}'
0.0075589

## local_mongoDB
for i in $(seq 1 100); do curl "localhost:8770/mongo/get_trial" -o /dev/null -w "%{time_total}\n" 2> /dev/null -s; done | awk '{cnt++; sum+=$1} END {print sum/cnt}'
0.0132953

# しゃべくり007_アンタッチャブル_TVer   
http://players.brightcove.net/4394098882001/default_default/index.html?videoId=6227907929001


# ES_RESET
db.site_col.insert({siteID: 1, sitetitle: '痛いニュース',           rssURL: 'http://blog.livedoor.jp/dqnplus/index.rdf',   latestDate: '2020-01-01 00:00:00'});
db.site_col.insert({siteID: 2, sitetitle: 'アルファルファモザイク', rssURL: 'http://alfalfalfa.com/index.rdf',             latestDate: '2020-01-01 00:00:00'});
db.site_col.insert({siteID: 4, sitetitle: 'ハムスター速報',         rssURL: 'http://hamusoku.com/index.rdf',               latestDate: '2020-01-01 00:00:00'});
db.site_col.insert({siteID: 5, sitetitle: '暇人＼^o^／速報',        rssURL: 'http://himasoku.com/index.rdf',               latestDate: '2020-01-01 00:00:00'});
db.site_col.insert({siteID: 6, sitetitle: 'VIPPERな俺',             rssURL: 'http://blog.livedoor.jp/news23vip/index.rdf', latestDate: '2020-01-01 00:00:00'});
db.site_col.insert({siteID: 3, sitetitle: 'ニュー速クオリティ',     rssURL: 'http://news4vip.livedoor.biz/index.rdf',      latestDate: '2020-01-01 00:00:00'});

db.site_col.deleteMany( { siteID: {$lt: 10} } )

# mongo
kubectl exec -it mongo-0 sh
mongo --host mongo.default --port 27017

db.site_col.find({})