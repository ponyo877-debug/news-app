package handler

import (
	"net/http"
	"./redis"
	// "strconv"
    "github.com/labstack/echo"
)

func GetRanking() echo.HandlerFunc {
    return func(c echo.Context) error {		
		feed := feedRecord{}
		var feedArray []map[string]interface{}
		sql02_01 := "SELECT /* sql02_01 */ id, title, URL, image, updateDate, click, siteID FROM articleTBL WHERE id = $1"

		idsRanking := redis.GetIdsRankingTmp()
		for _, id_count := range idsRanking {
			db := openDB()
			defer db.Close()
			selectFeed := db.QueryRow(sql02_01, id_count["id"]) //strconv.Itoa(id_count["id"]))
			err := selectFeed.Scan(
        		&feed.ID,
        		&feed.title,
        		&feed.URL,
                &feed.image,
                &feed.updateDate,
                &feed.click,
			    &feed.siteID,
            )
			checkError(err)
            feedmap := map[string]interface{}{
				"id":          feed.ID,
				"viewcount":   id_count["viewcount"], //strconv.Itoa(id_count["viewcount"]),
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