package redis

import (
	"fmt"
	_"strconv"
)

func GetIdsRankingTmp() []map[string]interface{}{
	db := OpenKVS()
	defer db.Close()
	zsetKey := "view_counter"

	idsranking, err := db.ZRevRangeWithScores(zsetKey, 0, 14).Result()
	checkError(err)
	
	var rankArray []map[string]interface{}
	for _, z := range idsranking {
		/*
		Member_String, isString := z.Member.(string)
		if !isString {
			continue
		}
		_, err := strconv.Atoi(Member_String)
		if err != nil {
			continue
		}
		*/
		rankmap := map[string]interface{} {
			"id":          z.Member,
			"viewcount":   z.Score,
		}
		rankArray = append(rankArray, rankmap)
	}
	fmt.Println(rankArray)
	return rankArray
}