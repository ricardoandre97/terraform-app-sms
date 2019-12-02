package main

import (
	"app/pkg/handlers"
	"fmt"
	"net/http"
)

func main() {

	http.HandleFunc("/", handlers.SendMessage)
	fmt.Println("App is running on port 8080...")
	http.ListenAndServe(":8080", nil)

}
