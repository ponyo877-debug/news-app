package handler

import (
    "net/http"
    "fmt"
    "os"
    "strconv"
    "database/sql"
    _ "github.com/lib/pq"
    "github.com/labstack/echo"
    "io/ioutil"
    "encoding/json"

    "strings"
    "github.com/PuerkitoBio/goquery"
	"github.com/mmcdole/gofeed"
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
	ID    int
	title string
}

type feedRecord struct {
	ID         int
	title      string
	URL        string
	image      string
	updateDate string
	click      int
	siteID     int
}

type DBConfig struct {
    Host    string  `json:"host"`
    Port    int     `json:"port"`
    User    string  `json:"user"`
    Dbname  string  `json:"dbname"`
    Pass    string  `json:"pass"`
}

func checkError(err error) {
	if err != nil {
	        fmt.Fprintf(os.Stderr, "fatal: error: %s", err.Error())
		os.Exit(1)
	}
}

func openDB() *sql.DB{
    jsonString, err := ioutil.ReadFile("config.json")
    checkError(err)
    
    var c DBConfig
    err = json.Unmarshal(jsonString, &c)
    checkError(err)
    
    db, err := sql.Open("postgres", "host=" + c.Host + " port=" + strconv.Itoa(c.Port) + " user=" + c.User + " dbname=" + c.Dbname + " password=" + c.Pass + " sslmode=disable")
    checkError(err)
    return db
}

func GetPost() echo.HandlerFunc {
    return func(c echo.Context) error {		
		feed := feedRecord{}
        var feedArray []map[string]interface{}
        sql01_01 := "SELECT /* sql01_01 */ id, title, URL, image, updateDate, click, siteID FROM articleTBL"
        db := openDB()
        defer db.Close()
        selectFeedList, err := db.Query(sql01_01)
        checkError(err)      	
        defer selectFeedList.Close()
        for selectFeedList.Next() {
        	if err := selectFeedList.Scan(
        		&feed.ID,
        		&feed.title,
        		&feed.URL,
                &feed.image,
                &feed.updateDate,
                &feed.click,
			    &feed.siteID,
            ); err != nil {
                panic(err)
            }
            feedmap := map[string]interface{}{
                "title":       feed.title,
                "url":         feed.URL,
                "image":       feed.image,
                "publishedAt": feed.updateDate,
            }
            feedArray = append(feedArray, feedmap)
        }
        return c.JSON(http.StatusOK, feedArray)
    }
}

func PutPost() echo.HandlerFunc {
    return func(c echo.Context) error {	
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
        esRecord := registerLatestArticleToDB(feedArray)
        registerLatestArticleToES(esRecord)
        return c.JSON(http.StatusOK, map[string]int{"update_count": update_count})
    }
}

func getImageFromFeed(feed string) string {
	reader := strings.NewReader(feed)
	doc, _ := goquery.NewDocumentFromReader(reader)
	ImageURL, _ := doc.Find("img").Attr("src")
	return ImageURL
}

func registerLatestArticleToDB(articleList []SiteRecord) []EsRecord {
	db := openDB()
    defer db.Close()
    sql01_02 := "INSERT INTO /* sql01_02 */ articleTBL (title, URL, image, updateDate, click, siteID) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id"
    // stmt, err := db.Prepare(sql01_02)
	// sql01_02 := "INSERT INTO /* sql01_02 */ articleTBL (title, URL, image, updateDate, click, siteID) VALUES ($1, $2, $3, $4, $5, $6) RETURNING (id, title)""
	
	// checkError(err)
	// defer stmt.Close()
    
    esRecordList := []EsRecord{}
	var esRecord EsRecord
	for _, article := range articleList {
        // fmt.Println(article.title, article.URL, article.image, article.updateDate, 0, article.siteID)
        // err = stmt.QueryRow(article.title, article.URL, article.image, article.updateDate, 0, article.siteID).Scan(&esRecord.ID, &esRecord.title)
        // err = stmt.Exec(article.title, article.URL, article.image, article.updateDate, 0, article.siteID)
        err := db.QueryRow(sql01_02, article.title, article.URL, article.image, article.updateDate, 0, article.siteID).Scan(&esRecord.ID)
		checkError(err)
        esRecordList = append(esRecordList, esRecord)
    }
	return esRecordList
}

func registerLatestArticleToES(articleList []EsRecord) {
	for _, article := range articleList {
		fmt.Println("registerLatestArticleToES:", article.ID, article.title)
		// TBD
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
/*
{
    "host": "postgres",
    "port": 5433,
    "user": "test_user",
    "dbname": "test_db",
    "pass": "sukuryuu1"
}
*/