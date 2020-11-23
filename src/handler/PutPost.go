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
)

// SiteInfo is metainfomation of RSS Site
type SiteInfo struct {
	ID         int
	title      string
	rssURL     string
	latestDate string
}

// SiteRecord is article infomation for DB
type SiteRecord struct {
	title      string
	URL        string
	image      string
	updateDate string
	siteID     int
}

// EsRecord is article infomation for ElasticSearch
type EsRecord struct {
	id    		int
	image 		string
	publishedAt string
	titles 		string
	url			string
}

func PutPost() echo.HandlerFunc {
    return func(c echo.Context) error {
		update_count := PutPostTmp()
        return c.JSON(http.StatusOK, map[string]int{"update_count": update_count})
    }
}

func PutPostJob() {
	update_count := PutPostTmp()
	fmt.Println("update_count:", update_count)
}

func PutPostTmp() int{
	siteinfolist := getSiteInfoList()
    feedparser := gofeed.NewParser()
    feedArray := []SiteRecord{}
    isVisit := map[int]bool{}
    update_count := 0
    for _, siteinfo := range siteinfolist {
        isVisit[siteinfo.ID] = false
        feed, _ := feedparser.ParseURL(siteinfo.rssURL)
        items := feed.Items
        for _, item := range items {
            feedmap := SiteRecord{
                title:      item.Title,
                URL:        item.Link,
                image:      getImageFromFeed(item.Content),
                updateDate: item.Published,
                siteID:     siteinfo.ID,
            }
            if feedmap.updateDate > siteinfo.latestDate {
                update_count++
                feedArray = append(feedArray, feedmap)
                if !isVisit[siteinfo.ID] {
                    updateLatestDate(siteinfo.ID, feedmap.updateDate)
                    isVisit[siteinfo.ID] = true
                }
            }
        }
    }
    esId := registerLatestArticleToDB(feedArray)
	registerLatestArticleToES(esId, feedArray)
	// RegisterLatestArticleToMongo(feedArray)
	return update_count
}

func getImageFromFeed(feed string) string {
	reader := strings.NewReader(feed)
	doc, _ := goquery.NewDocumentFromReader(reader)
	ImageURL, _ := doc.Find("img").Attr("src")
	return ImageURL
}

func registerLatestArticleToDB(articleList []SiteRecord) []int {
	db := openDB()
    defer db.Close()
    sql01_02 := "INSERT INTO /* sql01_02 */ articleTBL (title, URL, image, updateDate, click, siteID) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id"
    // stmt, err := db.Prepare(sql01_02)
	// sql01_02 := "INSERT INTO /* sql01_02 */ articleTBL (title, URL, image, updateDate, click, siteID) VALUES ($1, $2, $3, $4, $5, $6) RETURNING (id, title)""
	
	// checkError(err)
	// defer stmt.Close()
    
    var esIdList []int 
	var esId int
	for _, article := range articleList {
        // fmt.Println(article.title, article.URL, article.image, article.updateDate, 0, article.siteID)
        // err = stmt.QueryRow(article.title, article.URL, article.image, article.updateDate, 0, article.siteID).Scan(&esRecord.ID, &esRecord.title)
        // err = stmt.Exec(article.title, article.URL, article.image, article.updateDate, 0, article.siteID)
        err := db.QueryRow(sql01_02, article.title, article.URL, article.image, article.updateDate, 0, article.siteID).Scan(&esId)
		checkError(err)
        esIdList = append(esIdList, esId)
    }
	return esIdList
}

func jsonStruct(esIt int, doc SiteRecord) string {
	docStruct := map[string]interface{}{
		"id":			esIt,
		"image":		doc.image,
		"publishedAt":	doc.updateDate,
		"titles":		doc.title,
		"url":			doc.URL,
    }
    b, err := json.Marshal(docStruct)
    checkError(err)
    return string(b)
}

func registerLatestArticleToES(esIdList []int, articleList []SiteRecord) {
	jsonstrings := ""
	for i := 0; i < len(esIdList); i++ {
		jsonstrings += "{\"create\":{ \"_index\" : \"test_es\" , \"_id\" : \"" + strconv.Itoa(esIdList[i]) + "\"}}\n"
		jsonstrings += jsonStruct(esIdList[i], articleList[i]) + "\n"
	}
	print(jsonstrings)
	client := elastic.OpenES()

	res, err := client.Bulk(
		strings.NewReader(jsonstrings),
	)
	defer res.Body.Close()

	//fmt.Println(res)
	checkError(err)
}

func RegisterLatestArticleToMongo(articleList []SiteRecord){
	ctx := context.Background()
	client := mongo.OpenMongo()
	err := client.Connect(ctx)
	defer client.Disconnect(ctx)
	checkError(err)
	col := client.Database("newsdb").Collection("article_col")

	var esDocumentList []interface{}
	for _, article := range articleList {
		esDocument := bson.M{
			"title": article.title,
			"URL": article.URL,
			"image": article.image,
			"updateDate": article.updateDate,
			"click": 0,
			"siteID": article.siteID,
		}
		esDocumentList = append(esDocumentList, esDocument)
	}
	if len(esDocumentList) != 0{
		_, err = col.InsertMany(ctx, esDocumentList)
		checkError(err)
	}
}

func updateLatestDate(siteID int, updateDate string) {
	db := openDB()
	defer db.Close()
	
	sql01_03 := "UPDATE /* sql01_03 */ siteTBL SET latestDate = $1 WHERE ID = $2"
	stmt, err := db.Prepare(sql01_03)
	checkError(err)
	defer stmt.Close()
	_, err = stmt.Exec(updateDate, siteID)
	checkError(err)
}

func getSiteInfoList() []SiteInfo {
	db := openDB()
	defer db.Close()

	siteinfo := SiteInfo{}
	siteinfolist := []SiteInfo{}
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