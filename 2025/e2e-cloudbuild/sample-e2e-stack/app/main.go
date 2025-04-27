package main

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/lib/pq"
)

type Message struct {
	ID        int
	Content   string
	CreatedAt time.Time
}

func main() {
	// データベース接続情報
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")
	dbUser := getEnv("DB_USER", "postgres")
	dbPassword := getEnv("DB_PASSWORD", "postgres")
	dbName := getEnv("DB_NAME", "testdb")
	
	// 接続文字列
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)
	
	// データベース接続
	var db *sql.DB
	var err error
	
	// 接続が成功するまで最大30秒待機
	for i := 0; i < 30; i++ {
		db, err = sql.Open("postgres", connStr)
		if err == nil {
			err = db.Ping()
			if err == nil {
				break
			}
		}
		fmt.Printf("データベース接続待機中... (%d秒)\n", i+1)
		time.Sleep(1 * time.Second)
	}
	
	if err != nil {
		log.Fatalf("データベース接続エラー: %v", err)
	}
	defer db.Close()
	
	// ハンドラーの設定
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "POST" {
			r.ParseForm()
			content := r.FormValue("content")
			
			if content != "" {
				_, err := db.Exec("INSERT INTO messages (content) VALUES ($1)", content)
				if err != nil {
					http.Error(w, "メッセージの保存中にエラーが発生しました", http.StatusInternalServerError)
					return
				}
			}
			
			// リダイレクト
			http.Redirect(w, r, "/", http.StatusSeeOther)
			return
		}
		
		// メッセージ一覧の取得
		rows, err := db.Query("SELECT id, content, created_at FROM messages ORDER BY created_at DESC")
		if err != nil {
			http.Error(w, "メッセージの取得中にエラーが発生しました", http.StatusInternalServerError)
			return
		}
		defer rows.Close()
		
		var messages []Message
		for rows.Next() {
			var m Message
			if err := rows.Scan(&m.ID, &m.Content, &m.CreatedAt); err != nil {
				http.Error(w, "データの解析中にエラーが発生しました", http.StatusInternalServerError)
				return
			}
			messages = append(messages, m)
		}
		
		// テンプレートの表示
		tmpl := template.Must(template.New("index").Parse(`
<!DOCTYPE html>
<html>
<head>
    <title>シンプルメッセージボード</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .message { border: 1px solid #ddd; padding: 10px; margin-bottom: 10px; }
        form { margin-bottom: 20px; }
        input[type="text"] { width: 80%; padding: 8px; }
        input[type="submit"] { padding: 8px 15px; }
    </style>
</head>
<body>
    <h1>シンプルメッセージボード</h1>
    
    <form method="post">
        <input type="text" name="content" placeholder="メッセージを入力" required>
        <input type="submit" value="送信">
    </form>
    
    <h2>メッセージ一覧</h2>
    {{if .}}
        {{range .}}
        <div class="message">
            <p>{{.Content}}</p>
            <small>{{.CreatedAt.Format "2006-01-02 15:04:05"}}</small>
        </div>
        {{end}}
    {{else}}
        <p>メッセージはありません</p>
    {{end}}
</body>
</html>
`))
		tmpl.Execute(w, messages)
	})
	
	// サーバー起動
	port := getEnv("PORT", "8080")
	fmt.Printf("サーバーを起動しています: http://localhost:%s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

// 環境変数の取得（デフォルト値付き）
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
