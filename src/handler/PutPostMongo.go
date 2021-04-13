package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	_ "strconv"
	"strings"

	"./elastic"
	"./imagectl"
	"./mongo"
	"github.com/PuerkitoBio/goquery"
	"github.com/labstack/echo"
	"github.com/mmcdole/gofeed"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func PutPostMongo() echo.HandlerFunc {
	return func(c echo.Context) error {
		update_count := PutPostMongoTmp()
		return c.JSON(http.StatusOK, map[string]int{"update_count": update_count})
	}
}

func PutPostMongoJob() {
	update_count := PutPostMongoTmp()
	fmt.Println("update_count: ", update_count)
}

func PutPostMongoTmp() int {
	siteinfolist := getSiteInfoListMongo()
	fmt.Println("siteinfolist: ")
	fmt.Println(siteinfolist)
	feedparser := gofeed.NewParser()
	feedArray := []map[string]interface{}{}
	isVisit := map[int]bool{}
	isDuplicate := map[string]bool{}
	update_count := 0
	for _, siteinfo := range siteinfolist {
		feed, _ := feedparser.ParseURL(siteinfo["rssURL"].(string))
		items := feed.Items
		for _, item := range items {
			if isDuplicate[item.Link] {
				continue
			}
			isDuplicate[item.Link] = true
			siteID := int(siteinfo["siteID"].(float64))
			feedmap := map[string]interface{}{
				"image":       getImageFromFeedMongo(item.Content),
				"publishedAt": item.Published,
				"sitetitle":   siteinfo["sitetitle"].(string),
				"siteID":      siteID,
				"titles":      item.Title,
				"url":         item.Link,
				"acquired":    false,
				"elastic":     false,
			}
			if item.Published > siteinfo["latestDate"].(string) {
				update_count++
				feedArray = append(feedArray, feedmap)
				if !isVisit[siteID] {
					updateLatestDateMongo(siteID, item.Published)
					isVisit[siteID] = true
				}
			}
		}
	}
	if update_count > 0 {
		_ = registerLatestArticleToMongo(feedArray)
		// registerLatestArticleToESMongo(esId, feedArray)
	}
	return update_count
}

func getImageFromFeedMongo(feed string) string {
	reader := strings.NewReader(feed)
	doc, _ := goquery.NewDocumentFromReader(reader)
	imageUrl, _ := doc.Find("img").Attr("src")
	return imagectl.ArrangeImageUrl(imageUrl)
}

func jsonStructMongo(esIt string, doc map[string]interface{}) string {

	docStruct := map[string]interface{}{
		"_id":         esIt,
		"image":       doc["image"],
		"publishedAt": doc["publishedAt"],
		"siteID":      doc["siteID"],
		"sitetitle":   doc["sitetitle"],
		"titles":      doc["titles"],
		"url":         doc["url"],
		"acquired":    doc["acquired"],
	}
	b, err := json.Marshal(docStruct)
	checkError(err)
	return string(b)
}

func registerLatestArticleToESMongo(esIdList []interface{}, articleList []map[string]interface{}) {
	jsonstrings := ""
	for i := 0; i < len(esIdList); i++ {
		jsonstrings += "{\"create\":{ \"_index\" : \"test_es2\" , \"_id\" : \"" + esIdList[i].(primitive.ObjectID).Hex() + "\"}}\n"
		jsonstrings += jsonStructMongo(esIdList[i].(primitive.ObjectID).Hex(), articleList[i]) + "\n"
	}

	print(jsonstrings)
	client := elastic.OpenES()

	_, err := client.Bulk(
		strings.NewReader(jsonstrings),
	)
	// defer res.Body.Close()
	checkError(err)
}

// https://qiita.com/h6591/items/f3a7c1bca31cfa634cca
// https://medium.com/since-i-want-to-start-blog-that-looks-like-men-do/%E5%88%9D%E5%BF%83%E8%80%85%E3%81%AB%E9%80%81%E3%82%8A%E3%81%9F%E3%81%84interface%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9-golang-48eba361c3b4
// https://noknow.info/it/go/how_to_conveert_between_map_string_interface_and_struct?lang=ja
func registerLatestArticleToMongo(articleList []map[string]interface{}) []interface{} {
	ctx := context.Background()
	client := mongo.OpenMongo()
	err := client.Connect(ctx)
	defer client.Disconnect(ctx)
	checkError(err)
	col := client.Database("newsdb").Collection("article_col")
	var esDocumentList []interface{}
	for _, article := range articleList {
		esDocument := bson.M{
			"image":       article["image"],
			"publishedAt": article["publishedAt"],
			"sitetitle":   article["sitetitle"],
			"siteID":      article["siteID"],
			"titles":      article["titles"],
			"url":         article["url"],
			"acquired":    article["acquired"],
			"elastic":     article["elastic"],
		}
		esDocumentList = append(esDocumentList, esDocument)
	}
	esIdList, err := col.InsertMany(ctx, esDocumentList)
	checkError(err)
	return esIdList.InsertedIDs
}

func updateLatestDateMongo(siteID int, updateDate string) {
	ctx := context.Background()
	client := mongo.OpenMongo()
	err := client.Connect(ctx)
	defer client.Disconnect(ctx)
	checkError(err)

	col := client.Database("newsdb").Collection("site_col")
	filter := bson.M{"siteID": bson.M{"$eq": siteID}}
	update := bson.M{"$set": bson.M{"latestDate": updateDate}}
	_, err = col.UpdateOne(ctx, filter, update)
	checkError(err)
}

func getSiteInfoListMongo() []map[string]interface{} {
	ctx := context.Background()
	client := mongo.OpenMongo()
	err := client.Connect(ctx)
	defer client.Disconnect(ctx)
	checkError(err)

	var siteinfolist []map[string]interface{}

	col := client.Database("newsdb").Collection("site_col")
	filter := bson.D{}
	cur, err := col.Find(ctx, filter)
	checkError(err)

	for cur.Next(ctx) {
		var siteinfo bson.M
		err = cur.Decode(&siteinfo)
		fmt.Println(siteinfo)
		checkError(err)
		siteinfolist = append(siteinfolist, siteinfo)
	}
	return siteinfolist
}
