# Commnads Paper

## Golang
go build -o GetHit GetHit.go

## kubectl Commands
export PROJECT_ID=gke-test-287910
docker build -t gcr.io/${PROJECT_ID}/get_latest_article_list:v3 .
docker push gcr.io/${PROJECT_ID}/get_latest_article_list:v3

docker build -t gcr.io/${PROJECT_ID}/insert_latest_article_list:v1 -f Dockerfile_cron .
docker push gcr.io/${PROJECT_ID}/insert_latest_article_list:v1

docker run 


## PostgreSQL Commnads
kubectl exec -it pod/postgres-84667b9486-t5xq5 sh
psql -h postgres -U test_user --password -p 5433 test_db
psql -h postgres.default -U test_user --password -p 5433 test_db

createuser -a -d -U postgres -P test_user
psql -h localhost -U test_user -d test_db
CREATE DATABASE test_db;

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