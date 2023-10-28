FROM golang:1.18-alpine3.15 AS go

WORKDIR /app

COPY . .

RUN go mod download \
&& go build -o chitchat /app

CMD [ "/app/chitchat" ]
