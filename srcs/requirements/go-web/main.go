package main

import (
    "net/http"
    "log"
)

func main() {
    fs := http.FileServer(http.Dir("./static"))
    http.Handle("/", fs)

    log.Println("Listening on :8080...")
    err := http.ListenAndServe("0.0.0.0:8080", nil)
    if err != nil {
        log.Fatal(err)
    }
}
