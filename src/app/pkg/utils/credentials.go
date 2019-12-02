package utils

import (
	"encoding/json"
	"fmt"
	"os"
)

type CredentialsResponse struct {
	RoleArn         string
	AccessKeyId     string
	SecretAccessKey string
	Token           string
	Expiration      string
}

func GetCredentials() (CredentialsResponse, error) {

	creds := CredentialsResponse{}

	url := fmt.Sprintf("http://169.254.170.2%v", os.Getenv("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI"))
	resp, err := GetUrl(url)
	if err != nil {
		return creds, err
	}

	jsonErr := json.Unmarshal(resp.Body, &creds)
	if jsonErr != nil {
		return creds, err
	}
	return creds, nil
}
