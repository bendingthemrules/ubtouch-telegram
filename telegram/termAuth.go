package telegram

import (
	"context"
	"fmt"
	"github.com/gotd/td/telegram"
	"github.com/gotd/td/tg"
	"time"
)

type termAuth struct {
	noSignUp

	client *telegram.Client
	phone  string
}

func (a termAuth) Phone(_ context.Context) (string, error) {
	return a.phone, nil
}

func (a termAuth) Password(_ context.Context) (string, error) {
	return "", nil
}

func (a termAuth) Code(ctx context.Context, authSentCode *tg.AuthSentCode) (string, error) {
	fmt.Println("GRABBING CODE")

	newTimer := time.NewTimer(time.Minute * 5)

	go func() {
		<-newTimer.C
		if code != "" {
			return
		}
		_, err := a.client.API().AuthResendCode(ctx, &tg.AuthResendCodeRequest{
			PhoneNumber:   a.phone,
			PhoneCodeHash: authSentCode.PhoneCodeHash,
		})
		if err != nil {
			fmt.Println(err)
		}
	}()

	for code == "" {
	}
	fmt.Println("RETURNING CODE", code)
	return code, nil
}
