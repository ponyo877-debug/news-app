package mongo

import (
    _"fmt"
    "strconv"
    "context"
    "net/http"
    "github.com/labstack/echo"
    "go.mongodb.org/mongo-driver/bson"
    "go.mongodb.org/mongo-driver/mongo/options"
)

// https://qiita.com/h6591/items/a1898bddb6819b27d88f
// https://www.mongodb.com/blog/post/mongodb-go-driver-tutorial
/*
func GetPostMongo() echo.HandlerFunc {
    return func(c echo.Context) error {		
        ctx := context.Background()
        client := OpenMongo()
        err := client.Connect(ctx)
        defer client.Disconnect(ctx)
		checkError(err)
		
		col := client.Database("newsdb").Collection("article_col")
        filter := bson.D{}
        findOptions := options.Find()
        findOptions.SetSort(bson.D{{"publishedAt", -1}}).SetLimit(15)
		cur, err := col.Find(ctx, filter, findOptions)
        checkError(err)
        
        var feedArray []map[string]interface{}
		for cur.Next(ctx) {
            var feed bson.M
			err = cur.Decode(&feed);
			checkError(err)
            feedArray = append(feedArray, feed)
        }
        return c.JSON(http.StatusOK, feedArray)
    }
}
*/

func GetPostMongoSkip() echo.HandlerFunc {
    return func(c echo.Context) error {
        qfrom, _ := strconv.Atoi(c.QueryParam("from"))

        ctx := context.Background()
        client := OpenMongo()
        err := client.Connect(ctx)
        defer client.Disconnect(ctx)
		checkError(err)
		
		col := client.Database("newsdb").Collection("article_col")
        filter := bson.D{}
        findOptions := options.Find()
        findOptions.SetSort(bson.D{{"publishedAt", -1}}).SetSkip(int64(qfrom)).SetLimit(15)
		cur, err := col.Find(ctx, filter, findOptions)
        checkError(err)
        
        var feedArray []map[string]interface{}
		for cur.Next(ctx) {
            var feed bson.M
			err = cur.Decode(&feed);
			checkError(err)
            feedArray = append(feedArray, feed)
        }
        return c.JSON(http.StatusOK, map[string][]map[string]interface{}{"data": feedArray})
    }
}

/*
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
*/