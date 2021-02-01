package main

import "./handler/rmads"
import "fmt"

func main() {
	Url := "http://news4vip.livedoor.biz/archives/52385741.html"
	result := rmads.RemoveAds(Url)
	fmt.Println(result)
}