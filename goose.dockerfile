FROM golang:alpine AS builder

LABEL authors="Jared Davis <jared.davis@pelo.tech>"

WORKDIR /github.com/pressly

RUN apk add git

RUN git clone https://github.com/pressly/goose

WORKDIR /github.com/pressly/goose

RUN go mod tidy && go build -ldflags="-s -w" -tags='no_sqlite no_clickhouse no_mssql no_mysql' -o /bin/goose ./cmd/goose

FROM scratch

COPY --from=builder /bin/goose /bin/goose

# https://pressly.github.io/goose/documentation/environment-variables/
ENV GOOSE_DBSTRING="user=postgres dbname=postgres sslmode=disable"

ENTRYPOINT [ "/bin/goose", "postgres" ]

CMD [ "status" ]
