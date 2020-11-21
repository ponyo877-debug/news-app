package elastic

import (
	"strings"
	"encoding/json"
)

func GetSearchResultTmp(searchwords string) []map[string]interface{}{
	client := OpenES()
	query := "{\"query\": { \"match\": { \"titles\": \"" + searchwords + "\"}}}"

	res, err := client.Search(
		client.Search.WithBody(strings.NewReader(query)),
		client.Search.WithPretty(),
	)
	checkError(err)
	defer res.Body.Close()
	var jsonstrings map[string]map[string][]map[string]map[string]interface{}
	err = json.NewDecoder(res.Body).Decode(&jsonstrings)
	prosjsonstrings := jsonstrings["hits"]["hits"]
	var searchArray []map[string]interface{}

	for _, searchmaptmp := range prosjsonstrings {
		searchArray = append(searchArray, searchmaptmp["_source"])
	}
	
	return searchArray
}