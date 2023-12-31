package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/go-sql-driver/mysql"
)

func main() {
	var err error
	c := mysql.Config{
		DBName:               "chitchat",
		User:                 "admin",
		Passwd:               os.Getenv("MYSQL_PASSWORD"),
		Net:                  "tcp",
		ParseTime:            true,
		Collation:            "utf8mb4_unicode_ci",
		AllowNativePasswords: true,
		Addr:                 os.Getenv("MYSQL_HOST") + ":3306",
	}
	Db, err = sql.Open("mysql", c.FormatDSN())
	if err != nil {
		p("open error", err)
		log.Fatal(err)
	}

	loadConfig()
	logger = log.New(os.Stdout, "INFO ", log.Ldate|log.Ltime|log.Lshortfile)

	p("ChitChat", version(), "started at", config.Address)

	// handle static assets
	mux := http.NewServeMux()
	files := http.FileServer(http.Dir(config.Static))
	mux.Handle("/static/", http.StripPrefix("/static/", files))

	//
	// all route patterns matched here
	// route handler functions defined in other files
	//

	// error
	mux.HandleFunc("/err", errorRoute)

	// health check
	mux.HandleFunc("/health", health)

	// defined in route_auth.go
	mux.HandleFunc("/login", login)
	mux.HandleFunc("/logout", logout)
	mux.HandleFunc("/signup", signup)
	mux.HandleFunc("/signup_account", signupAccount)
	mux.HandleFunc("/authenticate", authenticate)

	// defined in route_thread.go
	mux.HandleFunc("/thread/new", newThread)
	mux.HandleFunc("/thread/create", createThread)
	mux.HandleFunc("/thread/post", postThread)
	mux.HandleFunc("/thread/read", readThread)

	// index
	mux.HandleFunc("/", index)

	// starting up the server
	server := &http.Server{
		Addr:           config.Address,
		Handler:        mux,
		ReadTimeout:    time.Duration(config.ReadTimeout * int64(time.Second)),
		WriteTimeout:   time.Duration(config.WriteTimeout * int64(time.Second)),
		MaxHeaderBytes: 1 << 20,
	}
	server.ListenAndServe()
}
