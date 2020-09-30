package redis

import (
	"fmt"
	"context"
    "github.com/go-redis/redis"
)

func Get_Incr() {
	kvs := openKVS()
	ctx := context.Background()
	_, err := kvs.ZIncr(ctx, "counter", mem)
	checkError(err)
	result, err = kvs.Get(ctx, "counter").Result()
	checkError(err)

	fmt.Println(result)
	// Output: 1
}