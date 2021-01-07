package imagectl

import (
	"fmt"
    "os"
)

type CSConfig struct {
    Host    string  `json:"host"`
    Port    int     `json:"port"`
    User  	string	`json:"user"`
    Pass    string  `json:"pass"`
}

func checkError(err error) {
	if err != nil {
	        fmt.Fprintf(os.Stderr, "fatal: error: %s", err.Error())
		os.Exit(1)
	}
}