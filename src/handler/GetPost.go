package handler

import (
    "net/http"
    "github.com/labstack/echo"
)

type feedRecord struct {
	ID         int
	title      string
	URL        string
	image      string
	updateDate string
	click      int
	siteID     int
}

func GetPost() echo.HandlerFunc {
    return func(c echo.Context) error {		
		feed := feedRecord{}
        var feedArray []map[string]interface{}
        sql01_01 := "SELECT /* sql01_01 */ id, title, URL, image, updateDate, click, siteID FROM articleTBL ORDER BY updateDate DESC LIMIT 15"
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
                "id":          feed.ID,
                "titles":      feed.title,
                "url":         feed.URL,
                "image":       feed.image,
                "publishedAt": feed.updateDate,
            }
            feedArray = append(feedArray, feedmap)
        }
        return c.JSON(http.StatusOK, map[string][]map[string]interface{}{"data": feedArray})
    }
}