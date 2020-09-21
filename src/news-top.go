package main

import (
        "github.com/labstack/echo"
        "./handler"
)

func main() {
        e := echo.New()
        e.GET("/", handler.GetPost())
        e.GET("/put", handler.PutPost())
        e.Logger.Fatal(e.Start(":8770"))
}