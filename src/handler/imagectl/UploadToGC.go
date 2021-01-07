package imagectl

import (
	"cloud.google.com/go/storage"
	"context"
	"github.com/labstack/echo"
	"google.golang.org/api/option"
	_ "io"
	"io/ioutil"
	"net/http"
	"fmt"
)

// checkError(err)
func UploadToGC() echo.HandlerFunc {
	return func(c echo.Context) error {
		credentialFilePath := "config_gcp.json"
		bktName := "img_matome"
		objName := "sample_cat.jpg"
		// path := "XXX"
		imageUrl := "http://placekitten.com/g/640/340"

		response, err := http.Get(imageUrl)
		checkError(err)
		defer response.Body.Close()

		// body, err := ioutil.ReadAll(response.Body)
		_, err = ioutil.ReadAll(response.Body)
		checkError(err)

		ctx := context.Background()

		// Creates a client.
		client, err := storage.NewClient(ctx, option.WithCredentialsFile(credentialFilePath))
		checkError(err)
		defer client.Close()

		wc := client.Bucket(bktName).Object(objName).NewWriter(ctx)
		defer wc.Close()
		// option
		// w.ObjectAttrs.ContentType = "application/octet-stream"
		// w.ChunkSize = 1024

		// f, err := os.Open(path)
		// checkError(err)
		// defer f.Close()

		// _, err = io.Copy(w, body)
		// _, err = wc.Write(body)
		// _, err = wc.Write(([]byte)(body))
		// checkError(err)
		if _, err := wc.Write([]byte("abcde\n")); err != nil {
			fmt.Println("createFile: unable to write data to bucket %q, file %q: %v", bktName, objName, err)
			return c.JSON(http.StatusOK, map[string]string{"status": "NG"})
		}

		return c.JSON(http.StatusOK, map[string]string{"status": "OK"})
	}
}
