package utils

import (
	"io/ioutil"
	"net/http"
)

type HttResponse struct {
	Body       []byte
	StatusCode int
}

func GetUrl(url string) (HttResponse, error) {
	resp, err := http.Get(url)
	if err != nil {
		return HttResponse{nil, http.StatusBadRequest}, err
	}
	defer resp.Body.Close()

	response, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return HttResponse{nil, http.StatusBadRequest}, err
	}

	return HttResponse{response, resp.StatusCode}, nil
}
