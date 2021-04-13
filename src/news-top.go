package main

import (
	"./handler"
	_ "./handler/elastic"
	"./handler/imagectl"
	"./handler/mongo"
	"./handler/redis"
	"github.com/labstack/echo"
)

func main() {
	e := echo.New()
	e.GET("/", handler.GetPost())
	e.GET("/old", handler.GetPostFromTo())
	e.GET("/mongo/get", mongo.GetPostMongo())
	e.GET("/mongo/latest", mongo.GetPostMongoLatest())
	e.GET("/mongo/old", mongo.GetPostMongoSkip())
	e.GET("/psql/put", handler.PutPost())
	e.GET("/ranking", handler.GetRanking())
	e.GET("/mongo/ranking", handler.GetRankingMongo())
	e.GET("/redis/get/:post_id", redis.GetViewCount())
	e.GET("/redis/put/:post_id", redis.IncrViewCount())
	e.GET("/elastic/get", handler.GetSearch())
	e.GET("/site/get", mongo.GetSiteInfoMongo())
	e.GET("/try/saveimage", imagectl.SaveImageToCS())
	e.GET("/try/imgtocs", imagectl.UploadToGC())
	e.Static("/privacy_policy", "./public")
	e.Logger.Fatal(e.Start(":8770"))
}
