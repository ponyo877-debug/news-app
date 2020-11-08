package redis

import (
	"fmt"
	_"context"
)

func GetIdsRankingTmp() []map[string]interface{}{
	db := OpenKVS()
	defer db.Close()
	zsetKey := "view_counter"

	// score, err := db.ZScore(zsetKey, postID).Result()
	idsranking, err := db.ZRevRangeWithScores(zsetKey, 0, 14).Result()
	checkError(err)
	
	var rankArray []map[string]interface{}
	for _, z := range idsranking {
		rankmap := map[string]interface{}{
			"id":          z.Member,
			"viewcount":   z.Score,
		}
		rankArray = append(rankArray, rankmap)
	}
	fmt.Println(rankArray)
	return rankArray
}