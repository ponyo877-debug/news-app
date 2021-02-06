package handler

import (
	"fmt"
	"net/http"
	"strings"
	"context"
	"strconv"
	"encoding/json"
    "github.com/labstack/echo"
    "github.com/PuerkitoBio/goquery"
	"github.com/mmcdole/gofeed"
	"go.mongodb.org/mongo-driver/bson"
	"./mongo"
	"./elastic"
	"./imagectl"
)

// SiteInfo is metainfomation of RSS Site
type SiteInfoMongo struct {
	ID         int
	title      string
	rssURL     string
	latestDate string
}

// SiteRecord is article infomation for DB
type SiteRecordMongo struct {
	title      string
	URL        string
	image      string
	updateDate string
	siteID     int
}

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

func PutPostMongoTmp() int{
	siteinfolist := getSiteInfoList()
    feedparser := gofeed.NewParser()
    feedArray := []SiteRecordMongo{}
	isVisit := map[int]bool{}
	isDuplicate := map[int]bool{}
    update_count := 0
    for _, siteinfo := range siteinfolist {
        // isVisit[siteinfo.ID] = false
        feed, _ := feedparser.ParseURL(siteinfo.rssURL)
        items := feed.Items
        for _, item := range items {
			if !isDuplicate[item.Link] {
				continue
			}
			isDuplicate[item.Link] = true
            feedmap := SiteRecordMongo{
				image:       getImageFromFeedMongo(item.Content),
				publishedAt: item.Published,
				sitetitle:   siteinfo.title,
				siteID:      siteinfo.ID,
                titles:      item.Title,
                url:         item.Link,
            }
            if feedmap.updateDate > siteinfo.latestDate {
				update_count++
				feedArray = append(feedArray, feedmap)
                if !isVisit[siteinfo.ID] {
                    updateLatestDateMongo(siteinfo.ID, feedmap.updateDate)
                    isVisit[siteinfo.ID] = true
                }
            }
        }
    }
    esId := registerLatestArticleToMongo(feedArray)
	registerLatestArticleToESMongo(esId, feedArray)
	return update_count
}

func getImageFromFeedMongo(feed string) string {
	reader := strings.NewReader(feed)
	doc, _ := goquery.NewDocumentFromReader(reader)
	imageUrl, _ := doc.Find("img").Attr("src")
	return imagectl.ArrangeImageUrl(imageUrl)
}

func jsonStructMongo(esIt int, doc SiteRecordMongo) string {
	db := openDB()
	defer db.Close()
	sql01_03 := "SELECT title FROM siteTBL WHERE ID = $1"
	var sitetitle string
	err := db.QueryRow(sql01_03, doc.siteID).Scan(&sitetitle)
	docStruct := map[string]interface{}{
		"id":			esIt,
		"image":		doc.image,
		"publishedAt":	doc.updateDate,
		"titles":		doc.title,
		"url":			doc.URL,
		"sitetitle":    sitetitle,
    }
    b, err := json.Marshal(docStruct)
    checkError(err)
    return string(b)
}

func registerLatestArticleToESMongo(esIdList []int, articleList []SiteRecordMongo) {
	jsonstrings := ""
	for i := 0; i < len(esIdList); i++ {
		jsonstrings += "{\"create\":{ \"_index\" : \"test_es\" , \"_id\" : \"" + strconv.Itoa(esIdList[i]) + "\"}}\n"
		jsonstrings += jsonStructMongo(esIdList[i], articleList[i]) + "\n"
	}
	
	print(jsonstrings)
	client := elastic.OpenES()

	res, err := client.Bulk(
		strings.NewReader(jsonstrings),
	)
	defer res.Body.Close()
	checkError(err)
}

func registerLatestArticleToMongo(articleList []SiteRecordMongo) []int{
	ctx := context.Background()
	client := mongo.OpenMongo()
	err := client.Connect(ctx)
	defer client.Disconnect(ctx)
	checkError(err)
	col := client.Database("newsdb").Collection("article_col")
	var esIdList []int 

	var esDocumentList []interface{}
	for _, article := range articleList {
		esDocument := bson.M{
			"image": 		article.image,
			"publishedAt": 	article.publishedAt,
			"sitetitle": 	article.sitetitle,
			"siteID": 		article.siteID,
			"title": 		article.titles,
			"url": 			article.url,
		}
		esDocumentList = append(esDocumentList, esDocument)
	}
	if len(esDocumentList) != 0{
		_, err = col.InsertMany(ctx, esDocumentList)
		checkError(err)
	}
	// Need to get articleIDList from mongoDB
	return esIdList
}

func updateLatestDateMongo(siteID int, updateDate string) {
	db := openDB()
	defer db.Close()
	
	sql01_03 := "UPDATE /* sql01_03 */ siteTBL SET latestDate = $1 WHERE ID = $2"
	stmt, err := db.Prepare(sql01_03)
	checkError(err)
	defer stmt.Close()
	_, err = stmt.Exec(updateDate, siteID)
	checkError(err)
}

func getSiteInfoListMongo() []SiteInfoMongo {
	db := openDB()
	defer db.Close()

	siteinfo := SiteInfoMongo{}
	siteinfolist := []SiteInfoMongo{}
	sql01_01 := "SELECT /* sql01_01 */ ID, title, rssURL, latestDate FROM siteTBL"

	selectSiteInfoList, err := db.Query(sql01_01)
	checkError(err)
	defer selectSiteInfoList.Close()
	for selectSiteInfoList.Next() {
		err := selectSiteInfoList.Scan(
			&siteinfo.ID,
			&siteinfo.title,
			&siteinfo.rssURL,
			&siteinfo.latestDate,
		);
		checkError(err)
		siteinfolist = append(siteinfolist, siteinfo)
	}
	return siteinfolist
}