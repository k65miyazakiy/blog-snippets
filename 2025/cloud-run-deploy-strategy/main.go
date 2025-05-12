package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	target := os.Getenv("TARGET")
	if target == "" {
		target = "World"
	}

	// ハンドラーの定義
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request from %s", r.RemoteAddr)
		fmt.Fprintf(w, "Hello, %s!\n", target)
	})

	// ヘルスチェック用エンドポイント
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "OK")
	})

	// サーバー起動
	log.Printf("Starting server on port %s, version: %s", port, target)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
