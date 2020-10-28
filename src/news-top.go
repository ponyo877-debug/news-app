package main

import (
        "github.com/labstack/echo"
        "./handler"
        "./handler/redis"
        "./handler/mongo"
)

func main() {
        e := echo.New()
        e.GET("/", handler.GetPost())
        e.GET("/psql/put", handler.PutPost())
        e.GET("/redis/get/:post_id", redis.GetViewCount())
        e.GET("/redis/put/:post_id", redis.IncrViewCount())
        e.GET("/mongo/get", mongo.GetPostMongo())
        e.Static("/privacy_policy", "./public")
        e.Logger.Fatal(e.Start(":8770"))
}