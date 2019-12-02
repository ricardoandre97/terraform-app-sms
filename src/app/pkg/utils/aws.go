package utils

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/aws/aws-sdk-go/service/ssm"
)

func HandleAWS(ssmKey string, message string) error {

	creds, err := GetCredentials()
	if err != nil {
		return err
	}
	sess, err := session.NewSession(&aws.Config{
		Credentials: credentials.NewStaticCredentials(creds.AccessKeyId, creds.SecretAccessKey, creds.Token),
	})
	if err != nil {
		return err
	}

	ssmsvc := ssm.New(sess, aws.NewConfig())
	withDecryption := false

	// Get parameter value
	param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
		Name:           &ssmKey,
		WithDecryption: &withDecryption,
	})
	if err != nil {
		return err
	}

	topicArn := *param.Parameter.Value

	// Post to sns topic
	svc := sns.New(sess)
	result, err := svc.Publish(&sns.PublishInput{
		Message:  aws.String(message),
		TopicArn: &topicArn,
	})
	if err != nil {
		return err
	}
	fmt.Println(*result.MessageId)
	return nil
}
