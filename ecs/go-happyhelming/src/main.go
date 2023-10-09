package main

import (
  "fmt"
  "net/http"
)

func handler(writer http.ResponseWriter, request *http.Request) {
  fmt.Fprintf(writer, "Happy Helming, %s!", request.URL.Path[1:])
  fmt.Printf("Request received for %s\n", request.URL.Path[1:])
}

func main() {
  http.HandleFunc("/", handler)
  http.ListenAndServe(":8080", nil)
  fmt.Println("Server starting on port 8080")
}
