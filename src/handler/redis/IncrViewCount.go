package redis

import (
	"context"
	"net/http"
	"github.com/labstack/echo"
)

var ctx = context.Background()

func IncrViewCount() echo.HandlerFunc {
    return func(c echo.Context) error {
		postIDStr := c.Param("post_id")
		newscore := IncrViewCountTmp(postIDStr)
		return c.JSON(http.StatusOK, map[string]int{"newscore": newscore})
    }
}

func GetViewCount() echo.HandlerFunc {
    return func(c echo.Context) error {
		postIDStr := c.Param("post_id")
		score := GetViewCountTmp(postIDStr)
		return c.JSON(http.StatusOK, map[string]int{"score": score})
    }
}

func IncrViewCountTmp(postID string) int{
	db := OpenKVS()
	defer db.Close()
	ctx := context.Background()
	zsetKey := "view_counter"

	newscore, err := db.ZIncrBy(ctx, zsetKey, 1, postID).Result()
	checkError(err)
	return int(newscore)
}

func GetViewCountTmp(postID string) int{
	db := OpenKVS()
	defer db.Close()
	ctx := context.Background()
	zsetKey := "view_counter"

	score, err := db.ZScore(ctx, zsetKey, postID).Result()
	checkError(err)
	return int(score)
}