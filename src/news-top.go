package main

import (
        "github.com/labstack/echo"
        "./handler"
        "./redis"
)

func main() {
        e := echo.New()
        e.GET("/", handler.GetPost())
        e.GET("/put", handler.PutPost())
        e.GET("/view/incr/:post_id", redis.IncrViewCount())
        e.GET("/view/get/:post_id", redis.GetViewCount())
        e.Logger.Fatal(e.Start(":8770"))
}