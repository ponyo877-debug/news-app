package redis

import (
	"fmt"
    "os"
    "strconv"
    "io/ioutil"
    "encoding/json"
    "github.com/go-redis/redis"
)

type KVSConfig struct {
    Host    string  `json:"host"`
    Port    int     `json:"port"`
    Db  	int		`json:"db"`
    Pass    string  `json:"pass"`
}

func checkError(err error) {
	if err != nil {
	        fmt.Fprintf(os.Stderr, "fatal: error: %s", err.Error())
		os.Exit(1)
	}
}

func openKVS() *redis.Client{
	jsonString, err := ioutil.ReadFile("config_redis.json")
    checkError(err)
    
    var c KVSConfig
    err = json.Unmarshal(jsonString, &c)
	checkError(err)
	
	rdb := redis.NewClient(&redis.Options{
		Addr:     c.Host + ":" + strconv.Itoa(c.Port),
		Password: c.Pass,
		DB:       c.Db,
	})
	return rdb
}

