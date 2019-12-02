package handlers

import (
	"app/pkg/utils"
	"fmt"
	"html/template"
	"net/http"
	"os"
)

func SendMessage(w http.ResponseWriter, req *http.Request) {
	// If path is not /, it's not valid
	if req.URL.Path != "/" {
		http.NotFound(w, req)
		return
	}
	tmpl := template.Must(template.ParseFiles("templates/form.html"))

	// If method is not POST, render html form
	if req.Method != http.MethodPost {
		tmpl.Execute(w, nil)
		return
	}

	// Get SNS arn from SSM and post to topic
	err := utils.HandleAWS(os.Getenv("SSM_PARAM"), req.FormValue("message"))

	if err != nil {
		fmt.Println(err)
		tmpl.Execute(w, struct{ Fail bool }{true})
	} else {
		tmpl.Execute(w, struct{ Success bool }{true})
	}

}
