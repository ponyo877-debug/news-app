package mongo

import (
	"fmt"
    "context"
    "net/http"
	"github.com/labstack/echo"
    "go.mongodb.org/mongo-driver/bson"
    _"go.mongodb.org/mongo-driver/mongo/options"
)

func GetPostMongo() echo.HandlerFunc {
    return func(c echo.Context) error {		
        ctx := context.Background()
        client := OpenMongo()
        err := client.Connect(ctx)
        defer client.Disconnect(ctx)
		checkError(err)
		
		col := client.Database("newsdb").Collection("article_col")
        // filter := bson.D{{"title", bson.D{{"$regex", "Goog"}}}}
        filter := bson.D{}
		cur, err := col.Find(ctx, filter)
        checkError(err)
        
        var feedArray []map[string]interface{}
        var feed bson.M
		for cur.Next(ctx) {
			err = cur.Decode(&feed);
			checkError(err)
            fmt.Printf(feed["title"].(string))
            feedmap := map[string]interface{}{
                "titles":      feed["title"],
                "url":         feed["URL"],
                "image":       feed["image"],
                "publishedAt": feed["updateDate"],
            }
            feedArray = append(feedArray, feedmap)
        }
        return c.JSON(http.StatusOK, feedArray)
    }
}