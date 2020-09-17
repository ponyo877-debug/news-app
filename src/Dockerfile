FROM golang:alpine as builder
ADD . /work
WORKDIR /work

# Install our dependencies
RUN apk --no-cache add git make build-base
RUN go get github.com/PuerkitoBio/goquery
RUN go get github.com/labstack/echo
RUN go get github.com/mmcdole/gofeed
RUN go get github.com/lib/pq

# Build api
RUN go build -o GetLatestArticleList GetLatestArticleList.go

FROM golang:alpine
WORKDIR /usr/local/bin
COPY --from=builder /work/GetLatestArticleList /usr/local/bin/GetLatestArticleList
COPY --from=builder /work/config_prd.json /usr/local/bin/config.json
ENTRYPOINT ["/usr/local/bin/GetLatestArticleList"]
